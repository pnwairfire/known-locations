# Use a web service to add missing elevation data

library(MazamaLocationUtils)

collectionName <- "airnow_PM2.5_sites"

# ----- Load and Review --------------------------------------------------------

setLocationDataDir("./AirNow")

locationTbl <- table_load(collectionName)

# Fix locationTbl:
# 1) airnow_FIPSMSACode once got converted to <dbl> after a manual update

locationTbl <-
  locationTbl %>%
  dplyr::mutate(
    airnow_FIPSMSACode = as.character(.data$airnow_FIPSMSACode)
  )

missingElevation_mask <- is.na(locationTbl$elevation)

locationTbl[missingElevation_mask,] %>%
  MazamaLocationUtils::table_leaflet(extraVars = "elevation")

# ----- Add elevations ---------------------------------------------------------

# NOTE:  This is a manual operation so print out progress
for ( i in which(missingElevation_mask) ) {

  if ( (i %% 10) == 0 )
    message(sprintf("Working on %d ...", i))

  result <- try({

    locationTbl$elevation[i] <-
      location_getSingleElevation_USGS(
        longitude = locationTbl$longitude[i],
        latitude = locationTbl$latitude[i]
      )

  }, silent = FALSE)

  if ( "try-error" %in% class(result) ) {
    next
  }

}

# ----- Review -----------------------------------------------------------------

locationTbl[missingElevation_mask,] %>%
  MazamaLocationUtils::table_leaflet(extraVars = "elevation")


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


