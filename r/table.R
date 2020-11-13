
library(janitor)
library(formattable)
library(magrittr)
library(dplyr)
library(tidyr)

setwd("/Users/carinapeng/PAHO : WHO/cordoba")

# Contexto results provided by Cordoba
contexto_results <- read.csv("data/ARG_contexto_values.csv")

# Clean data
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

# Calculate sub-category sums
cnames <- tolower(colnames(scores_clean))
scores_clean <- scores_clean %>%
  mutate(c_sum = rowSums(scores_clean[, grep("contexto", cnames)])) %>%
  mutate(e_sum = rowSums(scores_clean[, grep("epidemiologia", cnames)])) %>%
  mutate(m_sum = rowSums(scores_clean[, grep("mitigacion", cnames)]))


# Join datasets
# scores_clean$comuna <- scores_clean$comuna %>%
#   toupper()
# 
# joined <- inner_join(scores_clean, contexto_results_clean1,
#                      by = c("comuna" = "municipio_o_comuna"))
# 
# df <- joined %>%
#   select(departamento, comuna, score, hogares, poblacion_total)
# 
# df$hogares <- gsub(",","",df$hogares)
# df$hogares <- as.numeric(df$hogares)
# 
# 
# df$hogares <- comma(df$hogares, format = "f",
#       big.mark = ",")

table <- scores_clean %>%
  select(departamento, comuna, score, c_sum, e_sum, m_sum) %>%
  formattable(list(
    score = normalize_bar(color = "pink"),
    c_sum = color_tile("transparent", "#fc8d59"),
    e_sum = color_tile("transparent", "#67a9cf"),
    m_sum = color_tile("transparent", "#fc8d59"),
    comuna = formatter("span", style = ~ style(color = "black", font.weight = "bold")),
    align = c("l", "l", rep("r", NCOL(scores_clean) - 2))))

table





