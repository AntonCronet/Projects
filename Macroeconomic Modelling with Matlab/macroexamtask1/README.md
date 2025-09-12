
# Advanced Macroeconomics – Problem Set 1

This repository contains solutions and code implementations for **Problem Set No. 1** of the course **Advanced Macroeconomics (Winter 2024/25)** at Martin Luther University Halle-Wittenberg, supervised by **Prof. Dr. Oliver Holtemöller**.

## 📖 Contents

The project covers three main tasks:

1. **Task 1 – Budget Constraints & Euler Equation**

   * Derivation of the household’s intertemporal budget constraint.
   * Construction of the Lagrangian and first-order conditions.
   * Euler equation relating consumption across periods under taxation.

2. **Task 2 – Equilibrium with Capital Tax (τ)**

   * Extension of the two-period equilibrium model by introducing a tax on capital income.
   * Implementation of government spending equations:

     * $g_1 = τ r_1 k_1$
     * $g_2 = τ r_2 k_2$
   * Computation of equilibrium values for consumption, wages, rental rates, and government spending.

3. **Task 3 – Sensitivity Analysis of τ on g₁**

   * Simulation of the effect of capital taxation on government spending in period 1.
   * Linear relationship confirmed between τ and g₁.

---

## 🗂 Code Files

| File Name                       | Description                                   |
| ------------------------------- | --------------------------------------------- |
| **equilibrium.m**               | Base model setup for equilibrium computations |
| **twoperiodequilibrium.m**      | Two-period equilibrium model (without tax)    |
| **twoperiodequilibrium\_tax.m** | Extended equilibrium model including tax τ    |
| **sensitivity.m**               | Sensitivity analysis of τ on g₁               |

All scripts were implemented and tested in **GNU Octave 9.2.0**.

---

## 📚 References

* Alogoskoufis, G. (2003). *Dynamic Macroeconomics*. MIT Press.
* Holtemöller, O. (2024). *Advanced Macroeconomics Lecture Slides, Chapter 5*.
* [Octave Software](https://octave.org/index)
* [Penn World Table – Productivity Data](https://www.rug.nl/ggdc/productivity/pwt/?lang=en)

---

## ✍️ Notes

* All derivations were done independently.
* AI tools (ChatGPT) were only used to clarify concepts and guide reasoning; mathematical work was carried out manually.

