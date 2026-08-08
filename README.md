# Sargassum SSP Synth Data

## What is this project?
This project is part of the **BIP Summer Institute 2026**. It was mentored by **Dr. Rita Appiah** from **Purdue University**.

The goal is to create synthetic data for Sargassum seaweed energy conversion. This data supports the "TP2" research pipeline.

We use two methods:
1.  **Biological Block:** Simulates methane production over 46 days using Fortran.
2.  **Thermochemical Block:** Simulates pyrolysis and gasification yields using Fortran.

The generated CSV files are used to train Machine Learning models (LSTM and XGBoost) for biogas and syngas prediction.

## Project Structure
-   `src/`: Fortran source code for data generation.
-   `data/`: Generated CSV datasets and analysis plots.
-   `scripts/`: Gnuplot scripts for visualization.
-   `Makefile`: Instructions to compile the Fortran code.

## How to Run
You need `gfortran` and `make` installed.

1.  Compile the code:
    ```bash
    make all
    ```
2.  Run the biological simulation:
    ```bash
    ./sim_bip_dinamico.out
    ```
3.  Run the thermochemical simulation:
    ```bash
    ./sim_bip_termo.out
    ```

## Data Description
-   `sargassum_dynamic_data.csv`: Time-series data (t=1..46 days) for LSTM training.
-   `sargassum_thermochemical_data.csv`: Static mass/energy balance data for XGBoost/RF training.

## Data Source
The synthetic data is based on real research:

-   **Biological Block:** Uses separation coefficients and methane yields from Salgado-Hernández et al. (2023). The Liquid Fraction (LF) produces 159.7 L CH4/kg VS, while the Solid Fraction (SF) produces 83.45 L CH4/kg VS.
-   **Thermochemical Block:** Uses thermodynamic equations for syngas Lower Heating Value (LHV) based on Velázquez-Hernández et al.
-   **Kinetics:** Time-series data (46 days) follows the Modified Gompertz model parameters reported in the same study.

## ML Pipeline Context
This dataset supports two machine learning tasks:

1.  **LSTM Networks:** Trained on the 46-day dynamic series to predict cumulative methane production. LSTM is chosen because it handles time-series process dynamics effectively in biogas monitoring (Tisocco et al., 2026).
2.  **XGBoost & Random Forest:** Trained on static thermochemical data to predict gas yields and LHV. XGBoost often leads in gasification gas prediction, while Random Forest remains competitive for pyrolysis product yields (Cihan, 2025; Dong et al., 2022). Both models are benchmarked here to compare performance per target.

## References

1.  Salgado-Hernández, E., et al. (2023). Methane Production of Sargassum spp. Biomass from the Mexican Caribbean: Solid–Liquid Separation and Component Distribution. *International Journal of Environmental Research and Public Health*, 20(1), 219. https://doi.org/10.3390/ijerph20010219
    > *Key source for biological block parameters, separation coefficients, and BMP yields.*

2.  Tisocco, S., et al. (2026). Machine learning vs. ADM1: Reliable biogas prediction with minimal data requirements in full-scale plants. *Environmental Science and Ecotechnology*, 29, 100662. https://doi.org/10.1016/j.ese.2026.100662
    > *Supports the use of LSTM networks for time-series methane prediction in waste-to-energy systems.*

3.  Cihan, P. (2025). Bayesian Hyperparameter Optimization of Machine Learning Models for Predicting Biomass Gasification Gases. *Applied Sciences*, 15(3), 1018. https://doi.org/10.3390/app15031018
    > *Benchmarks XGBoost performance for gasification gas composition and LHV prediction.*

4.  Dong, Z., Bai, X., Xu, D., & Li, W. (2022). Machine learning prediction of pyrolytic products of lignocellulosic biomass based on physicochemical characteristics and pyrolysis conditions. *Bioresource Technology*, 128182. https://doi.org/10.2139/ssrn.4191315
    > *Demonstrates Random Forest competitiveness for pyrolysis product yield prediction.*

## License
This project is for academic research purposes.
