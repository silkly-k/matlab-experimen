%% ============================================================
% 模拟滤波器详细分析 —— 电路参数、零极点、Bode图
% 包含：
%   1. 无源RC一阶低通滤波器
%   2. Sallen-Key二阶有源低通滤波器
%   3. 零极点分布分析
%   4. 时域阶跃/冲激响应
%% ============================================================
clc; clear; close all;

%% ============================================================
% 第一部分：无源RC低通滤波器
% 传递函数: H(s) = 1/(1 + s*RC) = ωc/(s + ωc)
% 截止频率: fc = 1/(2πRC)
%% ============================================================

fc = 3000;  % 截止频率 3kHz

% 可选R值，计算对应C
R_options = [1000, 4700, 10000];  % Ω
fprintf('========== 无源RC低通滤波器设计 ==========\n');
fprintf('截止频率: %d Hz\n\n', fc);
fprintf('%-12s %-12s %-18s\n', 'R (Ω)', 'C (nF)', '实际fc (Hz)');
fprintf('%-12s %-12s %-18s\n', '------', '------', '----------');
for i = 1:length(R_options)
    R = R_options(i);
    C = 1 / (2*pi*fc*R);
    fprintf('%-12d %-12.2f %-18.1f\n', R, C*1e9, 1/(2*pi*R*C));
end

% 选定一组参数用于详细分析
R = 4700;    % 4.7kΩ
C = 1 / (2*pi*fc*R);
fprintf('\n选定参数: R = %.0f Ω, C = %.2f nF\n', R, C*1e9);

% ---- 系统传递函数 (连续域) ----
% H(s) = 1/(RC*s + 1)
num_rc = 1;
den_rc = [R*C, 1];

fprintf('\n传递函数: H(s) = 1/(%.4e s + 1)\n', R*C);
fprintf('极点: s = %.1f rad/s\n', -1/(R*C));

% 检查是否有 Control System Toolbox
has_ctrl_toolbox = (exist('tf', 'file') && exist('bode', 'file'));

if has_ctrl_toolbox
    sys_rc = tf(num_rc, den_rc);

    % ---- Bode图 ----
    figure('Name', 'RC滤波器Bode图', 'Position', [100, 100, 1000, 500]);
    bode(sys_rc, {10, 100000});
    grid on;
    sgtitle(sprintf('RC低通滤波器Bode图 (f_c = %.0f Hz)', fc));

    % ---- 零极点图 ----
    figure('Name', 'RC滤波器零极点图', 'Position', [300, 300, 500, 500]);
    pzmap(sys_rc);
    grid on;
    title(sprintf('RC低通滤波器零极点分布 (极点: s = -%.1f)', 1/(R*C)));

    % ---- 阶跃响应 ----
    figure('Name', 'RC滤波器阶跃响应', 'Position', [500, 100, 500, 400]);
    step(sys_rc, 0.002);
    grid on;
    title(sprintf('RC低通滤波器阶跃响应 (τ = %.2e s)', R*C));
    xlabel('时间 (s)');

    % ---- 冲激响应 ----
    figure('Name', 'RC滤波器冲激响应', 'Position', [500, 500, 500, 400]);
    impulse(sys_rc, 0.002);
    grid on;
    title('RC低通滤波器冲激响应');
