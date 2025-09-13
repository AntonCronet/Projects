# Advanced Macroeconomics - Problem Set No. 3

**Course:** Advanced Macroeconomics  
**Institution:** Martin Luther University Halle-Wittenberg  
**Professor:** Dr Oliver Holtemöller  
**Student:** Anton Cronet (anton.cronet@student.uni-halle.de)  
**Student ID:** 224220895  
**Problem Set ID:** xXDUrt  
**Date:** January 23, 2025  

## Project Overview

This project contains the analysis and code for Problem Set No. 3 in Advanced Macroeconomics, focusing on:

1. **Task 1:** Business cycle analysis of French GDP using Hodrick-Prescott (HP) filter
2. **Task 2:** Ramsey growth model with permanent time preference shocks

## Repository Structure

```
├── Data_Cleaning.R              # R script for cleaning Eurostat data
├── Task_1.m                     # MATLAB/Octave script for HP filter analysis
├── hpfilter.m                   # HP filter implementation function
├── Task_2.m                     # MATLAB/Octave script for Ramsey model analysis
├── Example_9_1.m                # Reference file for Ramsey model
├── ramseygrowth_perm.mod        # Dynare model file for Ramsey growth with shocks
├── FR.gz                        # Raw French GDP data from Eurostat
├── Cleaned_Data.csv             # Processed data for analysis
└── README.md                    # This file
```

## Data Sources

### Primary Data
- **Source:** Eurostat
- **Dataset:** Quarterly GDP at Market Prices for France
- **Time Period:** Q1 2000 – Q3 2024
- **Currency:** Millions of Euros (chain-linked to 2010 prices)
- **Adjustments:** Seasonally and calendar adjusted
- **URL:** https://ec.europa.eu/eurostat/databrowser/view/namq_10_gdp__custom_14701021

## Key Findings

### Task 1: French GDP Business Cycle Analysis

**HP Filter Parameters:**
- Smoothing parameter (λ): 1600 (standard for quarterly data)

**Key Economic Events Identified:**
- **2008 Financial Crisis:** Sharp negative deviation in cyclical component
- **COVID-19 Pandemic (2020):** Major downward spike at the start of 2020
- **General Pattern:** Cyclical component stays around zero, indicating effective economic policy stabilization

**Insight:** The HP filter successfully isolates cyclical fluctuations from the long-term growth trend, revealing how external shocks impact the French economy.

### Task 2: Ramsey Growth Model Analysis

**Model Parameters:**
- Output elasticity of capital (α): 0.3
- Base time preference rate (ρₚ): 0.01
- Depreciation rate (δ): 0.02
- Elasticity of intertemporal substitution (θ): 1
- Adjustment parameter (a): 0.01
- Population growth rate (n): 0
- Total factor productivity (Z): 1

**Initial Conditions:**
- Initial capital stock (k₀): 10
- Initial consumption (c₀): 2
- Initial output (y₀): 5
- Initial investment (i₀): 1

**Key Relationships:**
- **Time Preference vs Savings Rate:** Negative correlation confirmed
- Higher time preference rate → Lower steady-state savings rate
- This relationship holds both with and without permanent shocks

**Permanent Shock Analysis (ε = 2, doubling time preference rate):**

**Short-term Effects:**
- Consumption increases sharply (~15% peak)
- Investment decreases significantly
- Savings rate drops substantially
- Capital and output begin declining

**Long-term Steady State:**
- Capital stock: 25% lower than initial state
- Output: 9% lower than initial state
- Savings rate: 30% lower than initial state
- Investment: 30% lower than initial state
- Consumption: 5% lower than initial state

**Economic Interpretation:** The permanent increase in time preference leads to short-term consumption bias but ultimately leaves the economy worse off across all metrics in the long run.

## Technical Implementation

### Software Requirements
- **R (4.2.3)** - For data cleaning and preprocessing
- **MATLAB/Octave (9.2.0)** - For economic modeling and HP filter analysis
- **Dynare (6.2)** - For dynamic stochastic general equilibrium modeling
- **RStudio** - Recommended IDE for R development

### Model Equations

**Ramsey Growth Model:**

1. **Euler Equation for Consumption:**
   ```
   c_{t+1}/c_t = [(1 + αZk_t^{α-1} - δ)/(1 + ρᵥ)]^{1/θ} × 1/(1 + a)
   ```

2. **Capital Accumulation:**
   ```
   k_t = [Zk_{t-1}^α + (1 - δ)k_{t-1} - c_t]/[(1 + n)(1 + a)]
   ```

3. **Output Equation:**
   ```
   y_t = Zk_{t-1}^α
   ```

4. **Investment Equation:**
   ```
   i_t = y_t - c_t
   ```

5. **Savings Rate:**
   ```
   s_t = i_t/y_t
   ```

6. **Time Preference Rate with Shock:**
   ```
   ρᵥ = ερₚ
   ```

## Usage Instructions

### Task 1: HP Filter Analysis
1. Run `Data_Cleaning.R` to process raw Eurostat data
2. Execute `Task_1.m` in MATLAB/Octave to:
   - Apply HP filter to French GDP data
   - Generate cyclical component visualization
   - Identify business cycle patterns

### Task 2: Ramsey Model Analysis
1. Ensure Dynare is properly installed and configured
2. Run `Task_2.m` in MATLAB/Octave to:
   - Analyze time preference rate vs savings rate relationship
   - Simulate permanent shock effects
   - Generate comparative visualizations

### File Dependencies
- `Task_1.m` requires `hpfilter.m` function
- `Task_2.m` references `Example_9_1.m` and uses `ramseygrowth_perm.mod`
- All scripts depend on cleaned data files

## Results and Visualizations

The project generates four key figures:
1. **French GDP Cyclical Component (2000-2024):** Shows business cycle fluctuations with major crisis events
2. **Time Preference vs Savings Rate (With Shock):** Demonstrates negative relationship
3. **Time Preference vs Savings Rate (Without Shock):** Confirms robustness of relationship
4. **Shock Impact Comparison:** Shows both level changes and percentage changes of endogenous variables

## Policy Implications

**Key Insights:**
- **Business Cycle Management:** HP filter analysis shows the effectiveness of stabilization policies in keeping cyclical fluctuations moderate
- **Intertemporal Choice:** Higher time preference rates lead to suboptimal economic outcomes in the long run
- **Policy Importance:** The Ramsey model demonstrates how institutions that influence consumer time preferences can improve overall economic welfare

**Theoretical Contribution:** This analysis reinforces the importance of forward-looking economic policies that balance present consumption with future investment needs.

## Academic Integrity

This work was completed independently with the following assistance:
- **ChatGPT:** Used for debugging code and MATLAB/Octave syntax guidance
- **Human verification:** All code was manually written and verified
- **R code:** Developed entirely without external assistance
- **Dynare models:** Based on lecture materials with independent modifications

## Software and References

### Software Versions
- Octave (9.2.0): https://octave.org/index
- Dynare (6.2): https://dynare.org/
- R (4.2.3): https://posit.co/download/rstudio-desktop/

### Lecture Materials
- Holtemöller, O., 2024. Advanced Macroeconomics. Chapter 9 & 10. Lecture Slides.
- Example_9_1.m (provided course material)
- hpfilter.m (provided course material)
