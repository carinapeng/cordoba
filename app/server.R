
# Data that Cordoba will update:

# localidad_codigo: Geocode for each comuna
# link: Linking variable to the shapefile
# epidemiologia01: 7-day incidence rate per 100,000 persons
# epidemiologia02: Proportion of confirmed cases who are men
# epidemiologia03: Proportion of confirmed cases age 65 or older
# epidemiologia04: Reproductive rate (Rt)
# epidemiologia08: 7-day mortality rate per 100,000 persons
# epidemiologia09: Proportion of COVID-related deaths who are men
# epidemiologia10: Proportion of COVID-related deaths age 65 or older
# mitigacion02: Proportion of suspected cases who received test results within 72h
# mitigacion03: Proportion of healthcare workers infected with SARS-CoV-2
# mitigacion04: Proportion of confirmed/suspected cases who were hospitalized
# mitigacion07: Proportion of confirmed cases admitted within 48h of symptom onset
# mitigacion08: Proportion of confirmed cases admitted within 48h of symptom onset, and transferred to ICU
# mitigacion09: Proportion of confirmed cases admitted within 48h of symptom onset, who entered via the ER
# mitigacion10: Proportion of newborns who were born in a hospital in the last month
# mitigacion14: Proportion of new cases who were quarantined
# mitigacion15: Proportion of new cases who were self-isolating before diagnosis
# mitigacion16: Implementation of contact tracing
# mitigacion17: Number of new cases who were known contacts
# mitigacion18: Number of tested persons, over number of new cases (during the last week)



admin2 <- readOGR("data/admin2/CORDOBA_adm2.shp")
locality <- readOGR("data/shapefile_new/ARG_Cordoba_UrbanRisk.shp")
coord_df <- readRDS("data/coordinates.rds")
contexto <- readRDS("data/contexto.rds")
data1 <- read.csv("data/cordoba_results.csv")
last7mobility <- readRDS("data/last7mobility.rds")
last30mobility <- readRDS("data/last30mobility.rds")


