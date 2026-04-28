clear all;
close all;

% Parameters
T = 10^(-2);
over = 10;
Ts = T/over;
A = 4;
a = [0, 0.5, 1];
colors = ['r', 'g', 'b'];
labels = {'a = 0', 'a = 0.5', 'a = 1'};


%A.1
figure(1);
hold on;
for i = 1:length(a)
    [pulse, t] = srrc_pulse(T, over, A, a(i));
    plot(t, pulse, colors(i));
end

xlabel('Time (sec)')
ylabel('Amplitude')
grid on;
title('SRRC pulses for different roll-off values');
legend(labels);


%A.2 A
Nf = [1024, 2048];
for i = 1: length(Nf)
    figure();
    for j = 1 : length(a)
        [pulse, ~] = srrc_pulse(T, over, A, a(j));
        Fs = 1./Ts;
        f_axis = linspace(-Fs/2, Fs/2, Nf(i)); % Create frequency axis for plotting
        Freq_pulse = fftshift(fft(pulse, Nf(i))) .* Ts; % Fast fourier transform of srrc pulse
        pulse_energy = abs(Freq_pulse).^2;
        hold on;
        plot(f_axis, pulse_energy, colors(j));
    end

    xlabel('Frequency (Hz)');
    ylabel('Energy per unit bandwidth (J/Hz)');
    grid on;
    title(sprintf('Energy Spectral Density for Nf = %i', Nf(i)));
    legend(labels);
    hold off;
end;


%A.2 B
for i = 1: length(Nf)
    figure();
    for j = 1 : length(a)
        [pulse, ~] = srrc_pulse(T, over, A, a(j));
        Fs = 1./Ts;
        f_axis = linspace(-Fs/2, Fs/2, Nf(i));
        Freq_pulse = fftshift(fft(pulse, Nf(i))) .* Ts;
        pulse_energy = abs(Freq_pulse).^2;
        semilogy(f_axis, pulse_energy, colors(j));
        hold on;
    end

    xlabel('Frequency (Hz)');
    ylabel('Energy per unit bandwidth (J/Hz)');
    grid on;
    title(sprintf('Energy Spectral Density for Nf = %i', Nf(i)));
    legend(labels);
    hold off;
end

%A.3
figure(4);
c = T / 10^3;
yline(c, '--w', 'LineWidth', 1.5);

%B.1 1, 2
k_vals = 0:1:3;
[pulse, t] = srrc_pulse(T, over, A, a(2));

figure(6); hold on; grid on;
title('Shifted Pulses: \phi(t - kT)');
xlabel('Time (sec)'); ylabel('Amplitude');

figure(7); hold on; grid on;
title('Product: \phi(t) \cdot \phi(t - kT)');
xlabel('Time (sec)'); ylabel('Amplitude');

colors = lines(length(k_vals)); % Distinct colors for each k value

for i = 1:length(k_vals)
    k = k_vals(i);

    shift_samples = k * over;

    %Align original pulse by padding zeros at the end
    pulse_orig_aligned = [pulse, zeros(1, shift_samples)];

    %Shifted version φ(t - kT) by padding zeros at the beginning
    pulse_shift_aligned = [zeros(1, shift_samples), pulse];

    t_aligned = t(1) + (0:(length(pulse_orig_aligned)-1)) * Ts;

    %φ(t) * φ(t - kT)
    product_sig = pulse_orig_aligned .* pulse_shift_aligned;

    figure(6);
    plot(t_aligned, pulse_shift_aligned, 'Color', colors(i,:), 'LineWidth', 1.5, ...
    'DisplayName', sprintf('\\phi(t - %dT)', k));

    figure(7);
    plot(t_aligned, product_sig, 'Color', colors(i,:), 'LineWidth', 1.5, ...
    'DisplayName', sprintf('k = %d', k));
end

figure(6); legend('show'); hold off;
figure(7); legend('show'); hold off;

%B.1 3
for i = 1 : length(a)
    [pulse, ~] = srrc_pulse(T, over, A, a(i));
    fprintf('Roll - off (a) = %.1f\n', a(i));
    for j = 1 : length(k_vals)
        k = k_vals(j);
        shift_samples = k * over;
        pulse_orig = [pulse, zeros(1, shift_samples)];
        pulse_shift = [zeros(1, shift_samples), pulse];
        integral_val = sum(pulse_orig .* pulse_shift) * Ts;
        fprintf(' k = %d: Integral = %f\n', k, integral_val);
    end
fprintf('---\n');
end

% C.1
N = 100;
b = (sign(randn(N, 1)) + 1) / 2;

% C.2.1
X = bits_to_2PAM(b);

% C.2.2
X_up = zeros(1, length(X) * over); %Upsample sequence
X_up(1:over:end) = X; % Place symbols every T seconds

X_delta = (1/Ts) * X_up; % Scale by 1/Ts to approximate Dirca Impulses
t_delta = (0 : length(X_delta) - 1) * Ts;
figure();
stem(t_delta, X_delta);
title('Simulated Impulse Train X_\delta(t)');
xlabel('Time (sec)');
ylabel('Amplitude');
grid on;

% C.2.3
[pulse, t] = srrc_pulse(T, over, A, a(2));
X_t = conv(X_delta, pulse) * Ts;
t_X = t_delta(1) + t(1) + (0:length(X_t)-1) * Ts;
figure();
plot(t_X, X_t);
title('Transmitted Signal X(t)');
xlabel('Time (sec)');
ylabel('Amplitude');
grid on;

% C.2.4
pulse_matched = fliplr(pulse); %phi(-t)
t_matched = -fliplr(t); %flipped time vector

Z_t = conv(X_t, pulse_matched) * Ts; %Receiver output
t_Z = t_X(1) + t_matched(1) + (0:length(Z_t) -1 ) * Ts;

k_vals = 0:(N-1);
sampling_times = k_vals * T; %Sampling Instants

%Z_sampled = interp1(t_Z, Z_t, sampling_times, 'nearest');

figure();
hold on;
plot(t_Z, Z_t, 'b', 'LineWidth', 1.5, 'DisplayName', 'Z(t)');
stem(sampling_times, X, 'r', 'filled', 'LineWidth', 1.5, 'DisplayName', 'X_k at t=kT');
title('Receiver Output Z(t) vs Transmitted Symbols X_k');
xlabel('Time (sec)');
ylabel('Amplitude');
legend('show');
grid on;
xlim([min(sampling_times)-T, max(sampling_times)+T]);
hold off;