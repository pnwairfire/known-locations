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

plot(map)

sites <- AirMonitorIngest::airnow_getSites()

adjacent_sites <-
  sites %>%
  table_findAdjacentLocations(distanceThreshold = 200) # 500 is the actual separation we use

map <-
  adjacent_sites %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

plot(map)



# ----- Problem to fix ---------------------------------------------------------

locationTbl %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("locationName", "fullAQSID"),
    jitter = 0
  )

# Two locations west of Denver should be named "Rocky Mtn Fire Cache"

locationIDs <- c("b0fc73f5f6581c98", "1dd986303ae855f0")

locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Rocky Mtn Fire Cache"

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


