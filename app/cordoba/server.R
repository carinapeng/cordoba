
locality1 <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_new/ARG_Cordoba_UrbanRisk.shp")

locality1$overall_sc <- as.numeric(locality1$overall_sc)

pal1 <- colorNumeric("Blues", domain = locality1$overall_sc)

labels <- sprintf(
    "<strong>%s
    </strong><br/>Score: %s
    </strong><br/>%s households",
    locality1$localidad, locality1$overall_sc, locality1$hogares
) %>% lapply(htmltools::HTML)

# Define server logic to read selected file ----
server <- function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
        
        if(input$disp == "head") {
            return(head(df))
        }
        else {
            return(df)
        }
        
    })
    
    output$formattable <- DT::renderDataTable({
        as.datatable(scores_clean %>%
                         select(departamento, comuna, score, c_sum, e_sum, m_sum) %>%
                         formattable(
                             col.names = c("Departamento", "Comuna", "Puntuación", "Contexto", "Epidemiologicia", "Mitigación"),
                             list(
                                 score = color_tile("transparent", "lightpink"),
                                 c_sum = color_tile("transparent", "#fc8d59"),
                                 e_sum = normalize_bar("#67a9cf"),
                                 m_sum = color_tile("transparent", "#fc8d59"),
                                 comuna = formatter("span", style = ~ style(color = "black", font.weight = "bold")),
                                 align = c("l", "l", rep("r", NCOL(scores_clean) - 2)))))
    })
    
    output$mymap <- renderLeaflet(
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
    )
    
    
    
}


