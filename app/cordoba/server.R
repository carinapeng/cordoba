
setwd("/Users/carinapeng/PAHO : WHO/cordoba")

admin2 <- readOGR("/Users/carinapeng/Downloads/CORDOBA_adm2.shp")
locality <- readOGR("/Users/carinapeng/PAHO : WHO/cordoba/data/shapefile_new/ARG_Cordoba_UrbanRisk.shp")


# Define server logic to read selected file ----
server <- function(input, output) {
    
    df <- reactive({
        req(input$file1)
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
    })
    
    df_clean <- reactive({
        req(df())
        df_clean <- df() %>%
            clean_names() %>%
            select(departamento,
                   comuna,
                   contexto01,
                   contexto03,
                   contexto06,
                   contexto07,
                   contexto08,
                   contexto10,
                   contexto11,
                   contexto12,
                   contexto13,
                   contexto14,
                   contexto15,
                   contexto16,
                   contexto17,
                   contexto21,
                   contexto22,
                   epidemiologia1,
                   epidemiologia2,
                   epidemiologia3,
                   epidemiologia4,
                   epidemiologia5,
                   epidemiologia6,
                   epidemiologia8,
                   epidemiologia9,
                   epidemiologia10,
                   mitigacion02,
                   mitigacion03,
                   mitigacion04,
                   mitigacion07,
                   mitigacion08,
                   mitigacion09,
                   mitigacion10,
                   mitigacion11,
                   mitigacion12,
                   mitigacion13,
                   mitigacion14,
                   mitigacion15,
                   mitigacion16,
                   mitigacion17,
                   mitigacion18,
                   mitigacion19,
                   mitigacion21,
                   mitigacion22,
                   mitigacion23,
                   score
            )
        # Calculate sub-category sums
        cnames <- tolower(colnames(df_clean))
        df_clean1 <- df_clean %>%
            mutate(c_sum = rowSums(df_clean[, grep("contexto", cnames)])) %>%
            mutate(e_sum = rowSums(df_clean[, grep("epidemiologia", cnames)])) %>%
            mutate(m_sum = rowSums(df_clean[, grep("mitigacion", cnames)]))
        return(df_clean1)
    })
    
    
    output$formattable <- DT::renderDataTable({
        as.datatable(df_clean() %>%
                         select(departamento, comuna, score, c_sum, e_sum, m_sum) %>%
                         formattable(
                             col.names = c("Departamento", "Comuna", "Puntuación", "Contexto", "Epidemiologicia", "Mitigación"),
                             list(
                                 score = color_tile("transparent", "lightpink"),
                                 c_sum = color_tile("transparent", "#fc8d59"),
                                 e_sum = normalize_bar("#67a9cf"),
                                 m_sum = color_tile("transparent", "#fc8d59"),
                                 align = c("l", "l", rep("r", NCOL(df_clean()) - 2)))))
    })
    
    pal <- reactive({
        colorNumeric("Blues", domain = df_clean()$score)
    })
    
    labels <- reactive({
        sprintf("<strong>%s</strong><br/> Risk Assessment Score: %d</strong><br/>",
        df_clean()$comuna, df_clean()$score) %>%
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
                data = locality,
                lng = ~Long,
                lat = ~Lat,
                radius = ~log(locality$personas),
                fillColor = ~pal()(df_clean()$score),
                stroke = FALSE, fillOpacity = 0.5,
                popup = ~df_clean()$score,
                label = labels(),
                group = "Points"
            ) %>%
            addLayersControl(
                baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
                overlayGroups = c("Points", "Outline"),
                options = layersControlOptions(collapsed = FALSE)
            ))
    
    
}


