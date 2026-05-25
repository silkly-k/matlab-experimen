%% ============================================================
% 实时语音录制
% 用于实验第一部分：录制或导入语音信号
%% ============================================================
clc; clear; close all;

fs = 16000;          % 采样率 16kHz
duration = 5;        % 录制时长 5秒
nbits = 16;          % 量化位数
nchannels = 1;       % 单声道

fprintf('===== 语音录制 =====\n');
fprintf('采样率: %d Hz\n', fs);
fprintf('录制时长: %d 秒\n', duration);
fprintf('按任意键开始录制...\n');
pause;

% 创建录音对象
recObj = audiorecorder(fs, nbits, nchannels);
fprintf('正在录制... 请讲话\n');
recordblocking(recObj, duration);
fprintf('录制完成!\n');

% 获取录音数据
y = getaudiodata(recObj);

% 保存为WAV文件
audiowrite('recorded_speech.wav', y, fs);
fprintf('已保存到 recorded_speech.wav\n');

% ---- 绘制录制信号 ----
t = (0:length(y)-1)' / fs;

figure('Name', '录制语音信号', 'Position', [200, 300, 1000, 500]);

subplot(2,1,1);
plot(t, y);
xlabel('时间 (s)'); ylabel('幅度');
title('录制语音信号时域波形');
grid on;

% 频谱
subplot(2,1,2);
N_fft = 4096;
Y = abs(fft(y, N_fft));
f = (0:N_fft/2-1)' * (fs / N_fft);
Y_dB = 20*log10(Y(1:N_fft/2) / max(Y(1:N_fft/2)));
plot(f, Y_dB);
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('录制语音信号频谱');
grid on; xlim([0, fs/2]);

% 播放
fprintf('播放录制语音...\n');
sound(y, fs);
