# ============================================================
# Multinomial Logit Model - Fashion DCE Analysis
# Statistical Applications Exam | Winter Term 2025/2026
# Apollo package implementation
# ============================================================

# ============================================================
# 0. PACKAGES
# ============================================================

library(apollo)
library(dplyr)
library(tidyr)
library(ggplot2)


# ============================================================
# 1. LOAD & INSPECT DATA
# ============================================================

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
load("dce_fashion2.RData")

print(head(dce_fashion2))
colnames(dce_fashion2)
nrow(dce_fashion2)                                   # 1973
identical(dce_fashion2$block, dce_fashion2$DCEQ)     # TRUE
identical(dce_fashion2$gender, dce_fashion2$gender_group) # FALSE -> use gender
identical(dce_fashion2$age, dce_fashion2$age2)        # FALSE -> use age2

# Variables used:
#
# Choice:            choice (1 = Store 1, 2 = Store 2, 3 = Opt-out)
#
# Individual-level:  id, gender, age2, HGr,
#                    Mcloth, spendingclothes, MGE, GEGE, SecHand, SecHand2,
#                    Eink_num, block
#
# Alt 1 attributes:  price1, shipping_time1, social_sust1, eco_sust1
#                    + dummies: headquarter1_Ger/EU/US/As
#                               distribution1_online/stationär/hybrid
#                               marketing1_min/mod/max
#
# Alt 2 attributes:  price2, shipping_time2, social_sust2, eco_sust2
#                    + dummies: headquarter2_Ger/EU/US/As
#                               distribution2_online/stationär/hybrid
#                               marketing2_min/mod/max
#
# Alt 3:             Opt-out ("keine der genannten Optionen") -> Utility fixed to 0


# ============================================================
# 2. DATA PREPARATION
# ============================================================

# -- 2.1 Select relevant variables ---------------------------

d <- dce_fashion2 %>%
  select(
    # Identifiers & individual-level
    choice_set, id, gender, HGr, Mcloth, spendingclothes,
    MGE, GEGE, SecHand, SecHand2, DCEQ, age2, Eink_num, Eink_pro_Kopf,
    
    # Choice variable
    choice,
    
    # Alternative 1 attributes
    price1, shipping_time1, social_sust1, eco_sust1,
    
    # Alternative 2 attributes
    price2, shipping_time2, social_sust2, eco_sust2,
    
    # Alternative 3 attributes (unused — utility fixed to 0)
    price3, shipping_time3, social_sust3, eco_sust3,
    
    # Headquarter dummies
    headquarter1_Ger, headquarter1_EU, headquarter1_US, headquarter1_As,
    headquarter2_Ger, headquarter2_EU, headquarter2_US, headquarter2_As,
    
    # Distribution dummies
    distribution1_online, `distribution1_stationär`, distribution1_hybrid,
    distribution2_online, `distribution2_stationär`, distribution2_hybrid,
    
    # Marketing dummies
    marketing1_min, marketing1_mod, marketing1_max,
    marketing2_min, marketing2_mod, marketing2_max
  )

# -- 2.2 Check choice distribution ---------------------------

cat("\n--- Choice distribution ---\n")
print(table(d$choice))
print(prop.table(table(d$choice)))

# -- 2.3 Remove individuals with any missing values ----------

ids_with_na <- d %>%
  filter(if_any(everything(), ~ is.na(.))) %>%
  pull(id) %>%
  unique()

cat("IDs with at least one NA:", length(ids_with_na), "\n")
cat("Rows to be removed:", sum(d$id %in% ids_with_na), "\n")

d <- d %>%
  filter(!id %in% ids_with_na)

cat("Rows remaining:", nrow(d), "\n")
cat("Individuals remaining:", n_distinct(d$id), "\n")

# Verify no NAs remain
stopifnot(colSums(is.na(d)) == 0)

# Check panel structure: should show 6 rows per individual
d %>% count(id) %>% summary()


# ============================================================
# 3. APOLLO MODEL SETUP
# ============================================================

# -- 3.1 Initialise Apollo -----------------------------------

apollo_initialise()

database <- d

