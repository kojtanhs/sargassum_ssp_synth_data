! ==============================================================================
! Programa: sargassum_thermochemical_generator.f90
! Descripción: Genera datos sintéticos estáticos para la Fracción Sólida (SF)
!              de Sargassum, simulando gasificación, pirólisis y HTC.
! ==============================================================================
program sargassum_thermochemical_generator
    implicit none

    integer, parameter :: dp = kind(1.0d0)
    integer, parameter :: n_samples_per_process = 500
    integer, parameter :: n_processes = 3
    integer, parameter :: total_samples = n_samples_per_process * n_processes
    real(dp), parameter :: PI = 3.141592653589793_dp
    
    integer :: i, j, file_unit, process_type
    real(dp) :: rand_raw, gauss_noise
    
    ! Composición de la Fracción Sólida (SF)
    real(dp) :: C_pct, H_pct, O_pct, N_pct, S_pct
    real(dp) :: cellulose_pct, hemicellulose_pct, lignin_pct
    real(dp) :: ash_pct
    
    ! Condiciones de proceso
    real(dp) :: temperature, pressure, residence_time
    integer :: gasifying_agent ! 1=air, 2=oxygen, 3=steam
    
    ! Targets de salida
    real(dp) :: CO_yield, H2_yield, CH4_yield, CO2_yield, LHV
    real(dp) :: bio_oil_yield, biochar_yield, syngas_yield
    real(dp) :: hydrochar_yield, HHV_hydrochar
    
    ! Semilla aleatoria
    integer :: seed_size
    integer, allocatable :: seed(:)

    call random_seed(size=seed_size)
    allocate(seed(seed_size))
    seed = 54321
    call random_seed(put=seed)

    file_unit = 20
    open(unit=file_unit, file='data/sargassum_thermochemical_data.csv', status='replace', action='write')
    
    write(file_unit, '(A)') 'sample_id,process_type,C_pct,H_pct,O_pct,N_pct,S_pct,' &
                          // 'cellulose_pct,hemicellulose_pct,lignin_pct,ash_pct,' &
                          // 'temperature_C,pressure_bar,residence_time_h,gasifying_agent,' &
                          // 'CO_yield_pct,H2_yield_pct,CH4_yield_pct,CO2_yield_pct,LHV_MJ_Nm3,' &
                          // 'bio_oil_yield_pct,biochar_yield_pct,syngas_yield_pct,' &
                          // 'hydrochar_yield_pct,HHV_hydrochar_MJ_kg'

    print *, 'Iniciando generación de datos termoquímicos para SF de Sargassum...'

    do process_type = 1, n_processes
        print *, 'Procesando tipo: ', process_type
        
        do i = 1, n_samples_per_process
            ! 1. Muestrear composición de SF (basado en Salgado-Hernández et al., 2023)
            call random_number(rand_raw); C_pct = 28.0_dp + rand_raw * 4.0_dp        ! 28-32%
            call random_number(rand_raw); H_pct = 2.5_dp + rand_raw * 0.5_dp         ! 2.5-3.0%
            call random_number(rand_raw); O_pct = 30.0_dp + rand_raw * 6.0_dp        ! 30-36%
            call random_number(rand_raw); N_pct = 1.4_dp + rand_raw * 0.4_dp         ! 1.4-1.8%
            call random_number(rand_raw); S_pct = 0.3_dp + rand_raw * 0.1_dp         ! 0.3-0.4%
            
            call random_number(rand_raw); cellulose_pct = 10.0_dp + rand_raw * 3.0_dp    ! 10-13%
            call random_number(rand_raw); hemicellulose_pct = 1.0_dp + rand_raw * 1.5_dp ! 1-2.5%
            call random_number(rand_raw); lignin_pct = 9.0_dp + rand_raw * 3.0_dp        ! 9-12%
            
            call random_number(rand_raw); ash_pct = 25.0_dp + rand_raw * 10.0_dp     ! 25-35%

            ! 2. Muestrear condiciones de proceso
            if (process_type == 1) then ! Gasificación
                call random_number(rand_raw); temperature = 700.0_dp + rand_raw * 200.0_dp ! 700-900°C
                call random_number(rand_raw); pressure = 1.0_dp + rand_raw * 4.0_dp       ! 1-5 bar
                call random_number(rand_raw); residence_time = 0.5_dp + rand_raw * 2.0_dp ! 0.5-2.5 h
                call random_number(rand_raw)
                if (rand_raw < 0.33_dp) then
                    gasifying_agent = 1 ! air
                else if (rand_raw < 0.66_dp) then
                    gasifying_agent = 2 ! oxygen
                else
                    gasifying_agent = 3 ! steam
                end if
                
                ! 3. Calcular rendimientos de gasificación (correlaciones empíricas)
                ! Basado en balances elementales y literatura (Cihan, 2025)
                CO_yield = 15.0_dp + 0.02_dp * (temperature - 700.0_dp) + 0.3_dp * C_pct &
                         - 0.2_dp * O_pct + 2.0_dp * real(gasifying_agent, dp)
                H2_yield = 8.0_dp + 0.03_dp * (temperature - 700.0_dp) + 1.5_dp * H_pct &
                         + 3.0_dp * real(gasifying_agent - 2, dp) ! steam produce más H2
                CH4_yield = 6.0_dp - 0.015_dp * (temperature - 700.0_dp) + 0.5_dp * H_pct &
                          + 0.2_dp * C_pct
                CO2_yield = 15.0_dp + 0.4_dp * O_pct - 0.1_dp * (temperature - 700.0_dp)
                
                ! Normalizar para que sumen ~100% (el resto es N2 u otros)
                call normalize_gas_yields(CO_yield, H2_yield, CH4_yield, CO2_yield)
                
                ! LHV = 0.126*CO + 0.108*H2 + 0.358*CH4 (MJ/Nm³)
                LHV = 0.126_dp * CO_yield + 0.108_dp * H2_yield + 0.358_dp * CH4_yield
                
                ! Pirólisis y HTC no aplican para gasificación
                bio_oil_yield = 0.0_dp
                biochar_yield = 0.0_dp
                syngas_yield = 0.0_dp
                hydrochar_yield = 0.0_dp
                HHV_hydrochar = 0.0_dp
                
            else if (process_type == 2) then ! Pirólisis
                call random_number(rand_raw); temperature = 400.0_dp + rand_raw * 300.0_dp ! 400-700°C
                call random_number(rand_raw); pressure = 1.0_dp + rand_raw * 2.0_dp       ! 1-3 bar
                call random_number(rand_raw); residence_time = 0.2_dp + rand_raw * 1.0_dp ! 0.2-1.2 h
                gasifying_agent = 0 ! No aplica
                
                ! 3. Calcular rendimientos de pirólisis (basado en Dong et al., 2022)
                ! Bio-oil máximo a ~500°C, biochar máximo a baja T, syngas aumenta con T
                bio_oil_yield = 50.0_dp - 0.05_dp * abs(temperature - 500.0_dp) &
                              + 0.8_dp * cellulose_pct + 0.5_dp * hemicellulose_pct
                biochar_yield = 40.0_dp - 0.03_dp * (temperature - 400.0_dp) &
                              + 1.2_dp * lignin_pct
                syngas_yield = 100.0_dp - bio_oil_yield - biochar_yield
                
                ! Asegurar que estén en rangos realistas
                bio_oil_yield = max(20.0_dp, min(65.0_dp, bio_oil_yield))
                biochar_yield = max(15.0_dp, min(45.0_dp, biochar_yield))
                syngas_yield = 100.0_dp - bio_oil_yield - biochar_yield
                
                ! Gasificación y HTC no aplican
                CO_yield = 0.0_dp
                H2_yield = 0.0_dp
                CH4_yield = 0.0_dp
                CO2_yield = 0.0_dp
                LHV = 0.0_dp
                hydrochar_yield = 0.0_dp
                HHV_hydrochar = 0.0_dp
                
            else ! HTC (process_type == 3)
                call random_number(rand_raw); temperature = 180.0_dp + rand_raw * 100.0_dp ! 180-280°C
                call random_number(rand_raw); pressure = 10.0_dp + rand_raw * 40.0_dp    ! 10-50 bar
                call random_number(rand_raw); residence_time = 1.0_dp + rand_raw * 3.0_dp ! 1-4 h
                gasifying_agent = 0 ! No aplica
                
                ! 3. Calcular rendimientos de HTC (basado en Djandja et al., 2023; Yuan et al., 2024)
                hydrochar_yield = 60.0_dp - 0.1_dp * (temperature - 200.0_dp) &
                                - 2.0_dp * (residence_time - 2.0_dp) + 0.8_dp * lignin_pct
                hydrochar_yield = max(35.0_dp, min(75.0_dp, hydrochar_yield))
                
                ! HHV de hydrochar correlacionado con C y inversamente con ash
                HHV_hydrochar = 0.35_dp * C_pct + 0.5_dp * (100.0_dp - ash_pct) / 10.0_dp &
                              - 0.1_dp * temperature / 100.0_dp
                HHV_hydrochar = max(15.0_dp, min(30.0_dp, HHV_hydrochar))
                
                ! Gasificación y pirólisis no aplican
                CO_yield = 0.0_dp
                H2_yield = 0.0_dp
                CH4_yield = 0.0_dp
                CO2_yield = 0.0_dp
                LHV = 0.0_dp
                bio_oil_yield = 0.0_dp
                biochar_yield = 0.0_dp
                syngas_yield = 0.0_dp
            end if

            ! 4. Inyectar ruido gaussiano (Box-Muller)
            call box_muller(0.0_dp, 1.5_dp, gauss_noise)
            CO_yield = CO_yield + gauss_noise
            call box_muller(0.0_dp, 1.0_dp, gauss_noise)
            H2_yield = H2_yield + gauss_noise
            call box_muller(0.0_dp, 0.5_dp, gauss_noise)
            CH4_yield = CH4_yield + gauss_noise
            call box_muller(0.0_dp, 1.2_dp, gauss_noise)
            CO2_yield = CO2_yield + gauss_noise
            call box_muller(0.0_dp, 0.3_dp, gauss_noise)
            LHV = LHV + gauss_noise
            
            call box_muller(0.0_dp, 2.0_dp, gauss_noise)
            bio_oil_yield = bio_oil_yield + gauss_noise
            call box_muller(0.0_dp, 1.5_dp, gauss_noise)
            biochar_yield = biochar_yield + gauss_noise
            call box_muller(0.0_dp, 1.0_dp, gauss_noise)
            syngas_yield = 100.0_dp - bio_oil_yield - biochar_yield
            
            call box_muller(0.0_dp, 2.5_dp, gauss_noise)
            hydrochar_yield = hydrochar_yield + gauss_noise
            call box_muller(0.0_dp, 0.8_dp, gauss_noise)
            HHV_hydrochar = HHV_hydrochar + gauss_noise

            ! Asegurar que los rendimientos no sean negativos
            CO_yield = max(0.0_dp, CO_yield)
            H2_yield = max(0.0_dp, H2_yield)
            CH4_yield = max(0.0_dp, CH4_yield)
            CO2_yield = max(0.0_dp, CO2_yield)
            bio_oil_yield = max(0.0_dp, bio_oil_yield)
            biochar_yield = max(0.0_dp, biochar_yield)
            syngas_yield = max(0.0_dp, syngas_yield)
            hydrochar_yield = max(0.0_dp, hydrochar_yield)
            HHV_hydrochar = max(0.0_dp, HHV_hydrochar)

            ! 5. Escribir fila en CSV
            j = (process_type - 1) * n_samples_per_process + i
            write(file_unit, '(I0, ",", I0, ",", F5.2, ",", F4.2, ",", F5.2, ",", F4.2, ",", F4.2, ",", &
                             & F5.2, ",", F5.2, ",", F5.2, ",", F5.2, ",", F6.1, ",", F4.1, ",", F4.1, ",", I0, ",", &
                             & F5.2, ",", F5.2, ",", F5.2, ",", F5.2, ",", F5.2, ",", &
                             & F5.2, ",", F5.2, ",", F5.2, ",", F5.2, ",", F5.2)') &
                   j, process_type, C_pct, H_pct, O_pct, N_pct, S_pct, &
                   cellulose_pct, hemicellulose_pct, lignin_pct, ash_pct, &
                   temperature, pressure, residence_time, gasifying_agent, &
                   CO_yield, H2_yield, CH4_yield, CO2_yield, LHV, &
                   bio_oil_yield, biochar_yield, syngas_yield, &
                   hydrochar_yield, HHV_hydrochar
        end do
    end do

    close(file_unit)
    print *, 'Generación completada. Archivo: data/sargassum_thermochemical_data.csv'

contains

    subroutine normalize_gas_yields(CO, H2, CH4, CO2)
        real(dp), intent(inout) :: CO, H2, CH4, CO2
        real(dp) :: total
        
        total = CO + H2 + CH4 + CO2
        if (total > 0.0_dp) then
            CO = (CO / total) * 60.0_dp    ! Asumir que los gases combustibles suman ~60%
            H2 = (H2 / total) * 60.0_dp
            CH4 = (CH4 / total) * 60.0_dp
            CO2 = (CO2 / total) * 25.0_dp  ! CO2 típicamente 10-25%
        end if
    end subroutine normalize_gas_yields

    subroutine box_muller(mean, std, val)
        real(dp), intent(in) :: mean, std
        real(dp), intent(out) :: val
        real(dp) :: u1, u2
        
        do
            call random_number(u1)
            if (u1 > 0.0_dp) exit
        end do
        call random_number(u2)
        
        val = mean + std * sqrt(-2.0_dp * log(u1)) * cos(2.0_dp * PI * u2)
    end subroutine box_muller

end program sargassum_thermochemical_generator
