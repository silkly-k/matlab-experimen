clc; clear; close all;

% 基本参数
fs = 5000;          % 采样频率
t = 0:1/fs:0.1;     % 时间轴
f0 = 50;            % 基频

% 理想方波（使用 mod 生成）
square_wave = double(mod(t, 1/f0) < 1/(2*f0));

% 不同 N 值
N_list = [5, 21, 201];

% 绘制时域信号
figure;
subplot(4,1,1);
plot(t, square_wave);
title('理想方波');
xlabel('Time (s)'); ylabel('Amplitude');

for k = 1:length(N_list)
    N = N_list(k);
    y = zeros(size(t));
    for n = 1:2:N
        y = y + (4/pi)*(1/n)*sin(2*pi*n*f0*t);
    end
    
    subplot(4,1,k+1);
    plot(t, y);
    title(['正弦叠加合成方波  N = ', num2str(N)]);
    xlabel('Time (s)'); ylabel('Amplitude');
end

% 频域分析代码
L = length(t);
f = (-L/2:L/2-1)*(fs/L);

% 绘制频谱
figure;

% 理想方波 FFT
Y_square = fftshift(abs(fft(square_wave))/L);
subplot(4,1,1);
plot(f, Y_square);
title('理想方波频谱');
xlim([-500 500]);

for k = 1:length(N_list)
    N = N_list(k);
    y = zeros(size(t));
    for n = 1:2:N
        y = y + (4/pi)*(1/n)*sin(2*pi*n*f0*t);
    end
    
    Y = fftshift(abs(fft(y))/L);
    subplot(4,1,k+1);
    plot(f, Y);
    title(['N = ', num2str(N), ' 合成信号频谱']);
    xlim([-500 500]);
end
