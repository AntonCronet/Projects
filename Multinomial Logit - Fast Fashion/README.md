# Store Choice and Customer Behaviour: Multinomial Logit Analysis

**Statistical Applications Exam | MLU | Winter Term 2025/2026**
**Anton Cronet**

---

## Overview

This project investigates how consumers trade off price, sustainability, and store characteristics when choosing between fashion retailers. Using a Discrete Choice Experiment (DCE) survey of MLU students, a Multinomial Logit (MNL) model is estimated via the `apollo` package in R to quantify attribute importance and willingness to pay.

**Research Question:** How do consumers trade off price, sustainability, and store characteristics when choosing between fashion retailers, and how do individual characteristics influence store engagement relative to the opt-out?

---

## Repository Structure

```
├── Cronet-Anton_StatAp25_script.R   # Full analysis script
├── dce_fashion2.RData               # Survey data (not tracked — add to .gitignore)
├── output/                          # Apollo model output directory
└── README.md
```

---

## Data

- **Source:** Online survey of MLU students
- **Sample:** 319 individuals (after removing incomplete responses)
- **Structure:** Panel data — 6 choice tasks per respondent = 1,914 total observations
- **Choice alternatives:** Store 1, Store 2, or opt-out (neither)
- **Product:** Standardised black t-shirt

**Store attributes varied across choice tasks:**

| Attribute | Levels |
|---|---|
| Price | Continuous (€) |
| Headquarter Location | Germany / EU / US / Asia |
| Distribution Channel | In-store / Online / Hybrid |
| Shipping Time | Continuous (days) |
| Marketing Intensity | Minimal / Moderate / Maximum |
| Ecological Sustainability | Yes / No |
| Social Sustainability | Yes / No |

**Individual-level variables** include age, gender, household size and income, monthly clothing spend, in-store shopping share, and second-hand purchase behaviour.

---

## Methodology

**Model:** Multinomial Logit (MNL) under a Random Utility Maximisation (RUM) framework, estimated with the [`apollo`](https://www.apollochoicemodelling.com/) package.

**Utility function:**

$$U_{ij} = ASC_j + \beta_{indiv} \cdot Individual_i + \beta_{store} \cdot Attributes_{ij} + \varepsilon_{ij}$$

- Alternative 3 (opt-out) is the reference: utility fixed to 0
- Panel likelihood computed by multiplying choice probabilities across all 6 tasks per individual
- Robust standard errors reported throughout

**IIA assumption** tested via the Hausman-McFadden test (χ² = 3.00, df = 1, p = 0.083 → fail to reject H0, IIA holds).

**Post-estimation analyses:**
- Relative attribute importance (utility range method)
- Willingness to Pay: WTP = −β_attribute / β_price
- Store price elasticity (simulated 1% price increase)
- Odds ratios for individual-level characteristics

---

## Key Results

**Most important store attributes (share of total utility variation):**

| Attribute | Relative Importance |
|---|---|
| Price | 46.4% |
| Headquarter Location | 26.7% |
| Ecological Sustainability | 9.6% |
| Distribution Channel | 5.7% |
| Shipping Time | 5.3% |
| Social Sustainability | 4.1% |
| Marketing Intensity | 2.2% |

**Individual characteristics that significantly influence store choice vs opt-out:** age (−3% odds per year), monthly clothing spend (+~1% per unit), and second-hand attitude for events (+63% odds for Store 2).

---

## Limitations

- **Sample:** MLU students only — younger, more educated, and more sustainability-aware than the general population. Results may not generalise to broader consumer segments.
- **Hypothetical bias:** Stated preferences may overstate sustainability valuations relative to actual purchasing behaviour.
- **Preference homogeneity:** MNL assumes all taste variation is captured by observed demographics. A Mixed Logit model would allow random preference heterogeneity, but requires more choice tasks per respondent than the 6 available here for stable estimation.

---

## Requirements

```r
install.packages(c("apollo", "dplyr", "tidyr", "ggplot2"))
```

Tested with R ≥ 4.2. The `apollo` package requires additional setup — see the [Apollo documentation](https://www.apollochoicemodelling.com/manual.html).

---

## Usage

1. Clone the repository and place `dce_fashion2.RData` in the project root.
2. Open `Cronet-Anton_StatAp25_script.R` in RStudio.
3. Run the script top to bottom. Sections are clearly numbered (0–9):
   - **0** — Package loading
   - **1** — Data loading and inspection
   - **2** — Data preparation and cleaning
   - **3** — Apollo model setup and estimation
   - **4** — Model summary and coefficient table
   - **5** — Hausman-McFadden IIA test
   - **6** — Willingness to Pay
   - **7** — Store price elasticity simulation
   - **8** — Relative attribute importance
   - **9** — Odds ratios for individual characteristics

Model output is saved to `output/`.

---

## References

Carrington, M.J., Neville, B.A. & Whitwell, G.J. (2010). Why Ethical Consumers Don't Walk Their Talk. *Journal of Business Ethics*, 97, 139–158. https://doi.org/10.1007/s10551-010-0501-6

Niinimäki, K., Peters, G., Dahlbo, H., Perry, P., Rissanen, T., & Gwilt, A. (2020). The environmental price of fast fashion. *Nature Reviews Earth & Environment*, 1, 189–200. https://doi.org/10.1038/s43017-020-0039-9