apollo_control <- list(
  modelName       = "MNL_fashion_DCE",
  modelDescr      = "Multinomial Logit - Fashion Store Choice",
  indivID         = "id",
  outputDirectory = "output/",
  nCores          = 8,
  panelData       = TRUE   # 6 choice tasks per respondent
)

# -- 3.2 Starting values -------------------------------------

apollo_beta <- c(
  
  # Alternative-Specific Constants (Alt 3 = opt-out is reference -> no ASC_3)
  asc_1 = 0,
  asc_2 = 0,
  
  # Store attributes (generic across Alt 1 & Alt 2)
  b_price         = 0,
  b_shipping_time = 0,
  b_social_sust   = 0,
  b_eco_sust      = 0,
  
  # Headquarter dummies (reference = Germany)
  b_hq_EU = 0,
  b_hq_US = 0,
  b_hq_As = 0,
  
  # Distribution dummies (reference = stationary retail)
  b_dist_online = 0,
  b_dist_hybrid = 0,
  
  # Marketing dummies (reference = minimal)
  b_marketing_mod = 0,
  b_marketing_max = 0,
  
  # Individual-level interactions with ASCs
  # One beta per individual variable per non-reference alternative
  b_gender_1          = 0,   b_gender_2          = 0,
  b_age2_1            = 0,   b_age2_2            = 0,
  b_HGr_1             = 0,   b_HGr_2             = 0,
  b_Mcloth_1          = 0,   b_Mcloth_2          = 0,
  b_spendingclothes_1 = 0,   b_spendingclothes_2 = 0,
  b_MGE_1             = 0,   b_MGE_2             = 0,
  b_GEGE_1            = 0,   b_GEGE_2            = 0,
  b_SecHand_1         = 0,   b_SecHand_2         = 0,
  b_SecHand2_1        = 0,   b_SecHand2_2        = 0,
  b_Eink_num_1        = 0,   b_Eink_num_2        = 0
)

# -- 3.3 Fixed parameters ------------------------------------

apollo_fixed <- c()

# -- 3.4 Validate inputs -------------------------------------

apollo_inputs <- apollo_validateInputs()

# -- 3.5 Probability function --------------------------------

apollo_probabilities <- function(apollo_beta, apollo_inputs, functionality = "estimate") {
  
  apollo_attach(apollo_beta, apollo_inputs)
  on.exit(apollo_detach(apollo_beta, apollo_inputs))
  
  P <- list()
  V <- list()
  
  # Alt 1: Store 1
  V[["alt1"]] <-
    asc_1 +
    b_gender_1          * gender          +
    b_age2_1            * age2            +
    b_HGr_1             * HGr             +
    b_Mcloth_1          * Mcloth          +
    b_spendingclothes_1 * spendingclothes +
    b_MGE_1             * MGE             +
    b_GEGE_1            * GEGE            +
    b_SecHand_1         * SecHand         +
    b_SecHand2_1        * SecHand2        +
    b_Eink_num_1        * Eink_num        +
    b_price             * price1          +
    b_shipping_time     * shipping_time1  +
    b_social_sust       * social_sust1    +
    b_eco_sust          * eco_sust1       +
    b_hq_EU             * headquarter1_EU +
    b_hq_US             * headquarter1_US +
    b_hq_As             * headquarter1_As +
    b_dist_online       * distribution1_online +
    b_dist_hybrid       * distribution1_hybrid +
    b_marketing_mod     * marketing1_mod  +
    b_marketing_max     * marketing1_max
  
  # Alt 2: Store 2
  V[["alt2"]] <-
    asc_2 +
    b_gender_2          * gender          +
    b_age2_2            * age2            +
    b_HGr_2             * HGr             +
    b_Mcloth_2          * Mcloth          +
    b_spendingclothes_2 * spendingclothes +
    b_MGE_2             * MGE             +
    b_GEGE_2            * GEGE            +
    b_SecHand_2         * SecHand         +
    b_SecHand2_2        * SecHand2        +
    b_Eink_num_2        * Eink_num        +
    b_price             * price2          +
    b_shipping_time     * shipping_time2  +
    b_social_sust       * social_sust2    +
    b_eco_sust          * eco_sust2       +
    b_hq_EU             * headquarter2_EU +
    b_hq_US             * headquarter2_US +
    b_hq_As             * headquarter2_As +
    b_dist_online       * distribution2_online +
    b_dist_hybrid       * distribution2_hybrid +
    b_marketing_mod     * marketing2_mod  +
    b_marketing_max     * marketing2_max
  
  # Alt 3: Opt-out — utility set to zero
  V[["alt3"]] <- 0
  
  # MNL probabilities
  mnl_settings <- list(
    alternatives = c(alt1 = 1, alt2 = 2, alt3 = 3),
    avail        = list(alt1 = 1, alt2 = 1, alt3 = 1),
    choiceVar    = choice,
    utilities    = V
  )
  
  P[["model"]] <- apollo_mnl(mnl_settings, functionality)
  P <- apollo_panelProd(P, apollo_inputs, functionality)
  P <- apollo_prepareProb(P, apollo_inputs, functionality)
  
  return(P)
}


