# Manual corrections to airnow_PM2.5_sites.csv

library(MazamaLocationUtils)

collectionName <- "airnow_PM2.5_sites"

# ----- Load and Review --------------------------------------------------------

setLocationDataDir(".")

locationTbl <- table_load(collectionName)

MazamaLocationUtils::table_leaflet(
  locationTbl,
  maptype = "terrain",
  extraVars = c(
    "AQSID",
    "airnow_agencyName",
    "airnow_status"
  ),
  radius = 6,
  color = "black",
  weight = 2,
  fillColor = "blue",
  fillOpacity = 0.2
)

# ----- Fix stateCode ----------------------------------------------------------

# 2021-01-07 -- Fix stateCode mis-assignments at Canadian and Mexican borders

# Porthill, ID identified as BC -- b14c5a040b3aee2c
# Morrisburg, ON identified as NY -- 0e2ff7a2abcd3041
# Edmundston, NB identified as ME -- 9f2a9a1f8b550294
# Brownsville, TX identified as TM -- 10c34f29096856e3
# Laredo, TX identified as TM -- 73c648b20e722712
# Acarate Park, TX identified as CH -- 80c94e655393916e
# El Pas Sun Metro, TX identified as CH -- 9d1aad926a9cc797
# Laredo, TX identified as TM -- 73c648b20e722712

locationID <- c(
  "b14c5a040b3aee2c",
  "0e2ff7a2abcd3041",
  "9f2a9a1f8b550294",
  "10c34f29096856e3",
  "73c648b20e722712",
  "80c94e655393916e",
  "9d1aad926a9cc797",
  "73c648b20e722712"
)

locationData <- c("ID", "ON", "NB", "TX", "TX", "TX", "TX", "TX")

locationTbl <- MazamaLocationUtils::table_updateColumn(
  locationTbl,
  columnName = "stateCode",
  locationID = locationID,
  locationData = locationData,
  verbose = TRUE
)

# ----- Review -----------------------------------------------------------------

locationTbl %>%
  dplyr::filter(locationID %in% !!locationID) %>%
  MazamaLocationUtils::table_leaflet(extraVars = "airnow_agencyName")

# ----- Save the table ---------------------------------------------------------

MazamaLocationUtils::table_save(
  locationTbl,
  collectionName = collectionName,
  backup = FALSE,
  outputType = "csv"
)


