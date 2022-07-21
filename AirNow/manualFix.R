# NOTE:  Modify this script to fix one field at a time

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

# ----- Problem to fix ---------------------------------------------------------

locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

# NOTE:  Could also use MazamaLocationUtils::table_updateSingleRecord()

locationIDs <- c("9e06ddbd5f5e1d2f")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Red Bluff"

locationIDs <- c("74e0ef973916e244")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Bella Vista"

locationIDs <- c("6b06028001ac0f6f")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Mineral"

locationIDs <- c("a429b3f0992869a4")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Round Mountain"

locationIDs <- c("07454c54ae3963f0")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Burney"


# Review
locationTbl %>% MazamaLocationUtils::table_leaflet(extraVars = "locationName")

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