# ============================================================
# 4. MODEL ESTIMATION
# ============================================================

database      <- d          # ensure full dataset
apollo_fixed  <- c()
apollo_inputs <- apollo_validateInputs()

model <- apollo_estimate(apollo_beta, apollo_fixed, apollo_probabilities, apollo_inputs)
apollo_modelOutput(model, modelOutput_settings = list(printPVal = TRUE))

model_full <- model


# ============================================================
# 5. PRICE ELASTICITY
# ============================================================
# NOTE: Run before IIA test to avoid issues — IIA test modifies database and apollo_inputs

# -- 5.1 Reset to full data ----------------------------------

database      <- d
apollo_inputs <- apollo_validateInputs()

# -- 5.2 Base predictions ------------------------------------

predictions_base <- apollo_prediction(model, apollo_probabilities, apollo_inputs)

# -- 5.3 Scenario A: Shock Store 2 price only (+1%) ----------

database$price2 <- 1.01 * database$price2
apollo_inputs    <- apollo_validateInputs()
predictions_new  <- apollo_prediction(model, apollo_probabilities, apollo_inputs)

change_store2 <- (predictions_new - predictions_base) / predictions_base
alt_cols      <- grep("^alt", colnames(change_store2), value = TRUE)
change_store2 <- change_store2[, alt_cols]

change_store2 %>%
  pivot_longer(cols = all_of(alt_cols), names_to = "Alternative", values_to = "Change") %>%
  mutate(Alternative = recode(Alternative,
                              "alt1" = "Store 1", "alt2" = "Store 2", "alt3" = "Opt-out")) %>%
  ggplot(aes(y = Change, x = Alternative, fill = Alternative)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("#aaaaaa", "#e77d51", "#5b8db8")) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title    = "Change in Predicted Choice Probabilities",
    subtitle = "Response to 1% price increase in Store 2 only",
    x        = NULL,
    y        = "% Change in Predicted Probability"
  ) +
  theme_minimal() +
  theme(
    plot.title       = element_text(size = 18, face = "bold"),
    plot.subtitle    = element_text(size = 14, color = "grey40"),
    axis.text.x      = element_text(size = 15),
    axis.text.y      = element_text(size = 14),
    axis.title.y     = element_text(size = 14),
    legend.position  = "none",
    panel.grid.minor = element_blank()
  )

# Reset Store 2 price
database$price2 <- database$price2 / 1.01
apollo_inputs   <- apollo_validateInputs()

# -- 5.4 Scenario B: Shock both stores (+1%) -----------------

database$price1 <- 1.01 * database$price1    # Modify changes for different plot
database$price2 <- 1.01 * database$price2    # Note line below that resets change in database
apollo_inputs   <- apollo_validateInputs()
predictions_new <- apollo_prediction(model, apollo_probabilities, apollo_inputs)

change_both <- (predictions_new - predictions_base) / predictions_base
change_both <- change_both[, alt_cols]

