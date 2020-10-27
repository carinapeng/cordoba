
library(janitor)
library(formattable)
library(magrittr)
library(dplyr)

setwd("/Users/carinapeng/PAHO : WHO/cordoba")

# Contexto results provided by Cordoba
contexto_results <- read.csv("data/ARG_contexto_values.csv")

contexto_results_clean <- contexto_results %>%
  row_to_names(row_number = 2) %>%
  clean_names()

# Scores after calculation
scores <- read.csv("data/cordoba_Results.csv")

scores_clean <- scores %>%
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

# Join datasets
scores_clean$comuna <- scores_clean$comuna %>%
  toupper()

contexto_results_clean1 <- contexto_results_clean %>%
  select(municipio_o_comuna, hogares, poblacion_total)

contexto_results_clean1$hogares <- as.numeric(gsub(",", "", contexto_results_clean1$hogares))
# contexto_results_clean1$hogares <- as.numeric(contexto_results_clean1$hogares)
contexto_results_clean1$poblacion_total <- as.numeric(gsub(",", "", contexto_results_clean1$poblacion))

joined <- inner_join(scores_clean, contexto_results_clean1,
                     by = c("comuna" = "municipio_o_comuna"))

df <- joined %>%
  select(departamento, comuna, score, hogares, poblacion_total)

# unit.scale = function(x) (x - min(x)) / (max(x) - min(x))

formatabble_df <- df %>%
  formattable(list(hogares = color_tile("white", "orange"),
                   poblacion_total = color_tile("#DeF7E9", "#71CA97"),
                   #`comuna` = formatter("span", style = ~ style(color = "grey", font.weight = "bold")), 
                   `score` = normalize_bar(color = "pink"),
              align = c("l", "l", rep("r", NCOL(df) - 2))
              ))



