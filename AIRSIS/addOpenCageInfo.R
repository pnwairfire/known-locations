# Use a web service to add missing elevation data

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

locationTbl %>%
  dplyr::filter(is.na(.data$address)) %>%
  table_leaflet(extraVars = c("elevation", "address"))


# ----- Add OpenCage info ------------------------------------------------------

# locationTbl <- table_addOpenCageInfo(
#   locationTbl,
#   replaceExisting = FALSE,
#   retainOpenCage = FALSE,
#   verbose = FALSE
# )

# NOTE:  Had to use the chunk below when I had a problem with tidygeocoder

openCageList <- list()

for ( i in seq_len(nrow(locationTbl)) ) {

  if ( (i %% 20) == 0 ) message("Working on ", i, " ...")

  openCageList[[i]] <-
    ###MazamaLocationUtils::location_getOpenCageInfo(
    location_getOpenCageInfo(
      longitude = locationTbl$longitude[i],
      latitude = locationTbl$latitude[i],
      verbose = FALSE
    )

}

openCageTbl <- dplyr::bind_rows(openCageList)

# TODO:  Paste sourceLines from MazamaLocationUtils::table_addOpenCageInfo()

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


