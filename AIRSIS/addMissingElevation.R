# Use a web service to add missing elevation data AFTER updating with OpenCage

# library(MazamaLocationUtils)
#
# collectionName <- "airsis_PM2.5_sites_1000"
#
# library(MazamaLocationUtils)
#
# collectionDir <- "AIRSIS"
# collectionName <- "airsis_PM2.5_sites_1000"
# collectionFile <- paste0(collectionName, ".rda")
#
# # ----- Load known locations ---------------------------------------------------
#
# download.file(
#   file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
#   destfile = file.path(".", collectionDir, collectionFile)
# )
#
# setLocationDataDir(file.path(".", collectionDir))
#
# locationTbl <- table_load(collectionName)


# ----- Review missing elevations ----------------------------------------------

missingElevation_mask <- is.na(locationTbl$elevation)

locationTbl[missingElevation_mask,] %>%
  MazamaLocationUtils::table_leaflet(extraVars = "elevation")

# ----- Add elevations ---------------------------------------------------------

message(sprintf("Getting %d missing elevations ...", sum(missingElevation_mask)))

# NOTE:  This is a manual operation so print out progress
count <- 0
for ( i in which(missingElevation_mask) ) {

  count <- count + 1
  if ( (count %% 10) == 0 )
    message(sprintf("Working on %d/%d ...", count, length(missingElevation_mask)))

  result <- try({

    locationTbl$elevation[i] <-
      location_getSingleElevation_USGS(
        longitude = locationTbl$longitude[i],
        latitude = locationTbl$latitude[i]
      )

  }, silent = FALSE)

  if ( "try-error" %in% class(result) ) {
    next
  }

}

# ----- Review -----------------------------------------------------------------

locationTbl[missingElevation_mask,] %>%
  MazamaLocationUtils::table_leaflet(extraVars = c("elevation", "address"))


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


