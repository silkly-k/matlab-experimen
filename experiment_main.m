%% ============================================================
% 语音信号去噪实验 —— 模拟滤波与数字滤波对比
% 实验内容：
%   1. 语音信号采集与加噪
%   2. 无源RC低通滤波器设计与仿真
%   3. 二阶有源低通滤波器(Sallen-Key)设计与仿真
%   4. 数字滤波算法 (FIR / IIR / 小波去噪 / 谱减法)
%   5. 模拟滤波与数字去噪性能对比 (SNR, MSE)
%% ============================================================
clc; clear; close all;

%% ============================================================
% 第一部分：语音信号采集与加噪
%% ============================================================

% 读取语音文件（优先使用录制的WAV，其次MP3，最后钢琴/小提琴）
if exist('recorded_speech.wav', 'file')
    voice_file = 'recorded_speech.wav';
elseif exist('Ellie Goulding - Love Me Like You Do.mp3', 'file')
    voice_file = 'Ellie Goulding - Love Me Like You Do.mp3';
elseif exist('piano_sound.mp3', 'file')
    voice_file = 'piano_sound.mp3';
elseif exist('violin_sound.mp3', 'file')
    voice_file = 'violin_sound.mp3';
else
    error('未找到任何音频文件。请先运行 record_speech.m 录制语音。');
end

[y_orig, fs_orig] = audioread(voice_file);
% 转单声道
if size(y_orig, 2) > 1
    y_orig = y_orig(:, 1);
end

% 为加快处理，截取前5秒并降采样到16kHz（语音主要能量在4kHz以下）
duration = 5;
N_orig = min(round(duration * fs_orig), length(y_orig));
y_orig = y_orig(1:N_orig);

target_fs = 16000;
if fs_orig ~= target_fs
    y_orig = resample(y_orig, target_fs, fs_orig);
end
fs = target_fs;
y_orig = y_orig / max(abs(y_orig));  % 归一化

N = length(y_orig);
t = (0:N-1)' / fs;

fprintf('=== 语音信号信息 ===\n');
fprintf('采样频率: %d Hz\n', fs);
fprintf('信号时长: %.2f 秒\n', N/fs);
fprintf('采样点数: %d\n', N);

% ---- 绘制原始语音信号波形 ----
figure('Name', '原始语音信号', 'Position', [100, 500, 1000, 400]);
plot(t, y_orig);
xlabel('时间 (s)'); ylabel('幅度');
title('原始语音信号时域波形');
grid on; xlim([0, N/fs]);

% ---- 原始信号频谱 ----
[orig_spectrum, f_orig] = compute_spectrum(y_orig, fs);
figure('Name', '原始语音信号频谱', 'Position', [100, 100, 1000, 400]);
plot(f_orig, orig_spectrum);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('原始语音信号频谱');
grid on; xlim([0, fs/2]);

%% ---- 加入高斯白噪声 ----
% 控制信噪比，使加噪后信号SNR约为5~10 dB（模拟较强噪声环境）
target_snr = 6;  % dB
signal_power = mean(y_orig.^2);
noise_power = signal_power / (10^(target_snr/10));
noise = sqrt(noise_power) * randn(N, 1);
y_noisy = y_orig + noise;

actual_snr = 10 * log10(signal_power / var(noise));
fprintf('\n目标 SNR: %.1f dB, 实际 SNR: %.1f dB\n', target_snr, actual_snr);

% ---- 绘制加噪信号时域波形 ----
figure('Name', '加噪语音信号', 'Position', [500, 500, 1000, 400]);
plot(t, y_noisy);
xlabel('时间 (s)'); ylabel('幅度');
title(sprintf('加噪语音信号时域波形 (SNR = %.1f dB)', actual_snr));
grid on; xlim([0, N/fs]);

% ---- 加噪信号频谱 ----
[noisy_spectrum, f_noisy] = compute_spectrum(y_noisy, fs);
figure('Name', '加噪语音信号频谱', 'Position', [500, 100, 1000, 400]);
plot(f_noisy, noisy_spectrum);
hold on;
plot(f_orig, orig_spectrum, 'r', 'LineWidth', 0.8);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('加噪语音信号频谱 (红色: 原始信号)');
legend('加噪信号', '原始信号');
grid on; xlim([0, fs/2]);

