![head.png](https://github.com/cafawo/FinancialDataAnalytics/blob/master/figures/head.jpg?raw=1)

# Case Study: Copula Based Trading Strategy

This repository contains the code and resources for a copula-based algorithmic trading strategy. The project is structured to support both backtesting on historical data and live simulation via paper trading using the Alpaca API.
Note that any stocks or asset can be used for this strategy, the whole back testing script is desinged to be modular and scalable.
The paper trading script focuses on trading META, since it has shown favorable backtesting results with a multitude of parameter configurations.

---

## Prerequisites

- Python 3.8+
- Conda (recommended)
- Required packages (see `requirements.yml`)
- Alpaca API credentials (for paper trading)
- Format 'local.ini' file as:

[Alpaca-Paper-Trading]

API_KEY = []

API_SECRET = []

---

## Repository Structure

- `Backtesting.ipynb` – Jupyter notebook for historical backtesting
- `Paper_Trading.ipynb` – Jupyter notebook for live paper trading simulation
- `Run_Strategy.ipynb` – Script/notebook for running the strategy in a loop
- `case_data/` – Historical data for backtesting (e.g., `AAPL.csv`)
- `local.ini` – Local configuration file for API keys (not tracked by git)
- `README.md` – This file

---

## Setup Instructions

1. **Clone the repository**  
   ```sh
   git clone <your-repo-url>
   cd algo-trading-margaritaville-mutual
   ```

2. **Create the environment**  
   ```sh
   conda env create -f requirements.yml
   conda activate <your-env-name>
   ```

3. **Configure API credentials**  
   - Copy `local.ini.example` to `local.ini` and fill in your Alpaca API key and secret under `[Alpaca-Paper-Trading]`.

---

## Backtesting

1. Open `Backtesting.ipynb`.
2. Run all cells to:
   - Load historical data from `case_data/`
   - Process Data (remove extreme outliers, log-returns, fit GARCH(1, 1))
   - Fit Gaussian Multivariate Copula and identify observations' likelihoods
   - Generate trading signals using the copula-based strategy
   - Evaluate performance metrics (returns, Sharpe ratio, drawdowns, etc.)
   - Compare with benchmarks (e.g., buy-and-hold)

---

## Paper Trading

1. Open `Paper_Trading.ipynb`.
2. Ensure your `local.ini` is configured with valid Alpaca paper trading credentials.
3. Run all cells to:
   - Connect to Alpaca's paper trading API
   - Fetch latest market data
   - Generate and execute simulated trades based on strategy signals

---

## Running the Strategy in a Loop

- Use `Run_Strategy.ipynb` to simulate daily trading:
  - The script fetches new data, generates signals, and places trades automatically.
  - Adjust the loop or sleep interval as needed for your simulation.

---

## Learning about Copulas

Having heard about copulas brieflz during one of the lessons, I set out to learn about them. It seemed like a powerful tool I had never heard about. Below is a youtube playlist link I used to understand all the basics of copulas:

https://youtube.com/playlist?list=PLJYjjnnccKYDppALiJlHskU8md904FXgd&si=1xbFXrxQ6pd6BS3-






