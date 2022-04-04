# NOTE:  Run this script first, checking as you go. Then run the elevation script.

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "WRCC"
collectionName <- "wrcc_PM2.5_sites_1000"
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

# NOTE:  Had to use the chunk below when I had a problem with tidygeocoder

# openCageList <- list()
#
# for ( i in seq_len(nrow(locationTbl)) ) {
#
#   if ( (i %% 20) == 0 ) message("Working on ", i, " ...")
#
#   openCageList[[i]] <-
#     MazamaLocationUtils::location_getOpenCageInfo(
#       longitude = locationTbl$longitude[i],
#       latitude = locationTbl$latitude[i],
#       verbose = FALSE
#     )
#
# }
#
#
# openCageTbl <- dplyr::bind_rows(openCageList)
#
# # TODO:  Paste sourceLines from MazamaLocationUtils::table_addOpenCageInfo()

# Combine two halves
updatedLocationTbl <-
  dplyr::bind_rows(hasAddressTbl, missingAddressTbl)

# Use original ordering
locationTbl <-
  uniqueOnlyTbl %>%
  dplyr::left_join(updatedLocationTbl, by = c("locationID"))

# Sanity check: should be TRUE
identical(uniqueOnlyTbl$locationID, locationTbl$locationID)

# ----- Review -----------------------------------------------------------------

locationTbl %>%
  MazamaLocationUtils::table_leaflet(extraVars = "address")


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