% ---- 播放对比 ----
fprintf('\n播放原始语音...\n');
sound(y_orig, fs); pause(duration + 0.5);
fprintf('播放加噪语音...\n');
sound(y_noisy, fs); pause(duration + 0.5);

%% ============================================================
% 第二部分：无源RC低通滤波器设计与仿真
% 截止频率 fc = 3000 Hz，滤除3kHz以上噪声
%% ============================================================

fc_rc = 3000;  % 截止频率 3kHz

% RC滤波器传递函数: H(s) = 1/(1 + RCs), 其中 RC = 1/(2*pi*fc)
RC = 1 / (2 * pi * fc_rc);

% 使用双线性变换将模拟滤波器转为数字滤波器进行仿真
% H(s) = 1/(1 + tau*s), tau = RC
[b_rc, a_rc] = bilinear(1, [RC, 1], fs);

% 对加噪信号进行RC滤波
y_rc = filter(b_rc, a_rc, y_noisy);

% ---- RC滤波器频率响应 ----
figure('Name', 'RC低通滤波器频率响应', 'Position', [200, 200, 1000, 500]);

% 幅频特性
subplot(2,1,1);
[h_rc, w_rc] = freqz(b_rc, a_rc, 4096, fs);
plot(w_rc, 20*log10(abs(h_rc)), 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title(sprintf('RC低通滤波器幅频特性 (f_c = %.0f Hz)', fc_rc));
grid on; xlim([0, fs/2]);
yline(-3, 'r--', '-3dB');
xline(fc_rc, 'r--');
legend('幅频响应', '-3dB线', '截止频率');

% 相频特性
subplot(2,1,2);
plot(w_rc, unwrap(angle(h_rc))*180/pi, 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('相位 (度)');
title('RC低通滤波器相频特性');
grid on; xlim([0, fs/2]);

% ---- RC滤波后时域对比 ----
figure('Name', 'RC滤波结果', 'Position', [300, 300, 1000, 600]);
subplot(3,1,1);
plot(t, y_orig); title('原始语音信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

subplot(3,1,2);
plot(t, y_noisy); title('加噪语音信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

subplot(3,1,3);
plot(t, y_rc); title('RC低通滤波后信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

% ---- RC滤波后频谱对比 ----
[rc_spectrum, f_rc] = compute_spectrum(y_rc, fs);
figure('Name', 'RC滤波频谱对比', 'Position', [400, 400, 1000, 400]);
plot(f_noisy, noisy_spectrum, 'b', 'LineWidth', 0.6); hold on;
plot(f_rc, rc_spectrum, 'r', 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('RC低通滤波频谱对比 (蓝色: 滤波前, 红色: 滤波后)');
legend('滤波前', 'RC滤波后');
grid on; xlim([0, fs/2]);

% RC滤波指标
snr_rc = compute_snr(y_orig, y_rc);
mse_rc = compute_mse(y_orig, y_rc);
fprintf('\n=== RC低通滤波器 (f_c=%.0f Hz) ===\n', fc_rc);
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_rc, mse_rc);

%% ============================================================
% 第三部分：二阶有源低通滤波器 (Sallen-Key拓扑)
% 传递函数: H(s) = 1 / (s^2*R1*R2*C1*C2 + s*(R1*C1+R2*C1) + 1)
% 截止频率: f_c = 1/(2*pi*sqrt(R1*R2*C1*C2))
% 设计 Q = 1/sqrt(2) ≈ 0.707 (Butterworth响应，最平坦)
%% ============================================================

fc_sk = 3000;  % 截止频率 3kHz
Q_target = 1/sqrt(2);  % Butterworth Q值

% Sallen-Key 设计方程 (等值元件设计: R1 = R2 = R, C1 = 2*Q*C, C2 = C/(2*Q))
% 或采用等R等C简化设计
R1 = 10000;          % 10kΩ
R2 = 10000;          % 10kΩ  (等R设计)
C_val = 1 / (2*pi*fc_sk*sqrt(R1*R2));
C1 = 2 * Q_target * C_val;
C2 = C_val / (2 * Q_target);

fprintf('\n=== Sallen-Key滤波器元件参数 ===\n');
fprintf('R1 = %.0f Ω, R2 = %.0f Ω\n', R1, R2);
fprintf('C1 = %.2f nF, C2 = %.2f nF\n', C1*1e9, C2*1e9);
fprintf('设计截止频率: %.1f Hz\n', 1/(2*pi*sqrt(R1*R2*C1*C2)));

% Sallen-Key传递函数系数
% H(s) = K / (s^2*R1*R2*C1*C2 + s*(R1*C1 + R2*C1) + 1)
% 对于单位增益 Sallen-Key: K = 1
num_sk = 1;
den_sk = [R1*R2*C1*C2, (R1*C1 + R2*C1), 1];

% 双线性变换转数字滤波器
[b_sk, a_sk] = bilinear(num_sk, den_sk, fs);

% 对加噪信号进行Sallen-Key滤波
y_sk = filter(b_sk, a_sk, y_noisy);

% ---- Sallen-Key频率响应 ----
figure('Name', 'Sallen-Key滤波器频率响应', 'Position', [250, 250, 1000, 500]);
subplot(2,1,1);
[h_sk, w_sk] = freqz(b_sk, a_sk, 4096, fs);
plot(w_sk, 20*log10(abs(h_sk)), 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title(sprintf('Sallen-Key二阶低通滤波器幅频特性 (f_c = %.0f Hz, Q = %.2f)', fc_sk, Q_target));
grid on; xlim([0, fs/2]);
yline(-3, 'r--'); xline(fc_sk, 'r--');
legend('幅频响应', '-3dB线', '截止频率');

subplot(2,1,2);
plot(w_sk, unwrap(angle(h_sk))*180/pi, 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('相位 (度)');
title('Sallen-Key滤波器相频特性');
grid on; xlim([0, fs/2]);

% ---- Sallen-Key滤波后时域对比 ----
figure('Name', 'Sallen-Key滤波结果', 'Position', [350, 350, 1000, 600]);
subplot(3,1,1);
plot(t, y_orig); title('原始语音信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

subplot(3,1,2);
plot(t, y_noisy); title('加噪语音信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

subplot(3,1,3);
plot(t, y_sk); title('Sallen-Key滤波后信号');
xlabel('时间 (s)'); ylabel('幅度'); xlim([0, N/fs]); grid on;

% ---- Sallen-Key滤波频谱对比 ----
[sk_spectrum, f_sk] = compute_spectrum(y_sk, fs);
figure('Name', 'Sallen-Key滤波频谱对比', 'Position', [450, 450, 1000, 400]);
plot(f_noisy, noisy_spectrum, 'b', 'LineWidth', 0.6); hold on;
plot(f_sk, sk_spectrum, 'r', 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('Sallen-Key滤波频谱对比 (蓝色: 滤波前, 红色: 滤波后)');
legend('滤波前', 'Sallen-Key滤波后');
grid on; xlim([0, fs/2]);

% Sallen-Key滤波指标
snr_sk = compute_snr(y_orig, y_sk);
mse_sk = compute_mse(y_orig, y_sk);
fprintf('\n=== Sallen-Key二阶低通滤波器 (f_c=%.0f Hz) ===\n', fc_sk);
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_sk, mse_sk);

%% ============================================================
% 第四部分：RC与Sallen-Key幅频特性对比
%% ============================================================

figure('Name', 'RC vs Sallen-Key 幅频特性对比', 'Position', [300, 300, 1000, 500]);
plot(w_rc, 20*log10(abs(h_rc)), 'b', 'LineWidth', 1.2); hold on;
plot(w_sk, 20*log10(abs(h_sk)), 'r', 'LineWidth', 1.2);
yline(-3, 'k--');
xline(fc_rc, 'k--');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title(sprintf('RC一阶 vs Sallen-Key二阶 幅频特性对比 (f_c = %.0f Hz)', fc_rc));
legend('RC一阶 (-20dB/dec)', 'Sallen-Key二阶 (-40dB/dec)', '-3dB线', '截止频率');
grid on; xlim([0, 10000]);

%% ============================================================
% 第五部分：数字滤波算法
% 5.1 FIR低通滤波器 (窗函数法)
% 5.2 IIR Butterworth低通滤波器
% 5.3 小波阈值去噪
% 5.4 谱减法
%% ============================================================

%% ---- 5.1 FIR低通滤波器 (Kaiser窗) ----
fc_fir = 3000 / (fs/2);  % 归一化截止频率
fir_order = 100;
b_fir = fir1(fir_order, fc_fir, kaiser(fir_order+1, 5));
a_fir = 1;
y_fir = filter(b_fir, a_fir, y_noisy);

snr_fir = compute_snr(y_orig, y_fir);
mse_fir = compute_mse(y_orig, y_fir);
fprintf('\n=== FIR低通滤波器 (Kaiser窗, 阶数=%d) ===\n', fir_order);
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_fir, mse_fir);

%% ---- 5.2 IIR Butterworth低通滤波器 ----
fc_iir = 3000 / (fs/2);  % 归一化截止频率
iir_order = 6;
[b_iir, a_iir] = butter(iir_order, fc_iir, 'low');
y_iir = filter(b_iir, a_iir, y_noisy);

snr_iir = compute_snr(y_orig, y_iir);
mse_iir = compute_mse(y_orig, y_iir);
fprintf('\n=== IIR Butterworth低通滤波器 (阶数=%d) ===\n', iir_order);
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_iir, mse_iir);

%% ---- 5.3 小波阈值去噪 ----
% 使用 db4 小波基，5层分解，软阈值
wavelet_name = 'db4';
level = 5;

% 检查是否有 Wavelet Toolbox
if exist('wdenoise', 'file')
    % 使用内置小波去噪函数 (R2017b+)
    y_wavelet = wdenoise(y_noisy, level, ...
        'Wavelet', wavelet_name, ...
        'DenoisingMethod', 'Bayes', ...
        'ThresholdRule', 'Soft');
elseif exist('wden', 'file')
    % 使用传统 wden 函数
    % 获取小波分解
    [C, L] = wavedec(y_noisy, level, wavelet_name);
    % 估计噪声标准差 (使用第一层细节系数)
    sigma = median(abs(detcoef(C, L, 1))) / 0.6745;
    % 通用阈值
    thr = sigma * sqrt(2 * log(N));
    % 软阈值处理
    C_thr = wthresh(C, 's', thr);
    y_wavelet = waverec(C_thr, L, wavelet_name);
    % 确保长度一致
    y_wavelet = y_wavelet(1:N);
else
    % 无小波工具箱时，用简单的移动平均代替
    fprintf('警告: 未检测到 Wavelet Toolbox，使用移动平均代替小波去噪\n');
    win_len = round(fs / fc_fir / 2);
    y_wavelet = movmean(y_noisy, win_len);
end

snr_wavelet = compute_snr(y_orig, y_wavelet);
mse_wavelet = compute_mse(y_orig, y_wavelet);
fprintf('\n=== 小波阈值去噪 (db4, %d层) ===\n', level);
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_wavelet, mse_wavelet);

%% ---- 5.4 谱减法 ----
y_ss = spectral_subtraction(y_noisy, fs, 0.025, 0.01);

snr_ss = compute_snr(y_orig, y_ss);
mse_ss = compute_mse(y_orig, y_ss);
fprintf('\n=== 谱减法 ===\n');
fprintf('SNR: %.2f dB, MSE: %.6f\n', snr_ss, mse_ss);

%% ============================================================
% 第六部分：所有方法综合对比
%% ============================================================

% ---- 时域波形对比 ----
figure('Name', '所有去噪方法时域对比', 'Position', [50, 50, 1400, 900]);

plot_order = {'原始信号', '加噪信号', 'RC低通 (模拟)', ...
              'Sallen-Key (模拟)', 'FIR低通', 'IIR Butterworth', ...
              '小波去噪', '谱减法'};
signals = {y_orig, y_noisy, y_rc, y_sk, y_fir, y_iir, y_wavelet, y_ss};

for i = 1:8
    subplot(4, 2, i);
    plot(t, signals{i});
    title(plot_order{i});
    xlabel('时间 (s)'); ylabel('幅度');
    xlim([0, min(0.05, N/fs)]); grid on;  % 显示前50ms细节
end

% ---- 频谱对比 ----
figure('Name', '所有去噪方法频谱对比', 'Position', [100, 100, 1400, 900]);
for i = 1:8
    subplot(4, 2, i);
    [spec, f_spec] = compute_spectrum(signals{i}, fs);
    plot(f_spec, spec);
    if i == 1
        title(sprintf('%s (频谱)', plot_order{i}));
    else
        hold on;
        [orig_spec, ~] = compute_spectrum(y_orig, fs);
        plot(f_spec, orig_spec, 'r', 'LineWidth', 0.5);
        title(sprintf('%s (红色=原始)', plot_order{i}));
    end
    xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
    xlim([0, fs/2]); grid on;
end

% ---- 幅频特性对比 (滤波器频率响应) ----
figure('Name', '滤波器频率响应对比', 'Position', [200, 200, 1000, 500]);

% RC
[h_rc_full, w_rc_full] = freqz(b_rc, a_rc, 4096, fs);
plot(w_rc_full, 20*log10(abs(h_rc_full)), 'b', 'LineWidth', 1.2); hold on;

% Sallen-Key
[h_sk_full, w_sk_full] = freqz(b_sk, a_sk, 4096, fs);
plot(w_sk_full, 20*log10(abs(h_sk_full)), 'r', 'LineWidth', 1.2);

% FIR
[h_fir_full, w_fir_full] = freqz(b_fir, a_fir, 4096, fs);
plot(w_fir_full, 20*log10(abs(h_fir_full)), 'g', 'LineWidth', 1.2);

% IIR
[h_iir_full, w_iir_full] = freqz(b_iir, a_iir, 4096, fs);
plot(w_iir_full, 20*log10(abs(h_iir_full)), 'm', 'LineWidth', 1.2);

yline(-3, 'k--');
xline(3000, 'k--', 'f_c=3kHz');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('各滤波器幅频特性对比');
legend('RC一阶 (-20dB/dec)', 'Sallen-Key二阶 (-40dB/dec)', ...
       sprintf('FIR %d阶', fir_order), sprintf('IIR Butterworth %d阶', iir_order), ...
       '-3dB');
grid on; xlim([0, 8000]); ylim([-60, 5]);

% ---- SNR/MSE柱状图对比 ----
methods = {'RC低通', 'Sallen-Key', 'FIR', 'IIR', '小波去噪', '谱减法'};
snr_values = [snr_rc, snr_sk, snr_fir, snr_iir, snr_wavelet, snr_ss];
mse_values = [mse_rc, mse_sk, mse_fir, mse_iir, mse_wavelet, mse_ss];

figure('Name', '去噪性能对比', 'Position', [300, 300, 1000, 500]);

subplot(1,2,1);
b1 = bar(snr_values, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', methods);
ylabel('SNR (dB)'); title('输出信噪比对比 (越高越好)');
grid on;
% 标注数值
for i = 1:length(snr_values)
    text(i, snr_values(i) + 0.2, sprintf('%.1f', snr_values(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

subplot(1,2,2);
b2 = bar(mse_values, 'FaceColor', [0.8 0.4 0.3]);
set(gca, 'XTickLabel', methods);
ylabel('MSE'); title('均方误差对比 (越低越好)');
grid on;
for i = 1:length(mse_values)
    text(i, mse_values(i) + max(mse_values)*0.02, sprintf('%.4f', mse_values(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

% ---- 打印汇总表 ----
fprintf('\n\n========== 去噪性能汇总 ==========\n');
fprintf('%-20s %10s %12s\n', '方法', 'SNR (dB)', 'MSE');
fprintf('%-20s %10s %12s\n', '--------------------', '--------', '------------');
fprintf('%-20s %10.2f %12.6f\n', 'RC低通 (模拟)', snr_rc, mse_rc);
fprintf('%-20s %10.2f %12.6f\n', 'Sallen-Key (模拟)', snr_sk, mse_sk);
fprintf('%-20s %10.2f %12.6f\n', 'FIR 低通', snr_fir, mse_fir);
fprintf('%-20s %10.2f %12.6f\n', 'IIR Butterworth', snr_iir, mse_iir);
fprintf('%-20s %10.2f %12.6f\n', '小波去噪', snr_wavelet, mse_wavelet);
fprintf('%-20s %10.2f %12.6f\n', '谱减法', snr_ss, mse_ss);
fprintf('==================================\n');

fprintf('\n实验完成。\n');

%% ============================================================
% 辅助函数
%% ============================================================

function [spectrum_dB, f_axis] = compute_spectrum(signal, fs)
    % 计算单边幅度谱 (dB)
    N = length(signal);
    Y = fft(signal);
    Y_mag = abs(Y(1:floor(N/2)+1)) / N;
    Y_mag(2:end-1) = 2 * Y_mag(2:end-1);  % 单边谱补偿
    % 避免log(0)，加小值
    spectrum_dB = 20 * log10(max(Y_mag, 1e-10));
    f_axis = (0:floor(N/2))' * (fs / N);
end

function snr_val = compute_snr(original, processed)
    % 计算信噪比 SNR = 10*log10(P_signal / P_noise)
    noise = original - processed;
    signal_power = mean(original.^2);
    noise_power = mean(noise.^2);
    if noise_power < 1e-15
        snr_val = 100;  % 几乎无噪声
    else
        snr_val = 10 * log10(signal_power / noise_power);
    end
end

function mse_val = compute_mse(original, processed)
    % 计算均方误差
    mse_val = mean((original - processed).^2);
end

function y_denoised = spectral_subtraction(noisy_signal, fs, frame_len, overlap_len)
    % 谱减法语音增强
    % 输入:
    %   noisy_signal  - 带噪信号
    %   fs            - 采样率
    %   frame_len     - 帧长 (秒)
    %   overlap_len   - 帧重叠 (秒)
    % 输出:
    %   y_denoised    - 去噪后信号

    x = noisy_signal(:);
    N = length(x);

    frame_samples = round(frame_len * fs);
    overlap_samples = round(overlap_len * fs);
    hop = frame_samples - overlap_samples;

    win = hamming(frame_samples);

    % 估计噪声功率谱 (取前几帧作为噪声估计)
    noise_frames = min(10, floor((N - frame_samples) / hop));
    noise_psd = zeros(frame_samples, 1);
    for k = 1:noise_frames
        idx = (k-1)*hop + (1:frame_samples);
        segment = x(idx) .* win;
        noise_psd = noise_psd + abs(fft(segment)).^2;
    end
    noise_psd = noise_psd / noise_frames;

    % STFT 处理
    num_frames = floor((N - frame_samples) / hop) + 1;
    Y_out = zeros(frame_samples, num_frames);

    alpha = 2;      % 过减因子
    beta = 0.002;   % 频谱下限因子

    for k = 1:num_frames
        idx = (k-1)*hop + (1:frame_samples);
        segment = x(idx) .* win;
        X_mag = abs(fft(segment));
        X_phase = angle(fft(segment));

        % 谱减
        X_power = X_mag.^2;
        gain = max(1 - alpha * noise_psd ./ max(X_power, 1e-10), beta);
        Y_mag = X_mag .* sqrt(gain);

        Y_out(:, k) = Y_mag .* exp(1j * X_phase);
    end

    % Overlap-Add 重构
    y_denoised = zeros(N, 1);
    win_sum = zeros(N, 1);
    for k = 1:num_frames
        idx = (k-1)*hop + (1:frame_samples);
        y_frame = real(ifft(Y_out(:, k)));
        y_denoised(idx) = y_denoised(idx) + y_frame .* win;
        win_sum(idx) = win_sum(idx) + win.^2;
    end
    y_denoised = y_denoised ./ max(win_sum, 1e-10);

    % 确保输出信号长度与输入一致
    y_denoised = y_denoised(1:N);
end
