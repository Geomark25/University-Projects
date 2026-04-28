clear all;
close all;

% --- A.1 ---

T = 10^-3; over = 10; Ts = T/over; Fs = 1/Ts;
A = 4; a = 0.5; Nf = 2048;

[pulse, t] = srrc_pulse(T, over, A, a);

Freq_pulse = fftshift(fft(pulse, Nf)) * Ts;
pulse_energy = abs(Freq_pulse).^2;

f_axis = linspace(-Fs/2, Fs/2, Nf);

figure();
semilogy(f_axis, pulse_energy, 'b', 'LineWidth', 1.5);
title('Energy Spectral Density tou SRRC palmou (a=0.5, T=10^{-3})');
xlabel('Frequency (Hz)'); 
ylabel('Energy Spectral Density |\Phi(F)|^2');
grid on;


% --- A.2 ---

N = 100;
b = randi([0 1], N, 1); 

X_n = 1 - 2*b; 

X_up = zeros(length(X_n)*over, 1);
X_up(1:over:end) = X_n;

X_t = conv(X_up, pulse);

t_X = t(1) + (0:(length(X_t)-1)) * Ts;

figure();
plot(t_X, X_t, 'b', 'LineWidth', 1);
title('Waveform X(t) for N=100 2-PAM symbols');
xlabel('Time (sec)');
ylabel('Amplitude X(t)');
grid on;

% --- A.3 ---
T_total = length(X_t) * Ts;
Freq_X = fftshift(fft(X_t, Nf)) * Ts;
Px_F = (abs(Freq_X).^2) / T_total; 

figure();
plot(f_axis, Px_F);
title('Periodogram of a single realization (Linear scale)');
xlabel('Frequency (Hz)'); ylabel('P_X(F)'); grid on;

figure();
semilogy(f_axis, Px_F);
title('Periodogram of a single realization (Log scale)');
xlabel('Frequency (Hz)'); ylabel('P_X(F)'); grid on;

K = 500;
Px_accumulated = zeros(Nf, 1);
sigma_X2 = 1;

for k = 1:K
    b_k = randi([0 1], N, 1);
    X_n_k = 1 - 2*b_k;
    
    X_up_k = zeros(N*over, 1);
    X_up_k(1:over:end) = X_n_k;
    
    X_t_k = conv(X_up_k, pulse);

    Freq_X_k = fftshift(fft(X_t_k, Nf)) * Ts;
    Px_accumulated = Px_accumulated + (abs(Freq_X_k).^2) / T_total;
end

Px_estimated = Px_accumulated / K;

Sx_theoretical = (sigma_X2 / T) * pulse_energy;

figure();
semilogy(f_axis, Px_estimated, 'r', 'LineWidth', 1.2); hold on;
semilogy(f_axis, Sx_theoretical, 'k--', 'LineWidth', 1.5);
title(['PSD Estimation: K = ', num2str(K), ' realizations']);
xlabel('Frequency (Hz)'); ylabel('Power Spectral Density');
legend('Estimated PSD (Averaged Periodograms)', 'Theoretical PSD');
grid on;

% --- A.4 ---
bits_reshaped = reshape(b, 2, N/2)'; 
X_n_4pam = zeros(N/2, 1);

for i = 1:N/2
    pair = bits_reshaped(i, :);
    if     isequal(pair, [0 0]), X_n_4pam(i) = 3;
    elseif isequal(pair, [0 1]), X_n_4pam(i) = 1;
    elseif isequal(pair, [1 1]), X_n_4pam(i) = -1;
    elseif isequal(pair, [1 0]), X_n_4pam(i) = -3;
    end
end

K = 500;
Px_accum_4pam = zeros(1, Nf);
sigma_X2_4pam = 5; 

for k = 1:K
    b_k = randi([0 1], N, 1);
    bits_k_res = reshape(b_k, 2, N/2)';
    X_n_k = zeros(N/2, 1);
    for i = 1:N/2
        p = bits_k_res(i, :);
        if     isequal(p, [0 0]), X_n_k(i) = 3;
        elseif isequal(p, [0 1]), X_n_k(i) = 1;
        elseif isequal(p, [1 1]), X_n_k(i) = -1;
        else,                     X_n_k(i) = -3;
        end
    end

    X_up_k = zeros((N/2) * over, 1);
    X_up_k(1:over:end) = X_n_k;
    X_t_k = conv(X_up_k, pulse);
    
    T_total_4pam = length(X_t_k) * Ts;
    Freq_X_k = fftshift(fft(X_t_k, Nf)) * Ts;
    Px_accum_4pam = Px_accum_4pam + (abs(Freq_X_k).^2) / T_total_4pam;
end

Px_est_4pam = Px_accum_4pam / K;
Sx_theo_4pam = (sigma_X2_4pam / T) * pulse_energy;

figure();
semilogy(f_axis, Px_est_4pam, 'r', 'LineWidth', 1.2); hold on;
semilogy(f_axis, Sx_theo_4pam, 'k--', 'LineWidth', 1.5);
title('4-PAM Estimated vs Theoretical PSD');
xlabel('Frequency (Hz)'); ylabel('Power Spectral Density');
legend('Estimated PSD', 'Theoretical PSD');
grid on;

% --- A.5 ---

T_prime = 2 * T;
over_prime = 2 * over;
[pulse_A5, t_A5] = srrc_pulse(T_prime, over_prime, A, a);

Freq_pulse_A5 = fftshift(fft(pulse_A5, Nf)) * Ts;
pulse_energy_A5 = abs(Freq_pulse_A5).^2;

K = 500;
Px_accum_A5 = zeros(1, Nf);
sigma_X2 = 1;

for k = 1:K
    b_k = randi([0 1], N, 1);
    X_n_k = 1 - 2*b_k;
    
    X_up_k = zeros(N * over_prime, 1);
    X_up_k(1:over_prime:end) = X_n_k;
    
    X_t_k = conv(X_up_k, pulse_A5);
    
    T_total_A5 = length(X_t_k) * Ts;
    Freq_X_k = fftshift(fft(X_t_k, Nf)) * Ts;
    Px_accum_A5 = Px_accum_A5 + (abs(Freq_X_k).^2) / T_total_A5;
end

Px_est_A5 = Px_accum_A5 / K;
Sx_theo_A5 = (sigma_X2 / T_prime) * pulse_energy_A5;

figure();
semilogy(f_axis, Px_est_A5, 'r', 'LineWidth', 1.2); hold on;
semilogy(f_axis, Sx_theo_A5, 'k--', 'LineWidth', 1.5);
title(['PSD Estimation for T'' = 2T (', num2str(T_prime), ' sec)']);
xlabel('Frequency (Hz)'); ylabel('Power Spectral Density');
legend('Estimated PSD', 'Theoretical PSD');
grid on;

% --- B.1.1 ---

F0 = 10;
Ts = 10^-2;
t_axis = 0:Ts:5/F0;
num_realizations = 5;

figure();
hold on;
for i = 1:num_realizations
    X_val = randn();
    Phi_val = 2 * pi * rand();
    
    Y_t = X_val * cos(2*pi*F0*t_axis + Phi_val);
    
    plot(t_axis, Y_t, 'LineWidth', 1.2, 'DisplayName', ['Realization ', num2str(i)]);
end

title('5 Realizations of Y(t) = X cos(2\pi F_0 t + \Phi)');
xlabel('Time (sec)');
ylabel('Amplitude Y(t)');
legend show;
grid on;