change_both %>%
  pivot_longer(cols = all_of(alt_cols), names_to = "Alternative", values_to = "Change") %>%
  mutate(Alternative = recode(Alternative,
                              "alt1" = "Store 1", "alt2" = "Store 2", "alt3" = "Opt-out")) %>%
  ggplot(aes(y = Change, x = Alternative, fill = Alternative)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("#aaaaaa", "#e77d51", "#5b8db8")) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title    = "Change in Predicted Choice Probabilities",
    subtitle = "Response to 1% price increase across both stores",
    x        = NULL,
    y        = "% Change in Predicted Probability"
  ) +
  theme_minimal() +
  theme(
    plot.title       = element_text(size = 18, face = "bold"),
    plot.subtitle    = element_text(size = 14, color = "grey40"),
    axis.text.x      = element_text(size = 15),
    axis.text.y      = element_text(size = 14),
    axis.title.y     = element_text(size = 14),
    legend.position  = "none",
    panel.grid.minor = element_blank()
  )

# Reset both prices
database$price1 <- database$price1 / 1.01   # Don't forget to change back here if modified above
database$price2 <- database$price2 / 1.01
apollo_inputs   <- apollo_validateInputs()


# ============================================================
# 6. Hausman-McFadden test IIA TEST (Likelihood Ratio)
# ============================================================

# -- 6.1 Prepare restricted dataset (exclude Alt 3) ----------

d_no3 <- d %>% filter(choice != 3)

# -- 6.2 Estimate restricted model ---------------------------

apollo_initialise()

database <- d_no3

apollo_control <- list(
  modelName       = "MNL_fashion_DCE_restricted",
  modelDescr      = "MNL Restricted - No Opt-out (IIA Test)",
  indivID         = "id",
  outputDirectory = "output/",
  nCores          = 8,
  panelData       = TRUE
)

apollo_fixed  <- c("asc_1")
apollo_inputs <- apollo_validateInputs()

model_no3 <- apollo_estimate(apollo_beta, apollo_fixed, apollo_probabilities, apollo_inputs)

# -- 6.3 Manual LL computation on restricted data ------------

dr     <- d_no3
beta_f <- model_full$estimate
beta_r <- model_no3$estimate

compute_LL <- function(beta, dr) {
  
  V1 <- beta["asc_1"] +
    beta["b_gender_1"]          * dr$gender          +
    beta["b_age2_1"]            * dr$age2            +
    beta["b_HGr_1"]             * dr$HGr             +
    beta["b_Mcloth_1"]          * dr$Mcloth          +
    beta["b_spendingclothes_1"] * dr$spendingclothes +
    beta["b_MGE_1"]             * dr$MGE             +
    beta["b_GEGE_1"]            * dr$GEGE            +
    beta["b_SecHand_1"]         * dr$SecHand         +
    beta["b_SecHand2_1"]        * dr$SecHand2        +
    beta["b_Eink_num_1"]        * dr$Eink_num        +
    beta["b_price"]             * dr$price1          +
    beta["b_shipping_time"]     * dr$shipping_time1  +
    beta["b_social_sust"]       * dr$social_sust1    +
    beta["b_eco_sust"]          * dr$eco_sust1       +
    beta["b_hq_EU"]             * dr$headquarter1_EU +
    beta["b_hq_US"]             * dr$headquarter1_US +
    beta["b_hq_As"]             * dr$headquarter1_As +
    beta["b_dist_online"]       * dr$distribution1_online +
    beta["b_dist_hybrid"]       * dr$distribution1_hybrid +
    beta["b_marketing_mod"]     * dr$marketing1_mod  +
    beta["b_marketing_max"]     * dr$marketing1_max
  
  V2 <- beta["asc_2"] +
    beta["b_gender_2"]          * dr$gender          +
    beta["b_age2_2"]            * dr$age2            +
    beta["b_HGr_2"]             * dr$HGr             +
    beta["b_Mcloth_2"]          * dr$Mcloth          +
    beta["b_spendingclothes_2"] * dr$spendingclothes +
    beta["b_MGE_2"]             * dr$MGE             +
    beta["b_GEGE_2"]            * dr$GEGE            +
    beta["b_SecHand_2"]         * dr$SecHand         +
    beta["b_SecHand2_2"]        * dr$SecHand2        +
    beta["b_Eink_num_2"]        * dr$Eink_num        +
    beta["b_price"]             * dr$price2          +
    beta["b_shipping_time"]     * dr$shipping_time2  +
    beta["b_social_sust"]       * dr$social_sust2    +
    beta["b_eco_sust"]          * dr$eco_sust2       +
    beta["b_hq_EU"]             * dr$headquarter2_EU +
    beta["b_hq_US"]             * dr$headquarter2_US +
    beta["b_hq_As"]             * dr$headquarter2_As +
    beta["b_dist_online"]       * dr$distribution2_online +
    beta["b_dist_hybrid"]       * dr$distribution2_hybrid +
    beta["b_marketing_mod"]     * dr$marketing2_mod  +
    beta["b_marketing_max"]     * dr$marketing2_max
  
  denom  <- exp(V1) + exp(V2)
  prob_1 <- exp(V1) / denom
  prob_2 <- exp(V2) / denom
  
  LL <- sum(ifelse(dr$choice == 1, log(prob_1), log(prob_2)))
  return(LL)
}

