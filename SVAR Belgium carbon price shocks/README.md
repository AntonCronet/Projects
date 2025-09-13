# Structural Vector Autoregression Analysis: Carbon Policy Impacts on Macroeconomic Variables - Belgium

## Overview

This repository contains a Structural Vector Autoregression (SVAR) analysis examining the dynamic relationships between carbon policy measures and macroeconomic indicators in Belgium. The study uses monthly data from July 1999 to December 2019 to trace the effects of carbon policy surprises and shocks on key economic variables.

**Author**: Anton Cronet (224220895)  
**Institution**: Martin-Luther-University Halle-Wittenberg  
**Course**: Applied Macroeconometrics  
**Date**: July 31, 2025

## Research Questions

1. How do carbon policy surprises and shocks affect key macroeconomic variables?
2. What are the dynamic adjustment patterns following carbon policy interventions?
3. How robust are these relationships across different model specifications?

## Data Sources

### Variables Analyzed
- **Carbon Policy Surprises**: Monthly carbon policy surprises, aggregated by summing over daily surprises
- **Carbon Policy Shocks**: Identified using external instruments VAR with the surprise series as an instrument for energy price residual
- **HICP**: Harmonized Index of Consumer Prices (Belgium)
- **HICP-E**: Harmonized Index of Consumer Prices - Energy (Belgium)
- **Industrial Production**: Monthly industrial production index (Belgium)
- **Unemployment**: Unemployment rate (Belgium)

### Data Period
- **Time Span**: July 1999 - December 2019
- **Observations**: 246 monthly observations
- **Base Year**: All indices use 2015 = 1

### Sources
- **Carbon Shocks**: Diego Känzig's carbon price shock data from [GitHub Repository](https://github.com/dkaenzig/carbonpolicyshocks)
- **Economic Data**: Eurostat (Belgium-specific datasets)

## Methodology

### Data Processing Steps

1. **Log Transformation**: Applied to HICP, HICP-E, and Industrial Production
2. **Stationarity Testing**: Augmented Dickey-Fuller Test confirmed non-stationarity; first differences taken
3. **Model Specification**: Reduced-form VAR without trend (variables already stationary)
4. **Lag Length Selection**: Optimal lag length of 9 determined using AIC/BIC criteria and Ljung-Box tests
5. **SVAR Identification**: Cholesky decomposition with recursive ordering

### Variable Ordering (Cholesky Decomposition)

1. Carbon Policy Surprises (most exogenous)
2. Carbon Policy Shocks
3. Energy Prices (log difference)
4. Industrial Production (log difference)
5. HICP (log difference)
6. Unemployment Rate (difference)

### Economic Rationale for Ordering

- **Carbon Policies → Energy Prices**: Immediate cost impact on fossil fuel usage
- **Energy Prices → Industrial Production**: Contemporaneous effect due to energy as production input
- **Production → General Inflation**: Gradual pass-through due to sticky prices
- **Inflation → Unemployment**: Lagged response due to labor market frictions

## Key Findings

### Main Results
- Carbon policy variables show the strongest impulse response functions within the system
- Belgian macroeconomic variables demonstrate limited and mixed transmission patterns
- Unemployment shows unexpected immediate response (1 period lag) to carbon surprises
- Industrial production exhibits cyclical responses with 6-month periods
- Consumer prices respond positively to carbon shocks but negatively to surprises after 3 months

### Methodological Challenges
- Extreme sensitivity to model specification choices
- Dramatic changes across different lag lengths, trend specifications, and variable orderings
- Results suggest potential identification problems rather than genuine economic relationships

## Robustness Checks

### Tests Performed
1. **Linear Trend Specification**: Adding deterministic trend to baseline model
2. **Alternative Lag Lengths**: Testing with 6, 12, and 24 lags
3. **Alternative Variable Orderings**: Three different recursive orderings tested

### Results
All robustness checks revealed high sensitivity and erratic results, indicating fundamental methodological limitations in the SVAR identification scheme for this particular system.

## Technical Implementation

### Software
- **Primary Analysis**: MATLAB
- **Statistical Tests**: 
  - Augmented Dickey-Fuller Test (stationarity)
  - Ljung-Box Test (residual autocorrelation)
  - AIC/BIC (lag length selection)

### Model Specifications
- **Base Model**: VAR(9) with first differences
- **Identification**: Recursive Cholesky decomposition
- **Confidence Intervals**: 68% and 90% two-sided bands

## Files Structure

```
├── README.md
├── data/
│   ├── eurostat_data/          # Eurostat economic indicators
│   └── carbon_shocks/          # Känzig carbon policy data
├── code/
│   ├── main_analysis.m         # Primary SVAR estimation
│   ├── robustness_checks.m     # Alternative specifications
│   └── data_processing.m       # Data preparation scripts
├── results/
│   ├── figures/               # IRF plots and diagnostics
│   └── tables/                # Statistical test results
└── docs/
    └── term_paper.pdf         # Complete analysis report
```

## Limitations and Caveats

### Methodological Limitations
- High sensitivity to specification choices undermines result reliability
- Cholesky decomposition may be misspecified for this variable system
- Potential simultaneous relationships not captured by recursive identification

### Economic Interpretation Challenges
- Limited transmission channels from carbon policy to Belgian macroeconomy
- Results may reflect identification issues rather than true economic relationships
- Complex economic relationships may not be adequately captured by linear SVAR framework

## Future Research Directions

1. **Alternative Identification Strategies**: Sign restrictions or external instruments beyond carbon surprises
2. **Non-linear Models**: Threshold VAR or Markov-switching models
3. **Sectoral Analysis**: Industry-specific responses to carbon policy
4. **International Comparison**: Cross-country analysis of carbon policy transmission

## Usage Instructions

### Prerequisites
- MATLAB with Econometrics Toolbox
- Eurostat data access
- Känzig carbon shock dataset

### Running the Analysis
1. Clone repository and set up data directories
2. Download required datasets from Eurostat and Känzig's repository
3. Run `data_processing.m` to prepare variables
4. Execute `main_analysis.m` for baseline SVAR estimation
5. Run `robustness_checks.m` for sensitivity analysis

