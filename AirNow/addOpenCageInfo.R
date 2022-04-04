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

# NOTE:    1) two different AQSIDs to share the same locationID
# NOTE:    2) two different locationIDs to share the same AQSID

# Sanity check: both of these should be FALSE
any(is.na(locationTbl$AQSID))
any(duplicated(paste0(locationTbl$locationID, "_", locationTbl$AQSID)))

duplicateIDs <- locationTbl$locationID[duplicated(locationTbl$locationID)]

duplicatesTbl <-
  locationTbl %>%
  dplyr::filter(locationID %in% duplicateIDs)

duplicatesTbl %>%
  dplyr::select(locationID, AQSID, locationName) %>%
  dplyr::arrange(locationID) %>%
  View()

# ----- Subset and retain ordering ---------------------------------------------

uniqueOnlyTbl <-
  locationTbl %>%
  dplyr::select(locationID, AQSID)

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

missingAddressTbl <- table_addOpenCageInfo(
  missingAddressTbl,
  replaceExisting = TRUE,
  retainOpenCage = FALSE,
  verbose = FALSE
)

# Review
missingAddressTbl %>% table_leaflet(extraVars = c("elevation", "address"))

# ----- Combine two halves -----------------------------------------------------

updatedLocationTbl <-
  dplyr::bind_rows(hasAddressTbl, missingAddressTbl)

# Use original ordering
locationTbl <-
  uniqueOnlyTbl %>%
  dplyr::left_join(updatedLocationTbl, by = c("locationID", "AQSID"))

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