# -- 6.4 Compute test statistic ------------------------------

LL_full_betas <- compute_LL(beta_f, dr)
LL_rest_betas <- compute_LL(beta_r, dr)

chi_sq <- -2 * (LL_full_betas - LL_rest_betas)
df     <- 1
p_val  <- pchisq(chi_sq, df = df, lower.tail = FALSE)

cat("\n========================================\n")
cat("  Hausman-McFadden IIA Test (LL-based)\n")
cat("  Removed alternative: Alt 3 (Opt-out)\n")
cat("========================================\n")
cat(sprintf("  LL full betas on restricted data: %.4f\n", LL_full_betas))
cat(sprintf("  LL restricted betas:              %.4f\n", LL_rest_betas))
cat(sprintf("  Chi-squared:                      %.4f\n", chi_sq))
cat(sprintf("  Degrees of freedom:               %d\n",   df))
cat(sprintf("  p-value:                          %.4f\n", p_val))
cat("----------------------------------------\n")
if (chi_sq < 0) {
  cat("  Result: Negative statistic -> IIA HOLDS\n")
} else if (p_val > 0.05) {
  cat("  Result: Fail to reject H0 -> IIA HOLDS\n")
} else {
  cat("  Result: Reject H0 -> IIA VIOLATED\n")
}
cat("========================================\n")


# ============================================================
# 7. WILLINGNESS TO PAY (Delta Method)
# ============================================================

# -- 7.1 Restore full model context --------------------------

database      <- d
apollo_inputs <- apollo_validateInputs()

# -- 7.2 WTP expressions -------------------------------------

deltaMethod_settings <- list(
  expression = c(
    WTP_shipping_time = "-b_shipping_time/b_price",
    WTP_social_sust   = "-b_social_sust/b_price",
    WTP_eco_sust      = "-b_eco_sust/b_price",
    WTP_hq_EU         = "-b_hq_EU/b_price",
    WTP_hq_US         = "-b_hq_US/b_price",
    WTP_hq_As         = "-b_hq_As/b_price",
    WTP_dist_online   = "-b_dist_online/b_price",
    WTP_dist_hybrid   = "-b_dist_hybrid/b_price",
    WTP_marketing_mod = "-b_marketing_mod/b_price",
    WTP_marketing_max = "-b_marketing_max/b_price",
    WTP_store1        = "-asc_1/b_price",
    WTP_store2        = "-asc_2/b_price"
  )
)

wtp_results <- apollo_deltaMethod(model, deltaMethod_settings)

cat("═══════════════════════════════════════════════════════\n")
cat("WILLINGNESS TO PAY (€) — Delta Method\n")
cat("═══════════════════════════════════════════════════════\n")
print(wtp_results)

# -- 7.3 WTP plots -------------------------------------------

col <- "#e77d51"

