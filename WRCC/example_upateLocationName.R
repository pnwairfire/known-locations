# NOTE:  Modify this script to fix one field at a time

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


# ----- Problem to fix ---------------------------------------------------------

locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

# "Rocky Mtn Fire Cache" west of Denver, CO
locationIDs <- c("6594e05e882c2c1e")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Rocky Mtn Fire Cache"

# "Met One" headquarters in Grants Pass, OR
locationIDs <- c("e2b1634a0cf7d694")
locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Met One"


# Review
locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
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


