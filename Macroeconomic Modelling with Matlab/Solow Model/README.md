# Advanced Macroeconomics - Problem Set No. 2

**Course:** Advanced Macroeconomics  
**Institution:** Martin Luther University Halle-Wittenberg  
**Professor:** Dr Oliver Holtemöller  
**Student:** Anton Cronet (anton.cronet@student.uni-halle.de)  
**Student ID:** 224220895  
**Problem Set ID:** xXDUrt  
**Date:** January 9, 2025  

## Project Overview

This project contains the analysis and code for Problem Set No. 2 in Advanced Macroeconomics, focusing on:

1. **Task 1:** Comparative analysis of GDP per capita between Norway and Sri Lanka (1974-2023)
2. **Task 2b:** Solow growth model simulation comparing two economies with different productivity levels

## Repository Structure

```
├── Data_Cleaning.R          # R script for cleaning World Bank data
├── GDP_Plots.m             # MATLAB/Octave script for generating GDP visualizations
├── Solow_Simulation.m      # MATLAB/Octave script for Solow model simulation
├── Example_6_1.m           # Reference file for Solow simulation
├── GDP.csv                 # Raw GDP data from World Bank
├── Cleaned_Data.csv        # Processed data for analysis
└── README.md              # This file
```

## Data Sources

### Primary Data
- **Source:** World Bank Group - World Development Indicators database
- **Variables:** Real GDP per capita for Norway and Sri Lanka
- **Time Period:** 1974-2023
- **Currency:** USD 2015 (inflation-adjusted)

### Additional References
- Penn World Table: https://www.rug.nl/ggdc/productivity/pwt/?lang=en
- World Bank Data: https://databank.worldbank.org/source/world-development-indicators

## Key Findings

### Task 1: GDP Per Capita Analysis

**Norway (1974-2023):**
- Starting GDP per capita: $31,440 USD (1974)
- Ending GDP per capita: $78,939 USD (2023)
- Growth pattern: Steady growth until 2010s, then slower but consistent growth

**Sri Lanka (1974-2023):**
- Starting GDP per capita: $819 USD (1974)
- Ending GDP per capita: $3,969 USD (2023)
- Growth pattern: Exponential growth until 2010s, followed by declining GDP per capita

### Task 2b: Solow Model Simulation

**Model Parameters:**
- Output elasticity (α): 0.3
- Savings rate (s): 0.3
- Depreciation rate (δ): 0.1
- Initial capital stock (k₀): 0.1

**Economy Comparison:**
- **Economy 1** (A = 1.0): Converges to steady-state capital stock ≈ 4.8
- **Economy 2** (A = 1.1): Converges to steady-state capital stock ≈ 5.5

**Key Insight:** Higher productivity leads to higher steady-state capital stock and output per capita.

## Technical Implementation

### Software Requirements
- **R (4.4.2)** - For data cleaning and preprocessing
- **MATLAB/Octave (9.3.0)** - For economic modeling and visualization
- **RStudio** - Recommended IDE for R development

### Model Equations
The Solow growth model is implemented using:

```
y_t = A × k_t^α
k_{t+1} = s × y_t + (1 - δ) × k_t
```

Where:
- `y_t` = output per capita at time t
- `k_t` = capital stock per capita at time t
- `A` = total factor productivity
- `α` = output elasticity of capital
- `s` = savings rate
- `δ` = depreciation rate

## Usage Instructions

### Data Processing
1. Run `Data_Cleaning.R` to process raw World Bank data
2. This generates `Cleaned_Data.csv` for use in MATLAB/Octave

### Visualization Generation
1. Execute `GDP_Plots.m` in MATLAB/Octave to generate GDP comparison charts
2. Run `Solow_Simulation.m` to create Solow model visualizations

### File Dependencies
- `Solow_Simulation.m` references `Example_6_1.m`
- All plotting scripts depend on cleaned data files

## Results and Visualizations

The project generates five key figures:
1. GDP per capita of Norway (1974-2023)
2. GDP per capita of Sri Lanka (1974-2023)
3. Comparative GDP per capita plot
4. Capital stock evolution in Solow model
5. Production per capita evolution in Solow model

## Academic Integrity

This work was completed independently with the following assistance:
- **ChatGPT:** Used for debugging code and MATLAB/Octave syntax guidance
- **Human verification:** All code was manually written and verified
- **R code:** Developed entirely without external assistance

