
# Load libraries
library(tidyr)
library(tidyverse)
library(magrittr)
library(dplyr)
library(plyr)
library(EpiEstim)
library(markdown)
library(shiny)
library(shinyjs)
library(knitr)
library(incidence)
library(leaflet)
library(rgdal)
options(shiny.maxRequestSize = 2650 * 1024 ^ 2)

setwd("/Users/carinapeng/PAHO : WHO/cordoba")

locality1 <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_new/ARG_Cordoba_UrbanRisk.shp")

locality1$overall_sc <- as.numeric(locality1$overall_sc)

pal1 <- colorNumeric("Blues", domain = locality1$overall_sc)

labels <- sprintf(
    "<strong>%s
    </strong><br/>Score: %s
    </strong><br/>%s households",
    locality1$localidad, locality1$overall_sc, locality1$hogares
) %>% lapply(htmltools::HTML)

# Define UI for data upload app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("My Template"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = TRUE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Checkbox if file has header ----
            checkboxInput("header", "Header", TRUE),
            
            # Input: Select separator ----
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ","),
            
            # Input: Select quotes ----
            radioButtons("quote", "Quote",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'"),
                         selected = '"'),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Select number of rows to display ----
            radioButtons("disp", "Display",
                         choices = c(Head = "head",
                                     All = "all"),
                         selected = "head")
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            leafletOutput(outputId = "mymap"),
            
            # Output: Data file ----
            tableOutput("contents")
            
        )
        
    )
)

