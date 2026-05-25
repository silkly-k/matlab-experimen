% 设置参数
fs = 1000;            % 采样频率
t = 0:1/fs:20-1/fs;   % 时间向量，持续20秒
f1 = 1.5;             % 频率设为1.5Hz

% 生成正弦波，确保t=0时为1
x = sin(2*pi*f1*t + pi/2);   % 基础信号：正弦波，确保 t = 0 时为 1

% 创建单位冲激信号（在 t = 1, 2, ..., 20 时为 1，其他时刻为 0）
impulse_signal = zeros(size(t));  
for i = 1:20
    index_t = round(i * fs) + 1;  % 找到 t = i 时刻的索引
    if index_t <= length(t)  % 确保索引不会超出数组范围
        impulse_signal(index_t) = 1;   % 在 t = i 时刻生成单位冲激信号
    end
end

% 筛选信号的瞬时值
y = x .* impulse_signal;  % 用冲激信号筛选基础信号

% 绘制信号
subplot(3, 1, 1);
plot(t, x);
title('基础信号（正弦波）');
xlabel('时间 (秒)');
ylabel('幅度');

subplot(3, 1, 2);
stem(t, impulse_signal, 'r');  % 显示冲激信号
title('冲激信号（在 t = 1 到 20 时为 1）');
xlabel('时间 (秒)');
ylabel('幅度');

subplot(3, 1, 3);
stem(t, y, 'g');  % 用stem绘制筛选后的信号
title('冲激信号筛选后的信号');
xlabel('时间 (秒)');
ylabel('幅度');