wtp_for_plot <- data.frame(
  Attribute = c(
    "Shipping Time\n(per additional day)",
    "Social Sustainability",
    "Eco Sustainability",
    "EU vs Germany",
    "US vs Germany",
    "Asia vs Germany",
    "Online\n(vs In-Store)",
    "Hybrid\n(vs In-Store)",
    "Moderate\n(vs Minimal)",
    "Maximum\n(vs Minimal)"
  ),
  WTP   = wtp_results[1:10, "Value"],
  SE    = wtp_results[1:10, "s.e."],
  Group = c(
    "Shipping Time",
    "Sustainability", "Sustainability",
    "Headquarter", "Headquarter", "Headquarter",
    "Distribution", "Distribution",
    "Marketing", "Marketing"
  )
)

wtp_for_plot$Lower <- wtp_for_plot$WTP - 1.96 * wtp_for_plot$SE
wtp_for_plot$Upper <- wtp_for_plot$WTP + 1.96 * wtp_for_plot$SE

wtp_theme <- theme_minimal() +
  theme(
    plot.title         = element_text(size = 16, face = "bold"),
    plot.subtitle      = element_text(size = 13, color = "grey40"),
    axis.text.y        = element_text(size = 13),
    axis.text.x        = element_text(size = 12),
    axis.title.x       = element_text(size = 13),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank()
  )

plot_wtp <- function(data, title, subtitle) {
  max_abs <- max(abs(c(data$Lower, data$Upper)), na.rm = TRUE) * 1.15
  ggplot(data, aes(x = reorder(Attribute, WTP), y = WTP)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60", linewidth = 0.4) +
    geom_errorbar(aes(ymin = Lower, ymax = Upper),
                  width = 0.15, color = col, linewidth = 0.7) +
    geom_point(size = 4, color = col) +
    coord_flip() +
    scale_y_continuous(limits = c(-max_abs, max_abs)) +
    labs(title = title, subtitle = subtitle, x = NULL, y = "WTP (€)") +
    wtp_theme
}

print(plot_wtp(
  subset(wtp_for_plot, Group == "Shipping Time"),
  title    = "WTP – Shipping Time",
  subtitle = "€ per additional day of shipping time"
))

print(plot_wtp(
  subset(wtp_for_plot, Group == "Sustainability"),
  title    = "WTP – Sustainability",
  subtitle = "Reference: No sustainability commitment"
))

print(plot_wtp(
  subset(wtp_for_plot, Group == "Headquarter"),
  title    = "WTP – Headquarter Location",
  subtitle = "Reference: Germany"
))

print(plot_wtp(
  subset(wtp_for_plot, Group == "Distribution"),
  title    = "WTP – Distribution Channel",
  subtitle = "Reference: In-Store"
))

print(plot_wtp(
  subset(wtp_for_plot, Group == "Marketing"),
  title    = "WTP – Marketing Intensity",
  subtitle = "Reference: Minimal marketing"
))


# ============================================================
# 8. RELATIVE ATTRIBUTE IMPORTANCE
# ============================================================

coefs <- model$estimate

# Utility range for continuous attributes
u_r_price    <- coefs["b_price"] * (min(c(d$price1, d$price2)) - max(c(d$price1, d$price2)))
u_r_shipping <- coefs["b_shipping_time"] * (min(c(d$shipping_time1, d$shipping_time2)) -
                                              max(c(d$shipping_time1, d$shipping_time2)))
u_r_social   <- coefs["b_social_sust"] * (max(c(d$social_sust1, d$social_sust2)) -
                                            min(c(d$social_sust1, d$social_sust2)))
u_r_eco      <- coefs["b_eco_sust"] * (max(c(d$eco_sust1, d$eco_sust2)) -
                                         min(c(d$eco_sust1, d$eco_sust2)))

# Utility range for categorical attributes (reference level = 0)
hq_coefs   <- c(0, coefs["b_hq_EU"], coefs["b_hq_US"], coefs["b_hq_As"])
dist_coefs <- c(0, coefs["b_dist_online"], coefs["b_dist_hybrid"])
mkt_coefs  <- c(0, coefs["b_marketing_mod"], coefs["b_marketing_max"])

u_r_hq   <- max(hq_coefs) - min(hq_coefs)
u_r_dist <- max(dist_coefs) - min(dist_coefs)
u_r_mkt  <- max(mkt_coefs) - min(mkt_coefs)

importance_plot <- data.frame(
  Attribute = c("Price", "Shipping Time", "Social Sustainability",
                "Ecological Sustainability", "Headquarter Location",
                "Distribution Channel", "Marketing Intensity"),
  Utility_Range = c(u_r_price, u_r_shipping, u_r_social, u_r_eco,
                    u_r_hq, u_r_dist, u_r_mkt)
) %>%
  mutate(
    Percentage = 100 * abs(Utility_Range) / sum(abs(Utility_Range)),
    Attribute  = factor(Attribute, levels = Attribute[order(Percentage)])
  )

cat("\n═══════════════════════════════════════════════════════\n")
cat("RELATIVE ATTRIBUTE IMPORTANCE\n")
cat("═══════════════════════════════════════════════════════\n")
print(importance_plot[order(-importance_plot$Percentage), ], row.names = FALSE)

ggplot(importance_plot, aes(x = Attribute, y = Percentage)) +
  geom_col(fill = "#e77d51") +
  coord_flip() +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")),
            hjust = -0.1, size = 5, fontface = "bold") +
  scale_y_continuous(limits = c(0, max(importance_plot$Percentage) + 8)) +
  labs(
    title    = "Relative Attribute Importance",
    subtitle = "Share of total utility variation | Based on utility range",
    x        = NULL,
    y        = "Relative Importance (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title         = element_text(size = 18, face = "bold"),
    plot.subtitle      = element_text(size = 14, color = "grey40"),
    axis.text.y        = element_text(size = 14),
    axis.text.x        = element_text(size = 13),
    axis.title.x       = element_text(size = 13),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank()
  )


