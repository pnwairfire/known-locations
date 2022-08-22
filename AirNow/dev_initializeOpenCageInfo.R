# NOTE:  Run this script when you are rebuilding a data archive and have a
# NOTE:  brand new known locations table

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load and Review --------------------------------------------------------

# download.file(
#   file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
#   destfile = file.path(".", collectionDir, collectionFile)
# )

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Review duplicate locationIDs -------------------------------------------

# NOTE:  We support duplicate locationIDs for AirNow because it is possible for

# NOTE:    1) two different fullAQSIDs to share the same locationID
# NOTE:    2) two different locationIDs to share the same fullAQSID

# Sanity check: both of these should be FALSE
any(is.na(locationTbl$fullAQSID))
any(duplicated(paste0(locationTbl$locationID, "_", locationTbl$fullAQSID)))

duplicateIDs <- locationTbl$locationID[duplicated(locationTbl$locationID)]

duplicatesTbl <-
  locationTbl %>%
  dplyr::filter(locationID %in% duplicateIDs)

duplicatesTbl %>%
  dplyr::select(locationID, fullAQSID, locationName) %>%
  dplyr::arrange(locationID) %>%
  View()

# ----- Subset and retain ordering ---------------------------------------------

uniqueOnlyTbl <-
  locationTbl %>%
  dplyr::select(locationID, fullAQSID)

if ( !"address" %in% names(locationTbl) )
  locationTbl$address <- as.character(NA)

hasAddressTbl <-
  locationTbl %>%
  dplyr::filter(!is.na(address))

missingAddressTbl <-
  locationTbl %>%
  dplyr::filter(is.na(address))

dim(uniqueOnlyTbl)
dim(hasAddressTbl)
dim(missingAddressTbl)

# Review
missingAddressTbl %>% table_leaflet(extraVars = c("elevation", "address"))

# ----- Add OpenCage info ------------------------------------------------------

if ( Sys.getenv("OPENCAGE_KEY") == "" )
  stop("Please set one with Sys.setenv(\"OPENCAGE_KEY\" = \"<YOUR_KEY>\").")

# missingAddressTbl <- table_addOpenCageInfo(
#   missingAddressTbl,
#   replaceExisting = TRUE,
#   retainOpenCage = FALSE,
#   verbose = FALSE
# )

for ( i in seq_len(nrow(missingAddressTbl)) ) {

  if ( (i %% 10) == 0 )
    message(sprintf("Getting OpenCage info for %d of %d", i, nrow(missingAddressTbl)))

  result <- try({

    OpenCageList <-
      location_getOpenCageInfo(
        missingAddressTbl$longitude[i],
        missingAddressTbl$latitude[i],
        verbose = FALSE
      )

    if ( "address" %in% names(OpenCageList) )
      missingAddressTbl$address[i] <- OpenCageList$address
    if ( "components.country_code" %in% names(OpenCageList) )
      missingAddressTbl$countryCode[i] <- toupper(OpenCageList$components.country_code)
    if ( "components.state_code" %in% names(OpenCageList) )
      missingAddressTbl$stateCode[i] <- toupper(OpenCageList$components.state_code)
    if ( "annotations.timezone.name" %in% names(OpenCageList) )
      missingAddressTbl$timezone[i] <- OpenCageList$annotations.timezone.name
    if ( "components.countyName" %in% names(OpenCageList) )
      missingAddressTbl$county[i] <- OpenCageList$components.county %>% stringr::str_replace(" County", "")
    if ( "components.house_number" %in% names(OpenCageList) )
      missingAddressTbl$houseNumber[i] <- OpenCageList$components.house_number
    if ( "components.road" %in% names(OpenCageList) )
      missingAddressTbl$street[i] <- OpenCageList$components.road
    if ( "components.town" %in% names(OpenCageList) )
      missingAddressTbl$city[i] <- OpenCageList$components.town
    if ( "components.postcode" %in% names(OpenCageList) )
      missingAddressTbl$zip[i] <- OpenCageList$components.postcode

  }, silent = TRUE)

}

# Review
missingAddressTbl %>% table_leaflet(extraVars = c("elevation", "address"))

# ----- Combine two halves -----------------------------------------------------

updatedLocationTbl <-
  dplyr::bind_rows(hasAddressTbl, missingAddressTbl)

# Use original ordering
locationTbl <-
  uniqueOnlyTbl %>%
  dplyr::left_join(updatedLocationTbl, by = c("locationID", "fullAQSID"))

# Sanity check: should be TRUE
identical(uniqueOnlyTbl$locationID, locationTbl$locationID)

# Review
locationTbl %>% MazamaLocationUtils::table_leaflet(extraVars = "address")

# ----- Save the table ---------------------------------------------------------

table_save(
  locationTbl,
  collectionName = collectionName,
  backup = FALSE,
  outputType = "csv"
)

table_save(
  locationTbl,
  collectionName = collectionName,
  backup = FALSE,
  outputType = "rda"
)


# NOTE:  Now you should walk through addMissingElevation.R


