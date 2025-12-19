library(ggplot2)
library(readstata13)
library(AER)

# 2. Cargar los datos
df <- read.dta13("ahkjeboallvars.dta", nonint.factors = TRUE)

# 3. Preparación de variables con los nombres EXACTOS del archivo
# Usamos 'treat5group' que identifica los 5 grupos experimentales (T1-T5)
df$treatment <- as.factor(df$treat5group)

# 4. Establecer el grupo de referencia (Grupo 5: Couple)
# En este archivo, los niveles son numéricos ("1", "2", "3", "4", "5")
if ("5" %in% levels(df$treatment)) {
  df$treatment <- relevel(df$treatment, ref = "5")
}

# 5. Estimación del Modelo Tobit (Réplica Tabla 3)
# Ajustamos los nombres según la inspección del archivo:
# WTP, age, educationlevel, hhsizze, valuetotalassets1000
modelo_tobit <- tobit(WTP ~ treatment + age + educationlevel + hhsizze + valuetotalassets1000, 
                      left = 0, 
                      right = 150, 
                      data = df)

# 6. Mostrar resultados
summary(modelo_tobit)

# 1. Instalar y cargar marginaleffects
if (!require("marginaleffects")) install.packages("marginaleffects")
library(marginaleffects)

# 2. Calcular los efectos marginales promedio (AME)
# Especificamos el tipo "response" para obtener el efecto en ETB reales (WTP)
# y no en la variable latente.
ame_final <- avg_slopes(modelo_tobit, type = "response")

# 3. Ver los resultados
print(ame_final)


# Gráfico corregido usando el argumento 'by'
plot_slopes(modelo_tobit, variables = "treatment", by = "treatment") +
  theme_minimal() +
  labs(title = "Réplica Alem et al. (2023): Efectos Marginales de los Tratamientos",
       subtitle = "Referencia (Línea 0): Decisión en Pareja (T5)",
       y = "Diferencia en Disposición a Pagar (ETB)",
       x = "Grupos de Tratamiento") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  scale_x_discrete(labels = c("T1: Mujer/Indiv", "T2: Varón/Indiv", 
                              "T3: Mujer/Pareja", "T4: Varón/Pareja"))