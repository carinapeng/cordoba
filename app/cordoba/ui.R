
# Load libraries
library(tidyr)
library(tidyverse)
library(janitor)
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
library(formattable)
library(DT)
options(shiny.maxRequestSize = 2650 * 1024 ^ 2)

setwd("/Users/carinapeng/PAHO : WHO/cordoba")


# Define UI for data upload app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("Cordoba Shiny App Version 2"),
    
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
            tags$hr()
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            tabsetPanel(
                tabPanel("Welcome",
                         includeMarkdown("app/welcome.md")),
                tabPanel("Table",
                    DT::dataTableOutput("formattable")),
                tabPanel("Map",
                    leafletOutput(outputId = "mymap"))
            )
        )
        
    )
)

