# NOTE:  Modify this script to fix one field at a time

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
dim(locationTbl)

# ===== BY deviceDeploymentID ==================================================

if ( FALSE ) {

  # Unit 1027 mis-identified as 1026
  badIDs <- c("71bcdf39b6d635a4")

  # Review bad locations
  locationTbl %>%
    dplyr::filter(locationID == badIDs) %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  locationTbl <-
    locationTbl %>%
    table_updateSingleRecord(
      locationList = list(
        locationID = "71bcdf39b6d635a4",
        fullAQSID = "840MMFS11027",
        locationName = "Kernville",
        AQSID = "MMFS11027",
        airnow_stationID = "MMFS11027"
      )
    )


  # Review fixed locations
  locationTbl %>%
    dplyr::filter(locationID == badIDs) %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  # ----- Save the table -------------------------------------------------------

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

}

# ===== BY fullAQSID ===========================================================

if ( FALSE ) {

  locationTbl %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = c("locationName", "fullAQSID"),
      jitter = 0
    )

  # NOTE:  Could also use MazamaLocationUtils::table_updateSingleRecord()

  # locationIDs <- c("d9c1a2c884e60130")
  # locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Oakhurst"
  #
  # locationIDs <- c("786ab2a4f8f46681")
  # locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Minaret Creek"
  #
  # locationIDs <- c("9fbd8adf8e6e80a4")
  # locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Mammoth Mountain"
  #
  # locationIDs <- c("16d71b0a47a77f39")
  # locationTbl[locationTbl$locationID %in% locationIDs, "locationName"] <- "Devil's Postpile"


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

}
