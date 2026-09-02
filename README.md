# Algorithmic Trading Strategies in R

An educational quantitative-finance project that explores rule-based trading strategies using R. The repository contains implementations and examples built around moving averages, momentum signals, and Bollinger Bands.

> This project was developed as part of COMP396 and is intended to demonstrate practical skills in time-series analysis, trading-signal design, and strategy experimentation.

## Project Overview

The project investigates how technical indicators can be translated into reproducible trading rules. Each script focuses on a different strategy or provides an example configuration that can be adapted for further research and backtesting.

### Strategies Included

- **Moving-average strategy** — uses price averages to identify changes in market direction and potential entry or exit points.
- **Momentum strategy** — evaluates the strength and persistence of price movements.
- **Bollinger Band trend-following strategy** — uses volatility bands around a moving average to generate trend-based signals.
- **Example strategies** — contains sample parameters and configurations for experimenting with the available approaches.

## Repository Structure

| File | Purpose |
| --- | --- |
| `Williams%r&MovingAverage.R` | Explores Williams %R and moving-average indicators. |
| `bollinger_t_following.R` | Implements a Bollinger Band trend-following strategy. |
| `example_strategies.R` | Provides example strategy parameters and configurations. |
| `momentum1` | Contains the momentum-based strategy implementation. |

## Tools and Concepts

- R
- Financial time-series analysis
- Technical indicators
- Trading-signal generation
- Strategy parameterization
- Quantitative research and backtesting concepts

## Getting Started

### Prerequisites

Install a recent version of [R](https://www.r-project.org/) and, optionally, [RStudio](https://posit.co/download/rstudio-desktop/).

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/oluwatimilehintomoloju/COMP396.git
   cd COMP396
   ```

2. Open the project directory in RStudio or your preferred R environment.

3. Open the strategy you want to explore and install any packages requested by that script:

   ```r
   install.packages("PACKAGE_NAME")
   ```

4. Review the asset, date range, and strategy parameters near the top of the script, then run the file.

## Usage

The scripts can be used as starting points for comparing indicator-based strategies or testing alternative parameter values. A typical workflow is:

1. Select or import market-price data.
2. Configure the indicator and strategy parameters.
3. Run the selected strategy script.
4. Inspect its signals, plots, and any generated performance output.
5. Compare the behaviour of the strategy across different assets or time periods.

## Skills Demonstrated

- Converting financial concepts into working R code
- Manipulating and analysing time-series data
- Designing rule-based entry and exit signals
- Structuring reusable strategy parameters
- Evaluating quantitative-trading ideas through experimentation

## Future Improvements

- Add a reproducible package-management file with pinned versions.
- Standardize input data and output formats across all strategies.
- Add transaction costs, slippage, and position-sizing rules.
- Compare strategies with common risk and performance metrics.
- Include charts and a concise results table for portfolio presentation.
- Add automated tests for signal and indicator calculations.

## Disclaimer

This repository is for educational and research purposes only. It does not provide financial advice, and the strategies should not be used for live trading without independent validation and appropriate risk controls. Past performance does not guarantee future results.

## Authors

**Liel Takawira**, 
**Oluwatimilehin Tomoloju**, 
**Dewi Townley**

- GitHub: [@LielTaks](https://github.com/LielTaks)
- GitHub: [@oluwatimilehintomoloju](https://github.com/oluwatimilehintomoloju)
- GitHub: [@DewiTownley](https://github.com/DewiTownley)


## Acknowledgements

This repository is a fork of the original COMP396 project by [LielTaks](https://github.com/LielTaks/COMP396).

## License

No license has been specified. Unless a license is added, all rights are reserved by the repository owner and the original project contributors.
