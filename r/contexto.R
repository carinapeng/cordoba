

# Read data
geocode <- read.csv("./app/data/geocodes.csv")
results <- read.csv("./app/data/cordoba_results.csv")
# Subset to create a dataset with all contexto variables
contexto <- results %>%
  select(departamento, comuna, grep("contexto", names(results), value = TRUE))

# Clean data
contexto$comuna <- contexto$comuna %>%
  trimws() %>%
  toupper()

# Join by geocode
contexto_input <- contexto %>%
  inner_join(geocode1, by = c("comuna" = "localidad"))

saveRDS(contexto_input, file = "app/data/contexto.rds")

