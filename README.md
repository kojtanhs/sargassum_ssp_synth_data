# Sargassum SSP Synth Data

## What is this project?
This project creates synthetic data for Sargassum seaweed energy conversion. It supports the "TP2" research pipeline.

We use two methods:
1.  **Biological Block:** Simulates methane production over 46 days using Fortran.
2.  **Thermochemical Block:** Simulates pyrolysis and gasification yields using Fortran.

The generated CSV files are used to train Machine Learning models (LSTM and XGBoost).

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

## License
This project is for academic research purposes.
