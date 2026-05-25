%% 离散卷积全过程绘图（适配 h=[1,1,1,1] n=0~3）
clear; clc; close all;

%% 1. 定义信号（你的最新设置）
f = [1,1,5,1,1];   % 输入信号 f[n] n=1~5
h = [1,1,1,1];     % 冲激响应 h[n] n=0,1,2,3
k = -4:8;          % 时间轴（覆盖所有翻转/平移位置）

% 生成原始信号 f[k]
fk = zeros(size(k));
fk(k>=1 & k<=5) = f;

%% ===================== 图1：原始信号 f[k] =====================
figure;
stem(k, fk, 'filled','LineWidth',1.2,'Color','b');
grid on; xlabel('k'); ylabel('f[k]'); title('原始信号 f[k]');
xlim([-4 8]); ylim([0 6]);

%% 单独绘制：单位冲激响应信号 h[k]
clear;clc;close all;
k = -4:8;
hk = zeros(size(k));
% 冲激响应 h[k] = [1,1,1,1]  k=0,1,2,3
hk(k>=0 & k<=3) = [1,1,1,1]; 

stem(k, hk, 'filled','LineWidth',1.2,'Color','r');
grid on;
xlabel('k');
ylabel('h[k] 单位冲激响应');
title('系统单位冲激响应信号 h[k]');
xlim([-4 8]);
%% ===================== 图2：翻转信号 h[-k] =====================
figure;
h_flip = fliplr(h); % 翻转后 h[-k] 对应 k=-3,-2,-1,0
hk_flip = zeros(size(k));
% 4个位置匹配4个元素，彻底修复报错
hk_flip(k>=-3 & k<=0) = h_flip;  
stem(k, hk_flip, 'filled','LineWidth',1.2,'Color','r');
grid on; xlabel('k'); ylabel('h[-k]'); title('翻转信号 h[-k]');
xlim([-4 8]); ylim([0 1.2]);

%% ===================== 平移 h[n-k] + 相乘 f[k]h[n-k] (n=1~8) =====================
for n = 1:8
    h_nk = zeros(size(k));
    % 适配4点冲激响应：k ∈ [n-3, n]
    h_nk(k>=(n-3) & k<=n) = h; 
    prod = fk .* h_nk;
    
    % 绘制平移信号
    figure;
    stem(k, h_nk, 'filled','LineWidth',1.2);
    grid on; xlabel('k'); title(['平移 h(',num2str(n),'-k)']);
    
    % 绘制相乘信号
    figure;
    stem(k, prod, 'filled','LineWidth',1.2);
    grid on; xlabel('k'); title(['相乘 f[k]h(',num2str(n),'-k)']);
end

%% ===================== 最终卷积结果 y[n] =====================
y = conv(f, h);
ny = 1:length(y);
figure;
stem(ny, y, 'filled','LineWidth',1.5,'Color','k');
grid on; xlabel('n'); ylabel('y[n]'); title('卷积结果 y[n]');
xlim([0 10]); ylim([0 10]);