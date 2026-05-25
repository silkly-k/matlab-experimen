%% 实验内容2：系统带宽对测量误差的影响

% 参数定义
fs = 1000; L = 1000; t = (0:L-1)/fs;
fc1 = 200;  % 宽频带
fc2 = 50;   % 窄频带
tau1 = 1/(2*pi*fc1); % RC时间常数
tau2 = 1/(2*pi*fc2);

%% 子任务1：截止频率 fc = 200 Hz (宽频带)
% 仿真输出
y1 = zeros(size(signal_actual)); temp1 = 0;
for k = 2:L
    temp1 = temp1 + ((signal_actual(k-1) - temp1) / tau1) * (1/fs);
    y1(k) = temp1;
end

%% 子任务2：截止频率 fc = 50 Hz (窄频带)
% 仿真输出
y2 = zeros(size(signal_actual)); temp2 = 0;
for k = 2:L
    temp2 = temp2 + ((signal_actual(k-1) - temp2) / tau2) * (1/fs);
    y2(k) = temp2;
end

%% 绘图对比
% 时域波形对比
figure('Color', 'w');
subplot(2,1,1);
plot(t, signal_actual, 'Color', [0.7 0 0], 'LineWidth', 0.8); hold on;
plot(t, y1, 'b', 'LineWidth', 1.2);
legend('输入(含噪)', '输出(fc=200Hz)');
title('时域对比：截止频率 200Hz'); grid on;

subplot(2,1,2);
plot(t, signal_actual, 'Color', [0.7 0 0], 'LineWidth', 0.8); hold on;
plot(t, y2, 'g', 'LineWidth', 1.2);
legend('输入(含噪)', '输出(fc=50Hz)');
title('时域对比：截止频率 50Hz'); grid on;

% 频域FFT对比
NFFT = 2^nextpow2(L); f_fft = fs/2 * linspace(0, 1, NFFT/2+1);
Y1_fft = fft(y1, NFFT)/L; Y2_fft = fft(y2, NFFT)/L;
Y_input = fft(signal_actual, NFFT)/L;

figure('Color', 'w');
subplot(2,1,1);
plot(f_fft, 2*abs(Y_input(1:NFFT/2+1)), 'Color', [0.7 0 0]); hold on;
plot(f_fft, 2*abs(Y1(1:NFFT/2+1)), 'b', 'LineWidth', 1.5);
title('频域对比 (FFT)：截止频率 200Hz');
legend('输入频谱', '输出频谱'); grid on; xlim([0 500]);

subplot(2,1,2);
plot(f_fft, 2*abs(Y_input(1:NFFT/2+1)), 'Color', [0.7 0 0]); hold on;
plot(f_fft, 2*abs(Y2(1:NFFT/2+1)), 'g', 'LineWidth', 1.5);
title('频域对比 (FFT)：截止频率 50Hz');
legend('输入频谱', '输出频谱'); grid on; xlim([0 500]);