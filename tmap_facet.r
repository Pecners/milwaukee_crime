# I dare do all that may become a man...

library(tidyverse)
library(sf)
library(tmap)

# FYI this file is over 600,000 observations

crime <- read_csv("https://data.milwaukee.gov/dataset/e5feaad3-ee73-418c-b65d-ef810c199390/resource/87843297-a6fa-46d4-ba5d-cb342fb2d3bb/download/wibr.csv")

# cleaning data for mapping ====

crime_location <- crime %>%
  filter(!is.na(RoughX) & !is.na(RoughY)) %>%
  st_as_sf(coords = c("RoughX", "RoughY"), crs = 32054)

# Shapefiles can be found online
# or I have a repo here: https://github.com/Pecners/shapefiles
# Note that you will need all files located in a single folder

neighb <- read_sf("milwaukee_neighborhood/neighborhood.shp")
crime_neighb <- st_transform(crime_location, crs = st_crs(neighb))

# this chunk takes a while

crime_neighb <- crime_neighb %>%
  gather("Crime", "yn", -c(1:12, 23)) %>%
  filter(yn != 0)

# this chunk takes a while longer

crime_neighb <- st_intersection(neighb, crime_neighb)

crime_neighb_18 <- crime_neighb %>%
  filter(ReportedYear == 2018)

# make the map ====

tm_shape(neighb) +
  tm_polygons(border.alpha = 0) +
tm_shape(crime_neighb_18) +
  tm_dots(col = "red", alpha = 0.5) +
tm_facets(by = "Crime", free.coords = FALSE) +
tm_layout(main.title = "Reported Crimes in Milwaukee, 2018")