# ============================================================
# 9. ODDS RATIOS — INDIVIDUAL CHARACTERISTICS
# ============================================================

ind_vars <- c(
  "b_gender_1", "b_gender_2",
  "b_age2_1",   "b_age2_2",
  "b_HGr_1",    "b_HGr_2",
  "b_Mcloth_1", "b_Mcloth_2",
  "b_spendingclothes_1", "b_spendingclothes_2",
  "b_MGE_1",    "b_MGE_2",
  "b_GEGE_1",   "b_GEGE_2",
  "b_SecHand_1","b_SecHand_2",
  "b_SecHand2_1","b_SecHand2_2",
  "b_Eink_num_1","b_Eink_num_2"
)

betas  <- model$estimate
rob_se <- sqrt(diag(model$robvarcov))

odds_df <- data.frame(
  Parameter = ind_vars,
  Estimate  = betas[ind_vars],
  SE        = rob_se[ind_vars]
) %>%
  mutate(
    Odds_Ratio  = exp(Estimate),
    Pct_Change  = (exp(Estimate) - 1) * 100,
    OR_lower    = exp(Estimate - 1.96 * SE),
    OR_upper    = exp(Estimate + 1.96 * SE),
    t_stat      = Estimate / SE,
    p_value     = 2 * pnorm(-abs(t_stat)),
    Sig         = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE           ~ ""
    ),
    Alternative = ifelse(grepl("_1$", Parameter), "Store 1 vs Opt-out", "Store 2 vs Opt-out"),
    Variable    = gsub("b_|_1$|_2$", "", Parameter)
  ) %>%
  select(Variable, Alternative, Odds_Ratio, Pct_Change, OR_lower, OR_upper, p_value, Sig) %>%
  arrange(p_value)

cat("═══════════════════════════════════════════════════════════\n")
cat("  Odds Ratios — Individual Characteristics\n")
cat("  OR > 1 = increases odds of choosing store vs opt-out\n")
cat("  OR < 1 = decreases odds of choosing store vs opt-out\n")
cat("═══════════════════════════════════════════════════════════\n")
print(odds_df, digits = 3, row.names = FALSE)

# -- 9.1 Plot: Age -------------------------------------------

age_df <- odds_df %>%
  filter(Variable == "age2") %>%
  mutate(Pct_label = sprintf("%+.1f%%", Pct_Change))