else
    fprintf('(未检测到Control System Toolbox，使用手动计算替代)\n');
    % 手动计算频率响应 (Bode图替代)
    f_manual = logspace(1, 5, 1000)';
    s_manual = 1j * 2 * pi * f_manual;
    H_rc = 1 ./ (R*C * s_manual + 1);

    figure('Name', 'RC滤波器频率响应', 'Position', [100, 100, 1000, 500]);
    subplot(2,1,1);
    semilogx(f_manual, 20*log10(abs(H_rc)), 'LineWidth', 1.2);
    xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
    title(sprintf('RC低通滤波器幅频特性 (f_c = %.0f Hz)', fc));
    grid on; xlim([10, 100000]);
    yline(-3, 'r--');

    subplot(2,1,2);
    semilogx(f_manual, unwrap(angle(H_rc))*180/pi, 'LineWidth', 1.2);
    xlabel('频率 (Hz)'); ylabel('相位 (度)');
    title('RC低通滤波器相频特性');
    grid on; xlim([10, 100000]);

    % 阶跃响应 (手动计算)
    t_step = linspace(0, 0.002, 1000);
    y_step = 1 - exp(-t_step / (R*C));
    figure('Name', 'RC滤波器阶跃响应', 'Position', [500, 100, 500, 400]);
    plot(t_step*1000, y_step, 'LineWidth', 1.5);
    xlabel('时间 (ms)'); ylabel('幅度');
    title(sprintf('RC低通滤波器阶跃响应 (τ = %.2e s)', R*C));
    grid on;

    % 冲激响应
    t_imp = linspace(0, 0.002, 1000);
    y_imp = (1/(R*C)) * exp(-t_imp / (R*C));
    figure('Name', 'RC滤波器冲激响应', 'Position', [500, 500, 500, 400]);
    plot(t_imp*1000, y_imp, 'LineWidth', 1.5);
    xlabel('时间 (ms)'); ylabel('幅度');
    title('RC低通滤波器冲激响应');
    grid on;
end

%% ============================================================
% 第二部分：Sallen-Key二阶有源低通滤波器
% 传递函数:
%   H(s) = K / [s²R₁R₂C₁C₂ + s(R₁C₁ + R₂C₁ + (1-K)R₁C₂) + 1]
% 单位增益时 K=1:
%   H(s) = 1 / [s²R₁R₂C₁C₂ + sC₁(R₁+R₂) + 1]
% 截止频率: fc = 1/(2π√(R₁R₂C₁C₂))
% 品质因数: Q = √(R₁R₂C₁C₂) / [C₁(R₁+R₂)]
%% ============================================================

fc_sk = 3000;
Q_target = 1/sqrt(2);  % Butterworth: Q = 0.7071

% 等R等C简化设计方法
% 令 R1 = R2 = R, 则:
% Q = √(C2/C1) / 2   (对于单位增益 S-K)
% fc = 1/(2πR√(C1*C2))
% 解得: C1 = 1/(4π*Q*fc*R), C2 = 4Q²*C1

fprintf('\n\n========== Sallen-Key二阶低通滤波器设计 ==========\n');
fprintf('截止频率: %d Hz, 品质因数 Q = %.3f\n\n', fc_sk, Q_target);

R_sk = 10000;  % 10kΩ (等R设计)
C1_sk = 1 / (4*pi*Q_target*fc_sk*R_sk);
C2_sk = 4 * Q_target^2 * C1_sk;

fprintf('设计参数:\n');
fprintf('  R1 = R2 = %.0f Ω\n', R_sk);
fprintf('  C1 = %.2f nF\n', C1_sk*1e9);
fprintf('  C2 = %.2f nF\n', C2_sk*1e9);
fprintf('  验证 fc = %.1f Hz\n', 1/(2*pi*R_sk*sqrt(C1_sk*C2_sk)));
fprintf('  验证 Q  = %.4f\n', sqrt(C2_sk/C1_sk)/2);

% ---- Sallen-Key传递函数 ----
% 单位增益时标准形式: H(s) = 1 / (s²*R₁R₂C₁C₂ + s*(R₁C₁+R₂C₁) + 1)
a2 = R_sk * R_sk * C1_sk * C2_sk;
a1 = R_sk * C1_sk + R_sk * C1_sk;  % = 2*R*C1
a0 = 1;

% 二阶标准形式: H(s) = ωn² / (s² + 2ζωn s + ωn²)
wn = 1 / sqrt(a2);
zeta = a1 / (2 * sqrt(a2));
fprintf('\n自然频率 ωn = %.1f rad/s (fn = %.1f Hz)\n', wn, wn/(2*pi));
fprintf('阻尼系数 ζ = %.4f\n', zeta);
fprintf('品质因数 Q = 1/(2ζ) = %.4f\n', 1/(2*zeta));

num_sk = 1;
den_sk = [a2, a1, a0];

