# NOTE:  Run this script first, checking as you go. Then run the elevation script.

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load and Review --------------------------------------------------------

download.file(
  file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

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
print(length(duplicateIDs)) # zero is what we hope for

if ( length(duplicateIDs) > 0 ) {

  duplicatesTbl <-
    locationTbl %>%
    dplyr::filter(locationID %in% duplicateIDs)

  duplicatesTbl %>%
    dplyr::select(locationID, fullAQSID, locationName) %>%
    dplyr::arrange(locationID) %>%
    View()

}

# ----- Manual updates ---------------------------------------------------------

# NOTE:  This is the place to review the location table visually and make any
# NOTE:  manual fixes.
# NOTE:
# NOTE:  For example, if want to remove multiple locations associated with a
# NOTE:  single fullAQSID, this would be the place to do it.

if ( FALSE ) {

  duplicates_locationTbl <-
    locationTbl %>%
    dplyr::filter(fullAQSID == "840MMFS11043")

  map <-
    table_leaflet(
      duplicates_locationTbl,
      jitter = 0
    )

  preferredLocationTbl <-
    AirMonitorIngest::airnow_getSites() %>%
    dplyr::filter(parameterName == "PM2.5") %>%
    dplyr::filter(status == "Active")

  table_leafletAdd(
    map,
    preferredLocationTbl,
    jitter = 0
  )

  preferred_locationID <-
    MazamaCoreUtils::createLocationID(
      preferredLocationTbl$longitude,
      preferredLocationTbl$latitude
    )

  badIDs <- setdiff(duplicates_locationTbl$locationID, preferred_locationID)

  locationTbl <-
    locationTbl %>%
    table_removeRecord(locationID = badIDs, verbose = TRUE)


  ###
  # Custom removal of a single ID
  ###

  # locationTbl <-
  #   locationTbl %>%
  #   table_removeRecord(locationID = "d4ba731653a47dfe", verbose = TRUE)


  ###
  # Custom removal of a single ID
  ###

  # locationTbl <-
  #   locationTbl %>%
  #   dplyr::filter(fullAQSID != "840MMFS13203")


}

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
missingAddressTbl %>%
  table_leaflet(
    extraVars = c("fullAQSID", "elevation", "address"),
    jitter = 0
  )

# ----- Add OpenCage info ------------------------------------------------------

Sys.setenv("OPENCAGE_KEY" = OPENCAGE_API_KEY)

missingAddressTbl <- table_addOpenCageInfo(
  missingAddressTbl,
  replaceExisting = TRUE,
  retainOpenCage = FALSE,
  verbose = FALSE
)

# Review
missingAddressTbl %>%
  table_leaflet(
    extraVars = c("elevation", "address"),
    jitter = 0
  )

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
###locationTbl %>% MazamaLocationUtils::table_leaflet(extraVars = "address")

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


