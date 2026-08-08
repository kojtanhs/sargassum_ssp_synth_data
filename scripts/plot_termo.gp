# =========================================================================
# Gnuplot Script: scripts/plot_termo.gp
# Grafica el rendimiento de H2 vs Temperatura en la Gasificación (CSV)
# =========================================================================
set terminal pngcairo size 900,600 font "Sans,10"
set output 'data/rendimiento_h2_gasificacion.png'

# Configuración del motor para parsear archivos CSV
set datafile separator ","

# Filtro lógico: Si process_type (columna 2) == 1, devuelve el valor, si no, NaN
filtro_gas(proc, val) = (proc == 1) ? val : NaN

set title "Efecto de la Temperatura en el Rendimiento de H2 (Gasificación de SF)" font "Sans,12,Bold"
set xlabel "Temperatura de Proceso (°C)"
set ylabel "Rendimiento de H2 (% en volumen)"
set grid

# Graficar usando puntos de dispersión (Scatter Plot)
plot 'data/sargassum_thermochemical_data.csv' using 12:(filtro_gas($2, $17)) \
     with points pt 7 ps 0.8 lc rgb '#0066cc' title 'Muestras Estocásticas (Air/O2/Steam)'