if has_ctrl_toolbox
    sys_sk = tf(num_sk, den_sk);

    % ---- Bode图 ----
    figure('Name', 'Sallen-Key Bode图', 'Position', [150, 150, 1000, 500]);
    bode(sys_sk, {10, 100000});
    grid on;
    sgtitle(sprintf('Sallen-Key二阶低通滤波器Bode图 (f_c = %.0f Hz, Q = %.3f)', fc_sk, Q_target));

    % ---- 零极点图 ----
    figure('Name', 'Sallen-Key零极点图', 'Position', [350, 350, 500, 500]);
    pzmap(sys_sk);
    grid on;
    poles = roots(den_sk);
    fprintf('\n极点位置:\n');
    fprintf('  s1 = %.1f + j%.1f rad/s\n', real(poles(1)), imag(poles(1)));
    fprintf('  s2 = %.1f - j%.1f rad/s\n', real(poles(2)), imag(poles(2)));
    title(sprintf(['Sallen-Key零极点分布\n' ...
           '极点: %.0f ± j%.0f rad/s'], real(poles(1)), abs(imag(poles(1)))));

    % ---- 阶跃响应 ----
    figure('Name', 'Sallen-Key阶跃响应', 'Position', [550, 150, 500, 400]);
    step(sys_sk, 0.002);
    grid on;
    title(sprintf('Sallen-Key阶跃响应 (ζ = %.3f, 超调量 ≈ %.1f%%)', ...
          zeta, 100*exp(-pi*zeta/sqrt(1-zeta^2))));

    % ---- 冲激响应 ----
    figure('Name', 'Sallen-Key冲激响应', 'Position', [550, 550, 500, 400]);
    impulse(sys_sk, 0.002);
    grid on;
    title('Sallen-Key冲激响应');
else
    % 手动计算频率响应
    f_manual = logspace(1, 5, 1000)';
    s_manual = 1j * 2 * pi * f_manual;
    H_sk = 1 ./ (a2 * s_manual.^2 + a1 * s_manual + a0);

    figure('Name', 'Sallen-Key频率响应', 'Position', [150, 150, 1000, 500]);
    subplot(2,1,1);
    semilogx(f_manual, 20*log10(abs(H_sk)), 'LineWidth', 1.2);
    xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
    title(sprintf('Sallen-Key二阶低通滤波器幅频特性 (f_c = %.0f Hz, Q = %.3f)', fc_sk, Q_target));
    grid on; xlim([10, 100000]);
    yline(-3, 'r--');

    subplot(2,1,2);
    semilogx(f_manual, unwrap(angle(H_sk))*180/pi, 'LineWidth', 1.2);
    xlabel('频率 (Hz)'); ylabel('相位 (度)');
    title('Sallen-Key滤波器相频特性');
    grid on; xlim([10, 100000]);

    % 零极点
    poles = roots(den_sk);
    fprintf('\n极点位置:\n');
    fprintf('  s1 = %.1f + j%.1f rad/s\n', real(poles(1)), imag(poles(1)));
    fprintf('  s2 = %.1f - j%.1f rad/s\n', real(poles(2)), imag(poles(2)));
    figure('Name', 'Sallen-Key零极点图', 'Position', [350, 350, 500, 500]);
    plot(real(poles), imag(poles), 'x', 'MarkerSize', 12, 'LineWidth', 2);
    hold on; plot(0, 0, 'o', 'MarkerSize', 8);
    xline(0); yline(0);
    xlabel('实部'); ylabel('虚部');
    title(sprintf('Sallen-Key零极点分布 (极点: %.0f ± j%.0f rad/s)', ...
          real(poles(1)), abs(imag(poles(1)))));
    grid on; axis equal;

    % 阶跃响应 (拉普拉斯逆变换近似)
    t_step = linspace(0, 0.002, 2000);
    wd = wn * sqrt(1 - zeta^2);
    y_step = 1 - exp(-zeta*wn*t_step) .* (cos(wd*t_step) + zeta/sqrt(1-zeta^2)*sin(wd*t_step));
    figure('Name', 'Sallen-Key阶跃响应', 'Position', [550, 150, 500, 400]);
    plot(t_step*1000, y_step, 'LineWidth', 1.5);
    xlabel('时间 (ms)'); ylabel('幅度');
    title(sprintf('Sallen-Key阶跃响应 (ζ = %.3f, 超调量 ≈ %.1f%%)', ...
          zeta, 100*exp(-pi*zeta/sqrt(1-zeta^2))));
    grid on;

    % 冲激响应
    t_imp = linspace(0, 0.002, 2000);
    y_imp = (wn^2/wd) * exp(-zeta*wn*t_imp) .* sin(wd*t_imp);
    figure('Name', 'Sallen-Key冲激响应', 'Position', [550, 550, 500, 400]);
    plot(t_imp*1000, y_imp, 'LineWidth', 1.5);
    xlabel('时间 (ms)'); ylabel('幅度');
    title('Sallen-Key冲激响应');
    grid on;
