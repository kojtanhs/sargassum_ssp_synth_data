# =========================================================================
# Makefile Evolucionado - BIP Summer Institute 2026
# =========================================================================

FC       = gfortran
FCFLAGS  = -O2 -Wall -Wextra -fimplicit-none
INC_DIR  = include
OBJ_DIR  = obj

FCFLAGS += -J $(INC_DIR)

# Objetivos finales (Binarios)
TARGET_DYN = sim_bip_dinamico.out
TARGET_TERM = sim_bip_termo.out

# Regla por defecto: compilar ambos sistemas
all: $(TARGET_DYN) $(TARGET_TERM)

# Compilación del generador dinámico (Sargassum LF)
$(TARGET_DYN): $(OBJ_DIR)/main.o
	$(FC) $(FCFLAGS) -o $(TARGET_DYN) $(OBJ_DIR)/main.o

# Compilación del nuevo generador termoquímico (Sargassum SF)
$(TARGET_TERM): $(OBJ_DIR)/sargassum_thermochemical_generator.o
	$(FC) $(FCFLAGS) -o $(TARGET_TERM) $(OBJ_DIR)/sargassum_thermochemical_generator.o

# Regla genérica para construir objetos .o en su carpeta aislada
$(OBJ_DIR)/%.o: src/%.f90
	@mkdir -p $(OBJ_DIR) $(INC_DIR)
	$(FC) $(FCFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(OBJ_DIR)/*.o $(INC_DIR)/*.mod $(TARGET_DYN) $(TARGET_TERM)
	@echo "Ecosistema purgado y limpio."
