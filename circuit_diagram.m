%% ============================================================
% 模拟滤波电路图绘制
% 使用MATLAB图形绘制RC和Sallen-Key电路拓扑图
%% ============================================================
clc; clear; close all;

%% ---- 图1：无源RC低通滤波电路 ----
figure('Name', 'RC低通滤波电路', 'Position', [200, 300, 700, 400]);
hold on; axis equal off;
xlim([0, 12]); ylim([0, 6]);

% 输入电压源 Vin
plot([1, 2], [5, 5], 'k', 'LineWidth', 2);        % 导线
plot([1, 1.3], [0, 5], 'k', 'LineWidth', 2);       % 左侧引线
plot([1, 1.6], [5.3, 4.7], 'k', 'LineWidth', 2);   % 电池正极
plot([1.6, 1.6], [5.4, 4.6], 'k', 'LineWidth', 2); % 电池负极
plot([1.6, 1], [5.3, 4.7], 'k', 'LineWidth', 2);   % 电池上边
text(0.7, 5, 'V_{in}', 'FontSize', 12, 'HorizontalAlignment', 'right');
text(0.7, 2.5, '+', 'FontSize', 14, 'HorizontalAlignment', 'center');
text(0.7, 0.3, '-', 'FontSize', 14, 'HorizontalAlignment', 'center');

% 电阻 R (用锯齿线表示)
x_r = 2:0.3:5;
y_r = 5 + 0.3 * (-1).^(0:length(x_r)-1);
y_r(1) = 5; y_r(end) = 5;
plot(x_r, y_r, 'k', 'LineWidth', 2);
text(3.5, 5.8, 'R', 'FontSize', 12, 'HorizontalAlignment', 'center');

% 连接导线
plot([5, 6], [5, 5], 'k', 'LineWidth', 2);

% 电容 C (两条平行线)
plot([6, 6], [5, 3], 'k', 'LineWidth', 2);          % 上引线
plot([5.5, 6.5], [3, 3], 'k', 'LineWidth', 2.5);    % 上极板
plot([5.5, 6.5], [2.5, 2.5], 'k', 'LineWidth', 2.5);% 下极板
plot([6, 6], [2.5, 0], 'k', 'LineWidth', 2);        % 下引线到地
text(7, 3.75, 'C', 'FontSize', 12);

% 输出 Vout (从RC结点引出)
plot([6, 7], [5, 5], 'k', 'LineWidth', 2);
plot([7, 8], [5, 5], 'k', 'LineWidth', 2);
text(8.5, 5, 'V_{out}', 'FontSize', 12, ...
     'HorizontalAlignment', 'left');

% 地线
plot([1, 3], [0, 0], 'k', 'LineWidth', 2);
plot([6, 8], [0, 0], 'k', 'LineWidth', 2);
% 接地符号
plot([1.5, 1.5], [0, -0.5], 'k', 'LineWidth', 1.5);
plot([1.1, 1.9], [-0.5, -0.5], 'k', 'LineWidth', 1.5);
plot([1.3, 1.7], [-0.8, -0.8], 'k', 'LineWidth', 1);
plot([6.5, 6.5], [0, -0.5], 'k', 'LineWidth', 1.5);
plot([6.1, 6.9], [-0.5, -0.5], 'k', 'LineWidth', 1.5);
plot([6.3, 6.7], [-0.8, -0.8], 'k', 'LineWidth', 1);

% 标注传递函数和截止频率
text(9.5, 3, sprintf(['RC低通滤波器\n' ...
       'H(s) = 1/(1+sRC)\n' ...
       'f_c = 1/(2\\piRC)\n' ...
       '衰减: -20dB/dec']), ...
     'FontSize', 11, 'BackgroundColor', 'w', 'EdgeColor', 'k');

title('无源RC一阶低通滤波器电路图', 'FontSize', 14);
box on;

%% ---- 图2：Sallen-Key二阶有源低通滤波电路 ----
figure('Name', 'Sallen-Key滤波电路', 'Position', [300, 200, 900, 550]);
hold on; axis equal off;
xlim([0, 16]); ylim([0, 8]);

