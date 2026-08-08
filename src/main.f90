! ==============================================================================
! Programa: sargassum_dynamic_generator.f90
! Descripción: Genera series temporales sintéticas (t=1..46 días) para la 
!              fracción líquida (LF) de Sargassum, usando cinética de Gompertz
! ==============================================================================
program sargassum_dynamic_generator
    implicit none

    ! Parámetros globales de precisión y constantes
    integer, parameter :: dp = kind(1.0d0)
    integer, parameter :: n_samples = 500
    integer, parameter :: t_max = 46
    real(dp), parameter :: PI = 3.141592653589793_dp
    real(dp), parameter :: E_NUM = 2.718281828459045_dp
    
    ! Variables de bucle y archivos
    integer :: i, t, file_unit
    real(dp) :: gauss_noise
    
    ! Variables de Sustrato (Fracción Líquida - LF)
    real(dp) :: VS, C_cont, H_cont, N_cont, Phenols, Temp_base
    
    ! Variables Cinéticas (Gompertz Modificado)
    real(dp) :: BMP_max, R_max, lambda, BMP_t, daily_CH4
    real(dp) :: prev_BMP
    
    ! Variables de Reactor (Pseudo-ADM1 Sensors)
    real(dp) :: VFA, pH_val, Temp_val
    
    ! Semilla aleatoria
    integer :: seed_size
    integer, allocatable :: seed(:)
    real(dp) :: rand_raw ! Auxiliar para mapear random_number a dp

    ! Inicializar generador de números aleatorios
    call random_seed(size=seed_size)
    allocate(seed(seed_size))
    seed = 12345 
    call random_seed(put=seed)

    ! Abrir archivo de salida apuntando de forma estricta a nuestra carpeta data/
    file_unit = 10
    open(unit=file_unit, file='data/sargassum_dynamic_data.csv', status='replace', action='write')
    
    ! Escribir encabezados
    write(file_unit, '(A)') 'sample_id,time_day,VS_g_L,C_pct,H_pct,N_pct,Phenols_g_L,' &
                          // 'Cumulative_CH4_L_kg_VS,Daily_CH4_L_kg_VS,pH,VFA_mg_L,Temp_C'

    print *, 'Iniciando generación de datos dinámicos para Sargassum (LF)...'

    do i = 1, n_samples
        ! 1. Generación de Sustrato Sintético (Doble Precisión)
        call random_number(rand_raw); VS = 3.0_dp + rand_raw * 12.0_dp
        call random_number(rand_raw); C_cont = 27.0_dp + rand_raw * 3.0_dp
        call random_number(rand_raw); H_cont = 3.4_dp + rand_raw * 0.6_dp
        call random_number(rand_raw); N_cont = 1.5_dp + rand_raw * 1.5_dp
        call random_number(rand_raw); Phenols = 0.1_dp + rand_raw * 1.5_dp
        
        Temp_base = 35.0_dp

        ! 2. Muestreo de Parámetros Cinéticos
        call random_number(rand_raw); BMP_max = 120.0_dp + rand_raw * 60.0_dp
        call random_number(rand_raw); R_max = 4.0_dp + rand_raw * 4.0_dp
        call random_number(rand_raw); lambda = -5.0_dp + rand_raw * 7.0_dp

        prev_BMP = 0.0_dp

        ! 3. Bucle Temporal
        do t = 1, t_max
            ! Cinética de Gompertz Modificado
            BMP_t = BMP_max * exp(-exp((R_max * E_NUM / BMP_max) * (lambda - real(t, dp)) + 1.0_dp))
            daily_CH4 = BMP_t - prev_BMP
            if (daily_CH4 < 0.0_dp) daily_CH4 = 0.0_dp
            prev_BMP = BMP_t

            ! VFA: Pico temprano y decaimiento exponencial
            VFA = 1500.0_dp * exp(-0.1_dp * abs(real(t, dp) - 7.0_dp)) 
            
            ! pH: Correlación inversa
            pH_val = 7.2_dp - (0.7_dp * (VFA / 1500.0_dp)) 
            
            ! Temperatura con ruido blanco de Box-Muller
            call box_muller(0.0_dp, 0.3_dp, gauss_noise)
            Temp_val = Temp_base + gauss_noise

            ! Ruido inducido por los sensores
            call box_muller(0.0_dp, 2.0_dp, gauss_noise)
            BMP_t = BMP_t + gauss_noise
            if (BMP_t < 0.0_dp) BMP_t = 0.0_dp
            
            call box_muller(0.0_dp, 0.5_dp, gauss_noise)
            VFA = VFA + gauss_noise
            if (VFA < 0.0_dp) VFA = 0.0_dp
            
            call box_muller(0.0_dp, 0.05_dp, gauss_noise)
            pH_val = pH_val + gauss_noise

            ! Escribir registros en formato CSV estándar
            write(file_unit, '(I0, ",", I0, ",", F6.2, ",", F5.2, ",", F5.2, ",", F5.2, ",", F5.2, &
                             & ",", F8.2, ",", F8.2, ",", F5.3, ",", F8.2, ",", F5.2)') &
                   i, t, VS, C_cont, H_cont, N_cont, Phenols, BMP_t, daily_CH4, pH_val, VFA, Temp_val
        end do
        
        if (mod(i, 100) == 0) print *, 'Muestras generadas: ', i, '/', n_samples
    end do

    close(file_unit)
    print *, 'Generación completada de forma estricta. Archivo: data/sargassum_dynamic_data.csv'

contains

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

end program sargassum_dynamic_generator
