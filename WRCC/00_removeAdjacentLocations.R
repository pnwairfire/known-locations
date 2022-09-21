# NOTE:  Modify this script to review/fix the AirNow sites metadata

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "WRCC"
collectionName <- "wrcc_PM2.5_sites_1000"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load locationTbl -------------------------------------------------------

download.file(
  file.path("https://airfire-data-exports.s3.us-west-2.amazonaws.com/monitoring/v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
  # file.path("http://data-monitoring_v2-c1.airfire.org/monitoring-v2/known-locations", collectionFile),
  # destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 1000) # 500 is the actual separation we use

dim(adjacent_kl)

# If nrow(adjacent_kl) > 0, review the map

if ( nrow(adjacent_kl) > 0 ) {

  map <-
    adjacent_kl %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  print(map)

}

# ----- Locations to drop ------------------------------------------------------

# On 2022-09-21
#
badIDs <- c(
  # OR
  "03331ebcd95f5711"
)

locationTbl <-
  locationTbl %>%
  table_removeRecord(locationID = badIDs, verbose = TRUE)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 200) # 500 is the actual separation we use

map <-
  adjacent_kl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

print(map)


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