# Define server logic to read selected file ----
server <- function(input, output) {
    
    df <- reactive({
        req(input$file1)
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
    })
    
    joined <- reactive({
        req(input$file1)
        contexto %>%
            join(df(), by = "CODIGO")
    })
    
    output$test <- renderTable(join_map())
    
    calculated_data <- reactive({
        req(input$file1)
        mutated <- joined() %>%
            # Since Argentina's percentage of people at risk is 24.2731%, which is greater than both
            # the Latin American average (22%) and the Americas as a whole (24%), assign score 1 with 
            # weights 2
            mutate(contexto07 = 2) %>%
            mutate(mepidemiologia01 = as.numeric(ifelse(epidemiologia01>=1,"1","0"))) %>%
            mutate(mepidemiologia02 = as.numeric(ifelse(epidemiologia02>=50,"1","0"))) %>%
            mutate(mepidemiologia03 = as.numeric(ifelse(epidemiologia03>=30,"1","0"))) %>%
            mutate(mepidemiologia04 = as.numeric(ifelse(epidemiologia04>=20,"1","0"))) %>%
            mutate(mepidemiologia08 = as.numeric(ifelse(epidemiologia08>=26,"1","0"))) %>%
            mutate(mepidemiologia09 = as.numeric(ifelse(epidemiologia09>=9,"1","0"))) %>%
            mutate(mepidemiologia10 = as.numeric(ifelse(epidemiologia10>=15,"1","0"))) %>%
            # Calculate score for mitigation variables
            mutate(mmitigacion02 = as.numeric(ifelse(mitigacion02>=80,"0","1"))) %>%
            mutate(mmitigacion03 = as.numeric(ifelse(mitigacion03>=20,"1","0"))) %>%
            mutate(mmitigacion04 = as.numeric(ifelse(mitigacion04>=20,"1","0"))) %>%
            mutate(mmitigacion07 = as.numeric(ifelse(mitigacion07>=80,"0","1"))) %>%
            mutate(mmitigacion08 = as.numeric(ifelse(mitigacion08>=80,"0","1"))) %>%
            mutate(mmitigacion09 = as.numeric(ifelse(mitigacion09>=80,"0","1"))) %>%
            mutate(mmitigacion10 = as.numeric(ifelse(mitigacion10>=80,"0","1"))) %>%
            # Miti 11-13 come from WHO PHSM
            # mutate(mmitigacion11 = ifelse(mitigacion11>=15,"1","0")) %>%
            # mutate(mmitigacion12 = ifelse(mitigacion12>=15,"1","0")) %>%
            # mutate(mmitigacion13 = ifelse(mitigacion13>=15,"1","0")) %>%
            mutate(mmitigacion14 = as.numeric(ifelse(mitigacion14>=80,"0",
                                          ifelse(mitigacion14 %in% 50:79, "1",
                                                 ifelse(mitigacion14 <= 50, "2", "0"))))) %>%
            mutate(mmitigacion15 = as.numeric(ifelse(mitigacion15>=80,"0",
                                          ifelse(mitigacion15 %in% 50:79, "1",
                                                 ifelse(mitigacion15 <= 50, "2", "0"))))) %>%
            mutate(mmitigacion16 = as.numeric(mitigacion16)) %>%
            mutate(mmitigacion17 = as.numeric(ifelse(mitigacion17>=80,"0",
                                          ifelse(mitigacion17 %in% 50:79, "1",
                                                 ifelse(mitigacion17 <= 50, "2", "0"))))) %>%
            # Check again
            mutate(mmitigacion18 = as.numeric(ifelse(mitigacion18>=50,"0","1"))) %>%
            mutate(mmitigacion19 = as.numeric(mitigacion19))
            # mutate(contexto21 = ifelse(last7mobility$retail_diff >0, "1", "0")) %>%
            # mutate(contexto22 = ifelse(last7mobility$transit_diff >0, "1", "0"))
        
        # Mitigacion 20, 21, 22 come from Google Mobility
        
        final <- mutated %>%
            select(departamento, comuna, CODIGO, poblacion, hogares, departamento_codigo, 
                   grep("contexto", names(mutated), value = TRUE),
                   grep("mepidemiologia", names(mutated), value = TRUE),
                   grep("mmitigacion", names(mutated), value = TRUE)
                   )
        
        
        # Calculate sub-category sums
        final1 <- final %>%
            mutate(c_sum = rowSums(.[ grep("contexto", names(.))])) %>%
            mutate(e_sum = rowSums(.[ grep("mepidemiologia", names(.))])) %>%
            mutate(m_sum = rowSums(.[grep("mmitigacion", names(.))])) %>%
            mutate(score = rowSums(.[(ncol(.)-2):ncol(.)]))
            # mutate(e_sum = rowSums(final[, grep("mepidemiologia", cnames)])) %>%
            # mutate(m_sum = rowSums(final[, grep("mmitigacion", cnames)]))
        return(final1)
        
    })
    
    
    output$mobility_plot <- renderPlotly({
        p1 <- last30mobility %>%
            ggplot(aes(x = date, y = percent_change, group = category, color = category)) +
            geom_line() +
            theme_minimal() +
            # theme(
            #     axis.title.x=element_blank(),
            #     axis.text.x=element_blank(),
            #     axis.ticks.x=element_blank()) +
            scale_color_viridis(discrete=TRUE, option = "viridis") +
            labs(color = "Category",
                 title = "Mobility Change of the Last 30 Days from March baseline (3/1-3/15)") +
            ylab("Percentage Change") +
            xlab("Date") 
        ggplotly(p1, tooltip = c("x", "y", "group"))
    })
    
    
    
    output$grocery_text <- renderText({
        paste("Grocery shopping trends:", last7mobility$grocery_diff[1], "%")
    })
    
    output$parks_text <- renderText({
        paste("Parks trends:", last7mobility$parks_diff[1], "%")
    })
    
    output$residential_text <- renderText({
        paste("Residential trends:", last7mobility$residential_diff[1], "%")
    })
    
    output$retail_text <- renderText({
        paste("Retail trends:", last7mobility$retail_diff[1], "%")
    })
    
    output$transit_text <- renderText({
        paste("Transit trends:", last7mobility$transit_diff[1], "%")
    })
    
    output$workplace_text <- renderText({
        paste("Workplace trends:", last7mobility$workplace_diff[1], "%")
    })
    
    output$formattable <- DT::renderDataTable({
        df_final <- calculated_data() %>%
            select(departamento, comuna, score, c_sum, e_sum, m_sum, poblacion, hogares) %>%
            dplyr::rename(Departamento = departamento,
               Comuna = comuna,
               Puntuación = score,
               Contexto = c_sum,
               Epidemiologicia = e_sum,
               Mitigación = m_sum,
               Poblacion = poblacion,
               Hogares = hogares
               )
        as.datatable(df_final %>%
                         formattable(
                             list(
                                 Puntuación = color_tile("transparent", "#FA7272"),
                                 Contexto = color_tile("transparent", "#fc8d59"),
                                 Epidemiologicia = color_tile("transparent", "#67a9cf"),
                                 Mitigación = color_tile("transparent", "#99d594"),
                                 Poblacion = color_tile("transparent", "lightblue"),
                                 Hogares = color_tile("transparent", "lightblue"),
                                 align = c("l", "l", rep("r", NCOL(calculated_data()) - 2)))))
    })
    
    
    join_map <- reactive({
        
        map_join <- calculated_data() %>%
            inner_join(coord_df, by = c("CODIGO" = "code"))
        
        # Convert dataframe to SpatialPointDataFrame
         # xy <- map_join[,c(1,2)]
         xy <- cbind(map_join$easting , map_join$northing)
         crs <- CRS("+init=epsg:28992")
         spdf <- SpatialPointsDataFrame(coords = xy, 
                                        data = map_join,
                                        proj4string = crs)
        return(spdf)
        
    })
    
    
    pal <- reactive({
        colorNumeric("Blues", domain = join_map()$score)
    })
    
    labels <- reactive({
        sprintf("<strong>%s</strong><br/> 
                Puntuación: %d</strong><br/> 
                Poblacion: %d</strong><br/>
                Hogares: %d</strong><br/>",
                join_map()$comuna, 
                join_map()$score,
                join_map()$poblacion,
                join_map()$hogares) %>%
            lapply(htmltools::HTML)
    })
    
    output$mymap <- renderLeaflet(
        
        leaflet() %>% 
            setView(lng = -64.1888, lat = -31.4201, zoom = 6) %>%
            addTiles(group = "OSM (default)") %>%
            addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
            addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
            addPolygons(data = admin2, 
                        group = "Outline", 
                        color = "#444444", 
                        weight = 1, 
                        smoothFactor = 0.5,
                        opacity = 1, 
                        fillOpacity = 0.1) %>%
            addCircleMarkers(
                data = join_map(),
                lng = ~easting,
                lat = ~northing,
                radius = ~log(join_map()$poblacion),
                fillColor = ~pal()(join_map()$score),
                stroke = FALSE, fillOpacity = 0.5,
                popup = ~join_map()$score,
                label = labels(),
                group = "Points"
            ) %>%
            addLayersControl(
                baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
                overlayGroups = c("Points", "Outline"),
                options = layersControlOptions(collapsed = FALSE)
            ))
    
    
}


