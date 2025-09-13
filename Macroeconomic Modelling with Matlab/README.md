# Advanced Macroeconomics - Complete Problem Set Solutions

**Course:** Advanced Macroeconomics  
**Institution:** Martin Luther University Halle-Wittenberg  
**Professor:** Dr Oliver Holtemöller  
**Student:** Anton Cronet (anton.cronet@student.uni-halle.de)  
**Student ID:** 224220895  
**Problem Set ID:** xXDUrt  
**Semester:** Winter 2024/25

## 📖 Project Overview

This repository contains comprehensive solutions and code implementations for all three problem sets in Advanced Macroeconomics, covering fundamental topics in dynamic macroeconomic theory and empirical analysis. The project demonstrates mastery of key concepts including intertemporal optimization, growth theory, business cycle analysis, and dynamic stochastic general equilibrium modeling.

## 📚 Problem Set Contents

### Problem Set 1: Intertemporal Choice & Fiscal Policy
**Date:** December 2024  
**Focus:** Budget constraints, Euler equations, and capital taxation

**Key Topics:**
- **Task 1:** Household intertemporal budget constraints and Euler equation derivation
- **Task 2:** Two-period equilibrium model with capital tax (τ)
- **Task 3:** Sensitivity analysis of capital taxation on government spending

**Core Models:** Two-period overlapping generations model with government

### Problem Set 2: Growth Theory & International Comparisons
**Date:** January 9, 2025  
**Focus:** Solow growth model and empirical GDP analysis

**Key Topics:**
- **Task 1:** Comparative GDP per capita analysis (Norway vs Sri Lanka, 1974-2023)
- **Task 2b:** Solow growth model simulation with productivity differences

**Core Models:** Solow-Swan growth model with capital accumulation

### Problem Set 3: Business Cycles & Dynamic Optimization
**Date:** January 23, 2025  
**Focus:** HP filter analysis and Ramsey growth model

**Key Topics:**
- **Task 1:** Business cycle analysis of French GDP using Hodrick-Prescott filter
- **Task 2:** Ramsey growth model with permanent time preference shocks

**Core Models:** Ramsey-Cass-Koopmans model with perfect foresight

## 🗂️ Repository Structure

```
├── Problem_Set_1/
│   ├── equilibrium.m
│   ├── twoperiodequilibrium.m
│   ├── twoperiodequilibrium_tax.m
│   ├── sensitivity.m
│   └── README.md
├── Problem_Set_2/
│   ├── Data_Cleaning.R
│   ├── GDP_Plots.m
│   ├── Solow_Simulation.m
│   ├── Example_6_1.m
│   ├── GDP.csv
│   └── Cleaned_Data.csv
├── Problem_Set_3/
│   ├── Data_Cleaning.R
│   ├── Task_1.m
│   ├── hpfilter.m
│   ├── Task_2.m
│   ├── Example_9_1.m
│   ├── ramseygrowth_perm.mod
│   ├── FR.gz
│   └── Cleaned_Data.csv
└── README.md                    # This file
```

## 🎯 Key Theoretical Frameworks

### 1. Intertemporal Optimization Theory
**Mathematical Foundation:**
- Lagrangian optimization with intertemporal budget constraints
- Euler equation: `MU(c₁)/MU(c₂) = (1+r)/(1+ρ)`
- Tax incidence analysis in dynamic settings

**Policy Applications:**
- Effect of capital taxation on savings and investment
- Government spending financed through capital income taxes
- Ricardian equivalence implications

### 2. Solow Growth Model
**Core Equations:**
```
y_t = A × k_t^α
k_{t+1} = s × y_t + (1 - δ) × k_t
```

**Empirical Applications:**
- International growth comparisons (Norway vs Sri Lanka)
- Productivity differences and convergence analysis
- Steady-state capital stock determination

**Key Insights:**
- Higher productivity leads to higher steady-state capital and output
- Convergence dynamics depend on initial conditions and productivity levels

### 3. Ramsey Growth Model
**Dynamic Optimization:**
```
c_{t+1}/c_t = [(1 + αZk_t^{α-1} - δ)/(1 + ρᵥ)]^{1/θ} × 1/(1 + a)
```

**Shock Analysis:**
- Permanent time preference shocks (ε = 2)
- Short-term vs long-term adjustment dynamics
- Welfare implications of impatience

**Policy Insights:**
- Higher time preference rates reduce steady-state welfare
- Importance of institutions in shaping intertemporal choices

### 4. Business Cycle Analysis
**HP Filter Methodology:**
- Smoothing parameter λ = 1600 for quarterly data
- Trend-cycle decomposition: `y_t = y_t^trend + y_t^cycle`
- Identification of economic shocks and policy effectiveness

