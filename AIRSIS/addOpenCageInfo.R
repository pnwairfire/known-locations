# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionName <- "airsis_PM2.5_sites_1000"

# ----- Load and Review --------------------------------------------------------

download.file(
  "http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations/airsis_PM2.5_sites_1000.rda",
  destfile = "./AIRSIS/airsis_PM2.5_sites_1000.rda"
)

setLocationDataDir("./AIRSIS")

locationTbl <- table_load(collectionName)

locationTbl %>% table_leaflet()


# ----- Add OpenCage info ------------------------------------------------------

locationTbl <- table_addOpenCageInfo(
  locationTbl,
  replaceExisting = TRUE,
  verbose = FALSE
)


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


