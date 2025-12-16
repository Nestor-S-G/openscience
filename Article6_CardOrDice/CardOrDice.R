library(readxl)
library(dplyr)
library(MASS)

# 1. Leer el Excel (ya lo tienes hecho, pero lo dejo completo)
dat <- readxl::read_excel("allresultsIV.xlsx")

# 2. Construir variables tal como las describe el artículo
dat <- dat %>%
  mutate(
    # factor de muestra / lugar
    place_fac = factor(
      `place (3=Cambodia_classroom;; 1=Cambodia_farmers; 2= Germany_classroom, 4=Germany_laboratory)`,
      levels = c(1, 3, 2, 4),
      labels = c("Camb_farmers",
                 "Camb_students",
                 "Ger_class",
                 "Ger_lab")
    ),
    # recodificar 6 -> 0, como en la nota de la Tabla 5
    dice_rec  = ifelse(dice == 6, 0, dice),
    card_rec  = ifelse(card == 6, 0, card),
    dice_rec  = ordered(dice_rec),
    card_rec  = ordered(card_rec),
    # controles
    female           = gender1_W == 1,
    order_dice_first = `order1=W` == 0,
    education_years  = `education years`
  )

# 3. Ordered logit para la versión dado
m_dice <- MASS::polr(
  dice_rec ~ age + female + order_dice_first + place_fac,
  data = dat,
  Hess = TRUE
)

# 4. Ordered logit para la versión carta
m_card <- MASS::polr(
  card_rec ~ age + female + order_dice_first + place_fac,
  data = dat,
  Hess = TRUE
)

# 5. Resumen de resultados
summary(m_dice)
summary(m_card)

