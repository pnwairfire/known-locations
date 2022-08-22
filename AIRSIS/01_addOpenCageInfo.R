# NOTE:  Run this script first, checking as you go. Then run the elevation script.

# Use a web service to add missing address data

library(MazamaLocationUtils)

collectionDir <- "AIRSIS"
collectionName <- "airsis_PM2.5_sites_1000"
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

# Sanity check: both of these should be FALSE
any(is.na(locationTbl$locationID))
any(duplicated(locationTbl$locationID))

# ----- Subset and retain ordering ---------------------------------------------

uniqueOnlyTbl <-
  locationTbl %>%
  dplyr::select(locationID)

hasAddressTbl <-
  locationTbl %>%
  dplyr::filter(!is.na(address))

missingAddressTbl <-
  locationTbl %>%
  dplyr::filter(is.na(address))

dim(uniqueOnlyTbl)
dim(hasAddressTbl)
dim(missingAddressTbl)

# NOTE:  If there are no records with missing addresses, you can stop here.

# Review
if ( nrow(missingAddressTbl) > 0 ) {

  missingAddressTbl %>%
    table_leaflet(
      extraVars = c("fullAQSID", "elevation", "address"),
      jitter = 0
    )

}

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
    extraVars = c("fullAQSID", "elevation", "address"),
    jitter = 0
  )

# ----- Combine two halves -----------------------------------------------------

updatedLocationTbl <-
  dplyr::bind_rows(hasAddressTbl, missingAddressTbl)

# Use original ordering
locationTbl <-
  uniqueOnlyTbl %>%
  dplyr::left_join(updatedLocationTbl, by = c("locationID"))

# Sanity check: should be TRUE
identical(uniqueOnlyTbl$locationID, locationTbl$locationID)

# Review
locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("fullAQSID", "elevation", "address"),
    jitter = 0
  )

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


