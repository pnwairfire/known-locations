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
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 250) # 500 is the actual separation we use

dim(adjacent_kl)

# ----- Review adjacent locations ----------------------------------------------

if ( nrow(adjacent_kl) > 0 ) {

  adjacent_kl %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

} else {

  message("No adjacent locations. Proceed to step 01_addOpenCageInfo")

}

# ----- Locations to drop ------------------------------------------------------

# On 2022-09-22
#
badIDs <- c(
  # Mongolia and China (longitudes W?)
  "9304f07e2f12afde",
  "d98a65c17e22355f",
  "57a64a5afb5e47eb",
  "7390819102f42221",
  "cba8774652e52d4b",
  "4eba35453e7394b1"
)

locationTbl <-
  locationTbl %>%
  table_removeRecord(locationID = badIDs, verbose = TRUE)

# ----- Review adjacent locations ----------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 200) # 500 is the actual separation we use

nrow(adjacent_kl)

# NOTE:  Allow two locations in Entiat on either side of 97

if ( nrow(adjacent_kl) > 0 ) {

  map <-
    adjacent_kl %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  print(map)

}

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


