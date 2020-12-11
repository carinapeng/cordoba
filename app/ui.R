
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
library(viridis)
library(DT)
library(plotly)
options(shiny.maxRequestSize = 2650 * 1024 ^ 2)


# Define UI for data upload app ----
ui <- fluidPage(
    
    # App title ----
    titlePanel("PAHO - Cordoba Risk Assessment Tool"),
    
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
            
            helpText("Toggle Settings for uploading CSV"),
            # Input: Checkbox if file has header ----
            checkboxInput("header", "Header", TRUE),
            
            # Input: Select separator ----
            radioButtons(
                "sep",
                "Separator",
                choices = c(
                    Comma = ",",
                    Semicolon = ";",
                    Tab = "\t"
                ),
                selected = ","
            ),
            
            # Input: Select quotes ----
            radioButtons(
                "quote",
                "Quote",
                choices = c(
                    None = "",
                    "Double Quote" = '"',
                    "Single Quote" = "'"
                ),
                selected = '"'
            ),
            
            # Horizontal line ----
            tags$hr(),
            helpText("Toggle Settings for viewing results"),
            
            # Input: Select number of rows to display ----
            radioButtons(
                "disp",
                "Display",
                choices = c(Head = "head",
                            All = "all",
                            Tail = "tail"),
                selected = "tail"
            )
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            tabsetPanel(
                tabPanel("Bienvenido",
                         includeMarkdown("www/welcome.md"),
                         tableOutput("test")
                         ),
                
                tabPanel("Resultados",
                         h3("Mapa"),
                         p("El mapa muestra los niveles de riesgo de diferentes barrios de Córdoba. Desplácese sobre cada localidad para
ver la puntuación general de la evaluación de riesgos, así como las subpuntuaciones por vulnerabilidad social,
epidemiología, mitigación y tamaño de la población."),
                         leafletOutput(outputId = "mymap"),
                         br(),
                         h3("Tablero interactivo"),
                         p("Esta tabla interactiva es otra forma de destacar los barrios de mayor riesgo, en comparación con el Índice de
Pobreza de la CEPAL. Navegue por la tabla para ver qué factores pueden contribuir más al aumento general del
riesgo."),
                    DT::dataTableOutput("formattable")),
                tabPanel("Fuentes de datos",
                         h3("Prevalencia de enfermedades crónicas"),
                         p("El análisis utiliza los datos a nivel nacional de enfermedades no transmisibles de la Carga Mundial de
Enfermedades. La OPS recomienda el", span(code("'24%'")), "para las Américas en su conjunto y el", span(code("'22%'")), "para los países de
América Latina como valores de umbral. Dado que el porcentaje de la población total de Argentina en mayor
riesgo es", 
                           span(code("'24,27%'")), "la herramienta utiliza este valor para la provincia de Córdoba. El análisis y más información
se pueden encontrar aquí:", span(a(href="https://paho-who.shinyapps.io/comorbidities/", "Herramienta de comorbilidades de ENT de la OPS"))),
                         br(),
                         h3("Tendencias de movilidad"),
                         p("Este análisis utiliza la diferencia porcentual entre el promedio de los últimos 7 días y el valor de referencia
promedio del 1 al 15 de marzo."),
                         tags$style(type='text/css', '#grocery_text {background-color: lightgreen}'),
                         tags$style(type='text/css', '#parks_text {background-color: lightpink}'),
                         tags$style(type='text/css', '#residential_text {background-color: lightpink}'),
                         tags$style(type='text/css', '#retail_text {background-color: lightpink}'),
                         tags$style(type='text/css', '#transit_text {background-color: lightpink}'),
                         tags$style(type='text/css', '#workplace_text {background-color: lightgreen}'),
                         verbatimTextOutput("grocery_text"),
                         verbatimTextOutput("parks_text"),
                         verbatimTextOutput("residential_text"),
                         verbatimTextOutput("retail_text"),
                         verbatimTextOutput("transit_text"),
                         verbatimTextOutput("workplace_text"),
                         br(),
                         plotlyOutput("mobility_plot")
            ),
            tabPanel("Reference",
                     withMathJax(includeMarkdown("www/reference.md")))
        )
        
    )
))