p_age <- ggplot(age_df, aes(x = Alternative, y = Pct_Change, color = Alternative)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_errorbar(aes(ymin = (OR_lower - 1) * 100, ymax = (OR_upper - 1) * 100),
                width = 0.1, linewidth = 0.7) +
  geom_point(size = 5) +
  geom_text(aes(label = Pct_label), hjust = -0.4, size = 6, fontface = "bold") +
  scale_color_manual(values = c("#e77d51", "#5b8db8")) +
  scale_y_continuous(labels = function(x) paste0(x, "%"),
                     expand = expansion(mult = c(0.3, 0.3))) +
  labs(
    title    = "Effect of Age on Store Choice",
    subtitle = "% change in odds per additional year of age\nvs opt-out | 95% CI",
    x        = NULL,
    y        = "Change in Odds (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title         = element_text(size = 18, face = "bold"),
    plot.subtitle      = element_text(size = 14, color = "grey40"),
    axis.text.x        = element_text(size = 15),
    axis.text.y        = element_text(size = 14),
    axis.title.y       = element_text(size = 14),
    legend.position    = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank()
  )

# -- 9.2 Plot: Monthly Stationary Clothing Spend (GEGE) ------

gege_df <- odds_df %>%
  filter(Variable == "GEGE") %>%
  mutate(Pct_label = sprintf("%+.1f%%", Pct_Change))

p_gege <- ggplot(gege_df, aes(x = Alternative, y = Pct_Change, color = Alternative)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_errorbar(aes(ymin = (OR_lower - 1) * 100, ymax = (OR_upper - 1) * 100),
                width = 0.1, linewidth = 0.7) +
  geom_point(size = 5) +
  geom_text(aes(label = Pct_label), hjust = -0.4, size = 6, fontface = "bold") +
  scale_color_manual(values = c("#e77d51", "#5b8db8")) +
  scale_y_continuous(labels = function(x) paste0(x, "%"),
                     expand = expansion(mult = c(0.3, 0.3))) +
  labs(
    title    = "Effect of Monthly Clothing Spend on Store Choice",
    subtitle = "% change in odds per unit increase in monthly\nstationary retail spend vs opt-out | 95% CI",
    x        = NULL,
    y        = "Change in Odds (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title         = element_text(size = 18, face = "bold"),
    plot.subtitle      = element_text(size = 14, color = "grey40"),
    axis.text.x        = element_text(size = 15),
    axis.text.y        = element_text(size = 14),
    axis.title.y       = element_text(size = 14),
    legend.position    = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank()
  )

# -- 9.3 Plot: Second-Hand Attitude (SecHand2) ---------------

sechand_df <- odds_df %>%
  filter(Variable == "SecHand2") %>%
  mutate(Pct_label = sprintf("%+.1f%%", Pct_Change))

p_sechand <- ggplot(sechand_df, aes(x = Alternative, y = Pct_Change, color = Alternative)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_errorbar(aes(ymin = (OR_lower - 1) * 100, ymax = (OR_upper - 1) * 100),
                width = 0.1, linewidth = 0.7) +
  geom_point(size = 5) +
  geom_text(aes(label = Pct_label), hjust = -0.4, size = 6, fontface = "bold") +
  scale_color_manual(values = c("#e77d51", "#5b8db8")) +
  scale_y_continuous(labels = function(x) paste0(x, "%"),
                     expand = expansion(mult = c(0.3, 0.3))) +
  labs(
    title    = "Effect of Second-Hand Attitude on Store Choice",
    subtitle = "% change in odds per unit increase in second-hand attitude\nvs opt-out | 95% CI | Store 2 borderline significant (p = 0.050)",
    x        = NULL,
    y        = "Change in Odds (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title         = element_text(size = 18, face = "bold"),
    plot.subtitle      = element_text(size = 14, color = "grey40"),
    axis.text.x        = element_text(size = 15),
    axis.text.y        = element_text(size = 14),
    axis.title.y       = element_text(size = 14),
    legend.position    = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank()
  )

print(p_age)
print(p_gege)
print(p_sechand)



