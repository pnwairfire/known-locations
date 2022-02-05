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

locationTbl %>% table_leaflet(extraVars = c("elevation", "address"))


# ----- Add OpenCage info ------------------------------------------------------

# TODO:  waiting on a fix in tidygeocoder

# locationTbl <- table_addOpenCageInfo(
#   locationTbl,
#   replaceExisting = TRUE,
#   verbose = FALSE
# )

openCageList <- list()

for ( i in seq_len(nrow(locationTbl)) ) {

  if ( (i %% 20) == 0 ) message("Working on ", i, " ...")

  openCageList[[i]] <-
    MazamaLocationUtils::location_getOpenCageInfo(
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


