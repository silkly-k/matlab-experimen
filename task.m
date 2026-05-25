clc; clear; close all;

%% 实验三 线性时不变系统的时域分析（纯MATLAB版）
% ------------------------------------------------------------
% 第一题：连续系统
% 微分方程：
% y''(t)+2y'(t)+y(t)=f'(t)+2f(t)
% H(s)=Y(s)/F(s)=(s+2)/(s+1)^2
% h(t)=L^-1{H(s)}=(1+t)e^(-t)u(t)
% ------------------------------------------------------------

t_end = 10;

%% 第一题(1)：系统冲激响应
p = 0.01;
t = 0:p:t_end;
h = (1 + t).*exp(-t);

figure;
plot(t, h, 'LineWidth', 1.5);
grid on;
title('第一题(1)：冲激响应 h(t)=(1+t)e^{-t}u(t)');
xlabel('t (s)');
ylabel('h(t)');

%% 第一题(2)：输入 f(t)=e^{-2t}u(t) 的零状态响应
f = exp(-2*t);
y_zs = p * conv(f, h);          % 卷积积分离散近似
t_y = 0:p:(2*t_end);

figure;
plot(t_y, y_zs, 'LineWidth', 1.5);
grid on;
xlim([0 t_end]);
title('第一题(2)：零状态响应（f(t)=e^{-2t}u(t)）');
xlabel('t (s)');
ylabel('y_{zs}(t)');

%% 第一题(3)：改变采样间隔 p 观察影响
p_list = [0.2, 0.05, 0.01];

figure; hold on;
for k = 1:length(p_list)
    pk = p_list(k);
    tk = 0:pk:t_end;
    hk = (1 + tk).*exp(-tk);
    fk = exp(-2*tk);
    yk = pk * conv(fk, hk);
    tyk = 0:pk:(2*t_end);

    plot(tyk, yk, 'LineWidth', 1.2, ...
        'DisplayName', ['p = ' num2str(pk)]);
end
grid on;
xlim([0 t_end]);
legend('show');
title('第一题(3)：不同采样间隔 p 对零状态响应影响');
xlabel('t (s)');
ylabel('y_{zs}(t)');

% ------------------------------------------------------------
% 第二题：离散系统
% y(n)+y(n-1)+0.25y(n-2)=f(n)
% 求：单位冲激响应、单位阶跃响应
% ------------------------------------------------------------
n = 0:40;
den2 = [1 1 0.25];
num2 = 1;

% 单位冲激响应
x_imp = [1 zeros(1, length(n)-1)];
h2 = filter(num2, den2, x_imp);

figure;
stem(n, h2, 'filled');
grid on;
title('第二题：单位冲激响应 h(n)');
xlabel('n');
ylabel('h(n)');

% 单位阶跃响应
x_step = ones(1, length(n));
y_step = filter(num2, den2, x_step);

figure;
stem(n, y_step, 'filled');
grid on;
title('第二题：单位阶跃响应 s(n)');
xlabel('n');
ylabel('s(n)');

% ------------------------------------------------------------
% 第三题：离散系统
% y[n]=0.5f[n]+f[n-1]
% 求：冲激响应数值解并画波形
% ------------------------------------------------------------
n3 = 0:20;
x3 = [1 zeros(1, length(n3)-1)];   % f[n]=δ[n]

% y[n]=0.5f[n]+f[n-1] -> b=[0.5 1], a=1
h3 = filter([0.5 1], 1, x3);

figure;
stem(n3, h3, 'filled');
grid on;
title('第三题：冲激响应 h[n]');
xlabel('n');
ylabel('h[n]');

disp('第三题冲激响应前10项：');
disp(h3(1:10));
