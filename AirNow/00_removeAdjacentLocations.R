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

# ----- Review adjacent locations ----------------------------------------------

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
  # Canada
  "d9b7c49d81252e45",
  # WA
  "cd32c50d23e420de", "e9679b74fac7ed17", "17eacd84ae159d27",
  # ID
  "76ad362e5cecbb59",
  # WY
  "b8c19e231575557f",
  # FL
  "beb421676bf0e259",
  # IN
  "930dc39fcbef74ae", "d077f55fc2aa1520", "75ba3eaff7a6a4f3", "32bf022211283be6",
  # CO
  "ae18f23c92c781a5",
  # NM
  "9tuver0", "9tuver1", "9tuver2",
  # HI
  "3456b204b12ffadd",
  # CA
  "26ffe6f6fc94422d", "2b1eba90a08e5659", "c06f3b511ec4ef5c", "ceeac675fd056a51",
  "564d460e1c3ec388", "121fad25495a747a", "2275481147c5c093"
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


