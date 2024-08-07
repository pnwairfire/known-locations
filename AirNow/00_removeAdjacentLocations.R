# NOTE:  Modify this script to review/fix the AirNow sites metadata

# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionDir <- "AirNow"
collectionName <- "airnow_PM2.5_sites"
collectionFile <- paste0(collectionName, ".rda")

# ----- Load locationTbl -------------------------------------------------------

download.file(
  file.path("https://airfire-data-exports.s3.us-west-2.amazonaws.com/monitoring/v2/known-locations", collectionFile),
  destfile = file.path(".", collectionDir, collectionFile)
)

setLocationDataDir(file.path(".", collectionDir))

locationTbl <- table_load(collectionName)
dim(locationTbl)

# ----- Find adjacent locations ------------------------------------------------

adjacent_kl <-
  locationTbl %>%
  table_findAdjacentLocations(distanceThreshold = 100) # 500 is the actual separation we use

dim(adjacent_kl) # NOTE:  Two monitors in Calgary are < 200m apart

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

# On 2024-07-11
#
badIDs <- c(
  # ID
  "c2m274b",
  # FL
  "djmgqq5",
  # NM
  "9tfg89w",
  # CA
  "51371acbacd2b0ed",
  "6b06028001ac0f6f",
  "9r0qtq3",
  "9r2434q",
  "9r24uz5",
  "9r24uz6",
  "5742a6bbfc5d0683"
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


