# =========================================================================
# Gnuplot Script Optimizado: scripts/plot_sargassum.gp
# Multiplot 2x2 con control explícito de sub-paneles
# =========================================================================
set terminal pngcairo size 1200,900 font "Sans,10"
set output 'data/analisis_dinamico_sargassum.png'

set datafile separator ","
filtro(id, val) = (id == 1) ? val : NaN

# Inicializar el entorno multifigura
set multiplot layout 2, 2 title "Monitoreo de Reactores (Pseudo-ADM1) - Muestra #1"

# --- PANEL 1: METANO ---
set title "Potencial de Metano (Gompertz)"
set xlabel "Tiempo (Días)"
set ylabel "CH4 (L/kg VS)"
set grid
plot 'data/sargassum_dynamic_data.csv' using 2:(filtro($1, $8)) with lines lw 1.5 lc rgb '#009933' title 'Acumulado'

# --- PANEL 2: pH ---
set title "Dinámica del pH"
set xlabel "Tiempo (Días)"
set ylabel "pH"
set grid
plot 'data/sargassum_dynamic_data.csv' using 2:(filtro($1, $10)) with lines lw 1.5 lc rgb '#cc0000' title 'pH'

# --- PANEL 3: VFA ---
set title "Ácidos Grasos Volátiles"
set xlabel "Tiempo (Días)"
set ylabel "VFA (mg/L)"
set grid
plot 'data/sargassum_dynamic_data.csv' using 2:(filtro($1, $11)) with lines lw 1.5 lc rgb '#0066cc' title 'VFA'

# --- PANEL 4: TEMPERATURA ---
set title "Perfil de Temperatura"
set xlabel "Tiempo (Días)"
set ylabel "Temperatura (°C)"
set grid
plot 'data/sargassum_dynamic_data.csv' using 2:(filtro($1, $12)) with lines lw 1 lc rgb '#ff9900' title 'Temp'

unset multiplot