% ---- 运放三角形 ----
% 运放主体
opamp_x = [10, 12, 12, 10];
opamp_y = [2.5, 3.5, 5.5, 6.5];
fill(opamp_x, opamp_y, [0.9 0.9 1], 'EdgeColor', 'k', 'LineWidth', 1.5);
text(10.7, 4.5, 'OPA', 'FontSize', 10, 'HorizontalAlignment', 'center');
% +/- 标记
text(10.3, 3.3, '+', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(10.3, 5.7, '-', 'FontSize', 10, 'HorizontalAlignment', 'center');

% ---- Vin ----
plot([0.5, 1.5], [7, 7], 'k', 'LineWidth', 2);
text(0.2, 7, 'V_{in}', 'FontSize', 12, 'HorizontalAlignment', 'right');
plot([0.5, 0.8], [0, 7], 'k', 'LineWidth', 2);
text(0.2, 3.5, '+', 'FontSize', 14);
text(0.2, 0.3, '-', 'FontSize', 14);

% ---- R1 ----
x_r1 = 1.5:0.3:4.5;
y_r1 = 7 + 0.3 * (-1).^(0:length(x_r1)-1);
y_r1(1) = 7; y_r1(end) = 7;
plot(x_r1, y_r1, 'k', 'LineWidth', 2);
text(3, 7.8, 'R_1', 'FontSize', 11, 'HorizontalAlignment', 'center');

% ---- 节点1 (R1-R2-C1连接点) ----
plot([4.5, 5.5], [7, 7], 'k', 'LineWidth', 2);

% ---- R2 ----
x_r2 = 5.5:0.3:8.5;
y_r2 = 7 + 0.3 * (-1).^(0:length(x_r2)-1);
y_r2(1) = 7; y_r2(end) = 7;
plot(x_r2, y_r2, 'k', 'LineWidth', 2);
text(7, 7.8, 'R_2', 'FontSize', 11, 'HorizontalAlignment', 'center');

% ---- R2到运放同相输入端 ----
plot([8.5, 10], [7, 7], 'k', 'LineWidth', 2);
plot([10, 10], [7, 6.5], 'k', 'LineWidth', 2);  % 连接到运放+
plot([9.8, 10.2], [7, 7], 'k', 'LineWidth', 1);
plot([10, 10], [7, 7], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);

% ---- C1 (节点1到运放输出) ----
plot([5.5, 5.5], [7, 6], 'k', 'LineWidth', 2);       % 上引线
plot([5, 6], [6, 6], 'k', 'LineWidth', 2.5);          % 上极板
plot([5, 6], [5.5, 5.5], 'k', 'LineWidth', 2.5);      % 下极板
plot([5.5, 5.5], [5.5, 3.5], 'k', 'LineWidth', 2);    % 下引线
% 连接到运放输出(反馈)
plot([5.5, 10.5], [3.5, 3.5], 'k', 'LineWidth', 2);
plot([12, 12], [3.5, 3.5], 'k', 'LineWidth', 2);
plot([10.5, 12], [3.5, 3.5], 'k', 'LineWidth', 2);    % 反馈路径
text(3.8, 6.3, 'C_1', 'FontSize', 11);

% ---- 运放输出 (Vo) ----
plot([12, 12], [3.5, 3], 'k', 'LineWidth', 2);        % 运放输出向下
plot([12, 14], [3, 3], 'k', 'LineWidth', 2);
text(14.5, 3, 'V_{out}', 'FontSize', 12, ...
     'HorizontalAlignment', 'left');

% ---- C2 (运放同相输入端+ 到地) ----
% Sallen-Key拓扑: C2连接在运放同相输入端(+)和地之间
plot([10, 10], [7, 6.2], 'k', 'LineWidth', 2);        % 从+输入端向下
plot([9.5, 10.5], [6.2, 6.2], 'k', 'LineWidth', 2.5);  % 上极板(C2)
plot([9.5, 10.5], [5.7, 5.7], 'k', 'LineWidth', 2.5);  % 下极板(C2)
plot([10, 10], [5.7, 0], 'k', 'LineWidth', 2);         % 到地
text(11, 6.5, 'C_2', 'FontSize', 11);

% 单位增益跟随器: 运放输出直接反馈到反相输入端(-)
plot([12, 12], [3.5, 5.5], 'k', 'LineWidth', 2);
plot([9.8, 10.2], [5.5, 5.5], 'k', 'LineWidth', 1);
plot([10, 10], [5.5, 5.5], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);

% ---- 地线 ----
plot([0.5, 1.5], [0, 0], 'k', 'LineWidth', 2);
plot([9, 11], [0, 0], 'k', 'LineWidth', 2);
% 接地符号
for x_gnd = [0.8, 10]
    plot([x_gnd, x_gnd], [0, -0.4], 'k', 'LineWidth', 1.5);
    plot([x_gnd-0.4, x_gnd+0.4], [-0.4, -0.4], 'k', 'LineWidth', 1.5);
    plot([x_gnd-0.25, x_gnd+0.25], [-0.65, -0.65], 'k', 'LineWidth', 1);
end

% ---- 节点标记 ----
plot([5.5, 5.5], [7, 7], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
plot([4.5, 4.5], [7, 7], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);

text(13.5, 7.5, sprintf(['Sallen-Key二阶低通滤波器\n' ...
       'H(s) = 1/(s^2R_1R_2C_1C_2+sC_1(R_1+R_2)+1)\n' ...
       'f_c = 1/(2\\pi\\surd(R_1R_2C_1C_2))\n' ...
       'Q = \\surd(C_2/C_1)/2  (单位增益)\n' ...
       '衰减: -40dB/dec']), ...
     'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k');

title('Sallen-Key二阶有源低通滤波器电路图 (单位增益)', 'FontSize', 14);
box on;

fprintf('电路图绘制完成。\n');