## 📊 Major Empirical Findings

### Cross-Country Growth Patterns
**Norway (1974-2023):**
- GDP per capita growth: $31,440 → $78,939 (USD 2015)
- Steady growth with moderation post-2010s

**Sri Lanka (1974-2023):**
- GDP per capita growth: $819 → $3,969 (USD 2015)
- Exponential growth until 2010s, then decline

### French Business Cycles (2000-2024)
**Major Shocks Identified:**
- 2008 Financial Crisis: Sharp cyclical downturn
- 2020 COVID-19 Pandemic: Severe negative spike
- General stability: Cyclical component centers around zero

### Model Calibration Results
**Solow Model Convergence:**
- Economy 1 (A=1.0): Steady-state k* ≈ 4.8
- Economy 2 (A=1.1): Steady-state k* ≈ 5.5

**Ramsey Shock Effects (ρ doubled):**
- Capital stock: -25% in steady state
- Output: -9% in steady state
- Savings rate: -30% in steady state
- Short-term consumption spike: +15%

## 💻 Technical Implementation

### Software Stack
- **R (4.2.3-4.4.2)** - Data cleaning and preprocessing
- **MATLAB/Octave (9.2.0-9.3.0)** - Economic modeling and simulation
- **Dynare (6.2)** - DSGE model solving
- **RStudio** - Development environment

### Data Sources
- **World Bank Group** - World Development Indicators (GDP data)
- **Eurostat** - European macroeconomic statistics
- **Penn World Table** - International productivity comparisons

### Key Algorithms Implemented
1. **HP Filter** - Hodrick-Prescott trend-cycle decomposition
2. **Perfect Foresight Solver** - Ramsey model dynamics
3. **Steady-State Computation** - Solow and Ramsey equilibrium
4. **Sensitivity Analysis** - Parameter variation effects

## 🎓 Learning Outcomes

### Theoretical Mastery
- **Dynamic Optimization:** Lagrangian methods, Euler equations, transversality conditions
- **Growth Theory:** Solow convergence, endogenous savings, productivity effects
- **Business Cycles:** Trend-cycle decomposition, shock identification
- **Fiscal Policy:** Tax incidence, government budget constraints

### Empirical Skills
- **Data Processing:** Cleaning and transforming macroeconomic time series
- **Visualization:** Creating informative economic graphics
- **Model Calibration:** Parameter estimation and validation
- **Comparative Analysis:** Cross-country and cross-time comparisons

### Programming Proficiency
- **Scientific Computing:** MATLAB/Octave for numerical analysis
- **Statistical Software:** R for data manipulation and analysis
- **DSGE Modeling:** Dynare for solving dynamic models
- **Version Control:** Git workflow and documentation

## 🏛️ Policy Implications

### Fiscal Policy Design
- Capital taxation affects long-term growth through savings channels
- Government spending timing matters for intertemporal welfare
- Tax policy should consider dynamic adjustment costs

### Growth Policy Recommendations
- Productivity improvements have persistent effects on living standards
- International convergence depends on institutional quality
- Investment promotion policies can accelerate capital accumulation

### Macroeconomic Stabilization
- HP filter analysis supports counter-cyclical policy effectiveness
- Early identification of business cycle turning points aids policy timing
- Structural breaks require adaptive policy frameworks

## 📖 Academic References

### Textbooks
- Alogoskoufis, G. (2003). *Dynamic Macroeconomics*. MIT Press.
- Holtemöller, O. (2024). *Advanced Macroeconomics Lecture Slides*.

### Data Sources
- World Bank Group: World Development Indicators
- Eurostat: European macroeconomic database
- Penn World Table: International productivity data

### Software Documentation
- [GNU Octave](https://octave.org/index)
- [Dynare](https://dynare.org/)
- [R Project](https://posit.co/download/rstudio-desktop/)

## ⚖️ Academic Integrity

This work represents independent analysis with appropriate acknowledgment of assistance:

**AI Tool Usage:**
- ChatGPT used for debugging code syntax and conceptual clarification
- All mathematical derivations performed manually
- Code implementations verified independently

**Collaboration Policy:**
- Individual work with explicit citation of help received
- Course materials and lecture examples properly attributed
- Original analysis and interpretation throughout

*This repository demonstrates comprehensive understanding of modern macroeconomic theory through rigorous mathematical modeling, empirical analysis, and policy-relevant applications. The work bridges theoretical foundations with real-world economic phenomena, providing insights into growth, cycles, and optimal policy design.*