end

%% ============================================================
% 第三部分：RC一阶 vs Sallen-Key二阶 深度对比
%% ============================================================

% ---- 衰减斜率对比 (手动计算，不依赖工具箱) ----
f_test = logspace(2, 5, 1000)';  % 100Hz ~ 100kHz
s_test = 1j * 2 * pi * f_test;
H_rc_test = 1 ./ (R*C * s_test + 1);
H_sk_test = 1 ./ (a2 * s_test.^2 + a1 * s_test + 1);
mag_rc_dB = 20*log10(abs(H_rc_test));
mag_sk_dB = 20*log10(abs(H_sk_test));

figure('Name', '衰减特性对比', 'Position', [300, 300, 1000, 500]);
semilogx(f_test, mag_rc_dB, 'b', 'LineWidth', 1.5); hold on;
semilogx(f_test, mag_sk_dB, 'r', 'LineWidth', 1.5);
yline(-3, 'k--'); yline(-20, 'k:'); yline(-40, 'k:');
xline(3000, 'k--', 'f_c = 3kHz');
xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title('RC一阶 vs Sallen-Key二阶 衰减特性对比');
legend('RC一阶 (-20dB/dec)', 'Sallen-Key二阶 (-40dB/dec)', ...
       '-3dB', '-20dB', '-40dB', 'Location', 'southwest');
grid on; xlim([100, 50000]); ylim([-50, 5]);

% 幅频响应叠加图
figure('Name', 'RC vs Sallen-Key 幅频响应对比', 'Position', [200, 200, 1000, 500]);
semilogx(f_test, mag_rc_dB, 'b', 'LineWidth', 1.2); hold on;
semilogx(f_test, mag_sk_dB, 'r', 'LineWidth', 1.2);
yline(-3, 'k--');
xline(3000, 'k--'); xlabel('频率 (Hz)'); ylabel('幅度 (dB)');
title(sprintf('RC一阶 vs Sallen-Key二阶 幅频特性对比 (f_c = %.0f Hz)', fc));
legend('RC一阶 (-20dB/dec)', 'Sallen-Key二阶 (-40dB/dec)', '-3dB线', '截止频率');
grid on; xlim([100, fs/2]);

% ---- 计算特定频率处衰减 ----
H_rc_3k = 1 / (R*C * 1j*2*pi*3000 + 1);
H_sk_3k = 1 / (a2 * (1j*2*pi*3000)^2 + a1 * 1j*2*pi*3000 + 1);
H_rc_6k = 1 / (R*C * 1j*2*pi*6000 + 1);
H_sk_6k = 1 / (a2 * (1j*2*pi*6000)^2 + a1 * 1j*2*pi*6000 + 1);

fprintf('\n==== 3kHz处衰减对比 ====\n');
fprintf('RC一阶:       %.2f dB\n', 20*log10(abs(H_rc_3k)));
fprintf('Sallen-Key:   %.2f dB\n', 20*log10(abs(H_sk_3k)));

fprintf('\n==== 6kHz处衰减对比(一倍频程外) ====\n');
fprintf('RC一阶:       %.2f dB (理论: ~ -7dB)\n', 20*log10(abs(H_rc_6k)));
fprintf('Sallen-Key:   %.2f dB (理论: ~ -13dB)\n', 20*log10(abs(H_sk_6k)));

fprintf('\n分析完成。\n');
