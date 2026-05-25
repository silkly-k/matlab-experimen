clc; clear; close all;

% 使用你提供的MP3文件路径
file_path = 'D:/matlab experiment/Ellie Goulding - Love Me Like You Do.mp3'; 

% 读入MP3格式语音信号
[y, fs] = audioread(file_path);  % 使用完整路径

% 如果是立体声，取其中一个声道进行分析
if size(y, 2) > 1
    y = y(:, 1);  % 取左声道
end

% 显示音频信息
fprintf('音频信息:\n');
fprintf('采样频率: %.0f Hz\n', fs);
fprintf('总时长: %.2f 秒\n', length(y)/fs);
fprintf('总采样点数: %d\n', length(y));

% 截取前2秒进行分析，避免数据量过大
duration = 2;  % 只取2秒
samples_to_take = min(round(duration * fs), length(y));
y = y(1:samples_to_take);  % 截取前2秒的数据

fprintf('分析信号时长: %.2f 秒\n', length(y)/fs);

% 信号处理
y_amp = 1.5 * y;              % 放大1.5倍
y_rev = flip(y);              % 反转信号
y_comp = 0.8 * y;             % 轻微压缩
y_noise = y + 0.02*randn(size(y));  % 加噪声

% 绘制时域信号
figure;
subplot(5,1,1); plot(y); title('原语音信号'); 
xlabel('采样点'); ylabel('幅度');
ylim([-1, 1]); grid on;

subplot(5,1,2); plot(y_amp); title('放大后的语音信号'); 
xlabel('采样点'); ylabel('幅度');
ylim([-1.5, 1.5]); grid on;

subplot(5,1,3); plot(y_rev); title('反转后的语音信号'); 
xlabel('采样点'); ylabel('幅度');
ylim([-1, 1]); grid on;

subplot(5,1,4); plot(y_comp); title('压缩后的语音信号'); 
xlabel('采样点'); ylabel('幅度');
ylim([-0.8, 0.8]); grid on;

subplot(5,1,5); plot(y_noise); title('加噪声后的语音信号'); 
xlabel('采样点'); ylabel('幅度');
ylim([-1, 1]); grid on;

% ===================== FFT频谱分析 =====================
% 直接使用整个2秒信号进行分析，但为了频率分辨率，我们可以使用较长的FFT
% 设置FFT长度
N = min(8192, length(y));  % 使用8192点FFT，或信号长度（取较小者）

% 如果信号长度大于N，则截取前N个点
if length(y) > N
    y_segment = y(1:N);
    y_amp_segment = y_amp(1:N);
    y_rev_segment = y_rev(1:N);
    y_comp_segment = y_comp(1:N);
    y_noise_segment = y_noise(1:N);
else
    % 如果信号长度不足N，则补零
    y_segment = [y; zeros(N-length(y), 1)];
    y_amp_segment = [y_amp; zeros(N-length(y_amp), 1)];
    y_rev_segment = [y_rev; zeros(N-length(y_rev), 1)];
    y_comp_segment = [y_comp; zeros(N-length(y_comp), 1)];
    y_noise_segment = [y_noise; zeros(N-length(y_noise), 1)];
end

% 进行FFT
Y = fft(y_segment, N);
Y_amp = fft(y_amp_segment, N);
Y_rev = fft(y_rev_segment, N);
Y_comp = fft(y_comp_segment, N);
Y_noise = fft(y_noise_segment, N);

% 计算幅度谱
Y_mag = abs(Y);
Y_amp_mag = abs(Y_amp);
Y_rev_mag = abs(Y_rev);
Y_comp_mag = abs(Y_comp);
Y_noise_mag = abs(Y_noise);

% 创建频率轴
f = (0:N-1) * (fs/N);

% 只取一半（对称性）
if mod(N, 2) == 0
    f_half = f(1:N/2+1);
    Y_mag = Y_mag(1:N/2+1);
    Y_amp_mag = Y_amp_mag(1:N/2+1);
    Y_rev_mag = Y_rev_mag(1:N/2+1);
    Y_comp_mag = Y_comp_mag(1:N/2+1);
    Y_noise_mag = Y_noise_mag(1:N/2+1);
else
    f_half = f(1:(N+1)/2);
    Y_mag = Y_mag(1:(N+1)/2);
    Y_amp_mag = Y_amp_mag(1:(N+1)/2);
    Y_rev_mag = Y_rev_mag(1:(N+1)/2);
    Y_comp_mag = Y_comp_mag(1:(N+1)/2);
    Y_noise_mag = Y_noise_mag(1:(N+1)/2);
