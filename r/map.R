library(leaflet)
library(rgdal)
library(sp)
library(sf)
library(raster)

locality <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_ji/ARG_Cordoba_UrbanRisk.shp")

locality1 <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_new/ARG_Cordoba_UrbanRisk.shp")

x <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_new/ARG_Cordoba_UrbanRisk.dbf")

locality1$overall_sc <- as.numeric(locality1$overall_sc)

pal1 <- colorNumeric("Blues", domain = locality1$overall_sc)

labels <- sprintf(
  "<strong>%s</strong><br/> Score: %s</strong><br/>%s households",
  locality1$localidad, locality1$overall_sc, locality1$hogares
) %>% lapply(htmltools::HTML)

leaflet() %>% 
  setView(lng = -64.1888, lat = -31.4201, zoom = 6) %>%
  addTiles() %>%
  addCircleMarkers(
    data = locality1,
    lng = ~Long,
    lat = ~Lat,
    #radius = locality1$overall_sc,
    fillColor = ~pal1(locality1$overall_sc),
    stroke = FALSE, fillOpacity = 0.5,
    popup = ~locality1$overall_sc,
    label = labels
    #label = ~paste(locality1$overall_sc)
  )

