# Use a web service to add missing elevation data AFTER updating with OpenCage

library(MazamaLocationUtils)

collectionName <- "airsis_PM2.5_sites_1000"

# ----- Load and Review --------------------------------------------------------

setLocationDataDir("./AIRSIS")

locationTbl <-
  table_load(collectionName) %>%
  # Saw a record with all missing values once
  dplyr::filter(!is.na(.data$longitude) & !is.na(.data$latitude))

missingElevation_mask <- is.na(locationTbl$elevation)

if ( sum(missingElevation_mask) > 0 ) {

  locationTbl[missingElevation_mask,] %>%
    MazamaLocationUtils::table_leaflet(
      extraVars = "elevation",
      jitter = 0
    )

}

# ----- Add elevations ---------------------------------------------------------

missingCount <- sum(missingElevation_mask)
message(sprintf("Getting %d missing elevations ...", missingCount))

# NOTE:  This is a manual operation so print out progress
count <- 0
for ( i in which(missingElevation_mask) ) {

  count <- count + 1
  if ( (count %% 10) == 0 )
    message(sprintf("Working on %d/%d ...", count, missingCount))

  result <- try({

    locationTbl$elevation[i] <-
      location_getSingleElevation_USGS(
        longitude = locationTbl$longitude[i],
        latitude = locationTbl$latitude[i]
      ) %>%
      round(0) # Sub meter elevation precision is very unlikely

  }, silent = FALSE)

  if ( "try-error" %in% class(result) ) {
    next
  }

}

# ----- Review -----------------------------------------------------------------

locationTbl[missingElevation_mask,] %>%
  MazamaLocationUtils::table_leaflet(
    extraVars = c("elevation", "address"),
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