end

% 转换为dB单位
Y_dB = 20*log10(Y_mag/max(Y_mag));
Y_amp_dB = 20*log10(Y_amp_mag/max(Y_amp_mag));
Y_rev_dB = 20*log10(Y_rev_mag/max(Y_rev_mag));
Y_comp_dB = 20*log10(Y_comp_mag/max(Y_comp_mag));
Y_noise_dB = 20*log10(Y_noise_mag/max(Y_noise_mag));

% 绘制频谱图
figure;
subplot(5,1,1); 
plot(f_half, Y_dB); 
title('原语音信号频谱'); 
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

subplot(5,1,2); 
plot(f_half, Y_amp_dB); 
title('放大后的语音信号频谱'); 
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

subplot(5,1,3); 
plot(f_half, Y_rev_dB); 
title('反转后的语音信号频谱'); 
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

subplot(5,1,4); 
plot(f_half, Y_comp_dB); 
title('压缩后的语音信号频谱'); 
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

subplot(5,1,5); 
plot(f_half, Y_noise_dB); 
title('加噪声后的语音信号频谱'); 
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

% 对比分析时域变化和频谱对应关系
figure('Position', [100, 100, 1200, 600]);

% 绘制原信号和放大信号的对比
subplot(2,3,1);
plot(y_segment(1:min(1000, length(y_segment))), 'b', 'LineWidth', 1);
title('原信号 (时域前1000点)');
xlabel('采样点'); ylabel('幅度');
grid on;

subplot(2,3,4);
plot(f_half, Y_dB, 'b', 'LineWidth', 1);
title('原信号频谱');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

% 绘制放大信号
subplot(2,3,2);
plot(y_amp_segment(1:min(1000, length(y_amp_segment))), 'r', 'LineWidth', 1);
title('放大信号 (时域前1000点)');
xlabel('采样点'); ylabel('幅度');
grid on;

subplot(2,3,5);
plot(f_half, Y_amp_dB, 'r', 'LineWidth', 1);
title('放大信号频谱');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

% 绘制加噪声信号
subplot(2,3,3);
plot(y_noise_segment(1:min(1000, length(y_noise_segment))), 'g', 'LineWidth', 1);
title('加噪声信号 (时域前1000点)');
xlabel('采样点'); ylabel('幅度');
grid on;

subplot(2,3,6);
plot(f_half, Y_noise_dB, 'g', 'LineWidth', 1);
title('加噪声信号频谱');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
xlim([0, min(4000, fs/2)]); ylim([-60, 0]);
grid on;

% 输出分析结果
fprintf('\n频谱分析结果:\n');
fprintf('FFT长度: %d 点\n', N);
fprintf('频率分辨率: %.2f Hz\n', fs/N);
fprintf('显示频率范围: 0-%.0f Hz\n', min(4000, fs/2));

fprintf('\n时域变化与频谱对应关系:\n');
fprintf('1. 信号放大/压缩: 时域信号幅度按比例变化，频谱形状不变\n');
fprintf('   频谱中所有频率分量按相同比例变化\n');
fprintf('2. 信号反转: 时域信号时间顺序反转，频谱形状不变\n');
fprintf('   幅度谱不受时间反转影响\n');
fprintf('3. 加噪声: 时域信号添加随机波动，频谱添加均匀噪声基底\n');
fprintf('   整个频带的噪声水平提升\n');

% 计算信噪比
signal_power = mean(y.^2);
noise_power = 0.02^2;  % 噪声方差
snr = 10*log10(signal_power/noise_power);
fprintf('\n信噪比(SNR): %.2f dB\n', snr);

% 播放原语音与处理后的语音
if fs <= 48000  % 确保采样率在合理范围内
    fprintf('\n播放语音信号 (各1.5秒)...\n');
    sound(y(1:min(1.5*fs, length(y))), fs); 
    pause(2);
    sound(y_amp(1:min(1.5*fs, length(y_amp))), fs); 
    pause(2);
    sound(y_rev(1:min(1.5*fs, length(y_rev))), fs); 
    pause(2);
    sound(y_comp(1:min(1.5*fs, length(y_comp))), fs); 
    pause(2);
    sound(y_noise(1:min(1.5*fs, length(y_noise))), fs);
else
    fprintf('\n采样率过高，跳过音频播放\n');
end