%% 音频信号分析全流程（优化频谱图：STFT时频谱）
clear; clc; close all;

%% 步骤1：音频加载+预处理（同之前）
[piano_y, piano_sr] = audioread('piano_sound.mp3');
if size(piano_y, 2) > 1, piano_y = mean(piano_y, 2); end

[violin_y, violin_sr] = audioread('violin_sound.mp3');
if size(violin_y, 2) > 1, violin_y = mean(violin_y, 2); end

[voice_y, voice_sr] = audioread('Ellie Goulding - Love Me Like You Do.mp3');
if size(voice_y, 2) > 1, voice_y = mean(voice_y, 2); end

%% 步骤2：采样率统一（同之前）
target_sr = min([piano_sr, violin_sr, voice_sr]);
fprintf('统一后的目标采样率：%d Hz\n', target_sr);

piano_y_unified = resample(piano_y, target_sr, piano_sr);
violin_y_unified = resample(violin_y, target_sr, violin_sr);
voice_y_unified = resample(voice_y, target_sr, voice_sr);

%% 步骤3：绘制时域波形图（同之前）
figure(1); set(figure(1), 'Position', [100, 100, 1200, 800]);
piano_time = (0 : length(piano_y_unified)-1) / target_sr;
violin_time = (0 : length(violin_y_unified)-1) / target_sr;
voice_time = (0 : length(voice_y_unified)-1) / target_sr;

subplot(3,1,1); plot(piano_time, piano_y_unified, 'b');
title('钢琴信号 时域波形图'); xlabel('时间 (s)'); ylabel('幅度'); grid on;

subplot(3,1,2); plot(violin_time, violin_y_unified, 'r');
title('小提琴信号 时域波形图'); xlabel('时间 (s)'); ylabel('幅度'); grid on;

subplot(3,1,3); plot(voice_time, voice_y_unified, 'g');
title('语音信号 时域波形图'); xlabel('时间 (s)'); ylabel('幅度'); grid on;

%% 步骤4：STFT短时傅里叶变换（绘制时频谱图，更清晰）
win = hann(1024);  % 窗函数（提高频率分辨率）
noverlap = 512;    % 重叠采样（减少时间维度失真）
nfft = 2048;       % STFT的FFT点数

figure(2); set(figure(2), 'Position', [200, 200, 1200, 800]);

% 钢琴 时频谱图（0~5000Hz）
subplot(3,1,1);
[P_piano, F_piano, T_piano] = spectrogram(piano_y_unified, win, noverlap, nfft, target_sr);
imagesc(T_piano, F_piano(F_piano<=5000), 20*log10(abs(P_piano(F_piano<=5000,:))));
colormap('jet'); colorbar;
title('钢琴信号 时频谱图（0~5000 Hz）');
xlabel('时间 (s)'); ylabel('频率 (Hz)');
ylim([0, 5000]);

% 小提琴 时频谱图（0~5000Hz）
subplot(3,1,2);
[P_violin, F_violin, T_violin] = spectrogram(violin_y_unified, win, noverlap, nfft, target_sr);
imagesc(T_violin, F_violin(F_violin<=5000), 20*log10(abs(P_violin(F_violin<=5000,:))));
colormap('jet'); colorbar;
title('小提琴信号 时频谱图（0~5000 Hz）');
xlabel('时间 (s)'); ylabel('频率 (Hz)');
ylim([0, 5000]);

% 语音 时频谱图（0~5000Hz）
subplot(3,1,3);
[P_voice, F_voice, T_voice] = spectrogram(voice_y_unified, win, noverlap, nfft, target_sr);
imagesc(T_voice, F_voice(F_voice<=5000), 20*log10(abs(P_voice(F_voice<=5000,:))));
colormap('jet'); colorbar;
title('语音信号 时频谱图（0~5000 Hz）');
xlabel('时间 (s)'); ylabel('频率 (Hz)');
ylim([0, 5000]);

%% 步骤5：采样密度与总结
piano_density = target_sr / nfft;
fprintf('STFT采样密度：%.6f Hz/点\n', piano_density);
fprintf('时频谱图展示：不同时间的频率能量分布（颜色越亮能量越强）\n');