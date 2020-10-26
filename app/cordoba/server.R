

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
    
    output$mymap <- renderLeaflet(
        leaflet() %>% 
            setView(lng = -64.1888, lat = -31.4201, zoom = 7) %>%
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


