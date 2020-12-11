
library(magrittr)
library(dplyr)
library(xlsx)
library(tidyr)

# Read data
results <- read.xlsx("/Users/carinapeng/Downloads/results_geo.xlsx", 1)
raw <- read.xlsx("/Users/carinapeng/Downloads/raw_geo.xlsx",1)

# Omit rural zone (NA CODIGO)
results_dropna <- results %>% 
  drop_na(CODIGO)

raw_dropna <- raw %>%
  drop_na(CODIGO)

# Subset to create a dataset with all contexto variables
contexto <- results_dropna %>%
  select(departamento, comuna, CODIGO, grep("contexto", names(results_dropna), value = TRUE))

# Add population and household data to contexto
pop_house <- raw %>%
  select(CODIGO, poblacion, hogares)

contexto <- contexto %>%
  left_join(pop_house, by = "CODIGO")

saveRDS(contexto, file = "app/data/contexto.rds")


# ----------------

raw_input <- raw_dropna %>%
  select(departamento_codigo, CODIGO, grep("epidemiologia", names(raw_dropna), value = TRUE), grep("mitigacion", names(raw_dropna), value = TRUE))

write.csv(raw_input, "app/data/raw_input.csv")


