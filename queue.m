%%
clear
clc
%************************************************
%初始化顾客源
%************************************************
%总仿真时间(变量)
Total_time = 10;
%到达率与服务率(变量，对于服务台增多的情况可成倍减小 lambda 的大小)
lambda = 40;
mu = 13;
s = 3;
%平均到达时间与平均服务时间
arr_mean = 1 / lambda;
ser_mean = 1 / mu;
arr_num = round(Total_time * lambda * 2);
events = [];
%按负指数分布产生各顾客到达的时间间隔
events(1, :) = exprnd(arr_mean, 1, arr_num);
%各顾客的到达时刻等于时间价格的累积和
events(1, :) = cumsum(events(1, :));
%按负指数分布产生各顾客服务时间
events(2, :) = exprnd(ser_mean, 1, arr_num);
%计算仿真顾客个数，即到达时刻在仿真时间内的顾客数
len_sim = sum(events(1, :) <= Total_time);

%%
%********************************
%计算第 1 个顾客的信息
%********************************
%第 1 个顾客进入系统后直接接受服务，无需等待
events(3, 1) = 0;
%其离开时刻等于其到达时刻与服务时间之和
events(4, 1) = events(1, 1) + events(2, 1);
%其肯定被系统接纳，此时系统内共有 1 个顾客，故标志位置 1
events(5, 1) = 1;
%系统接纳的顾客数
len_mem = 1;
%正在服务的顾客的序号，用来看 3 个服务台都满了的时候，谁先走
serving_num = zeros(1,s);
serving_num(1) = 1;
% 这个已经囊括在后面那里了
% %如果第 2 个顾客在第 1 个顾客离开之前就来了
% if events(1, 2) < events(4, 1) 
%     serving_num(1) = 1;
% end
%%
%这里开启了上帝视角，一切都靠算出来
for i = 2 : len_sim
    %第 i 个人到达时，当前正在等待的人数
    wait_number = sum((events(1, 1:len_mem)+events(3, 1:len_mem)) > events(1, i));
    %第 i 个人到达时，当前正在被服务的人数
    serve_number = sum(events(4, 1:len_mem) > events(1, i)) - wait_number; 
%     if sum(serving_num) ~= 0
%         a_num = serving_num(serving_num ~= 0);
%         a = sum(events(4, a_num) < events(1, i));
%         if a ~= 0
%             serving_num(events(4, a_num) < events(1, i)) = 0;
%         end
%     end
    %如果系统为空，则第 i 个顾客直接接受服务
    if serve_number < s
        %当第 i 个人不需等待直接接受服务时，需要清理一波serving_num
        %如果i-1,i-2,i-3（不一定这三个都有）之中有人在第 i 个人到达服务台之前就离开
        %需要将serving_num中他们的位置置为0
        if sum(serving_num) ~= 0
            a_num = serving_num(serving_num ~= 0);
            a = sum(events(4, a_num) < events(1, i));
            if a ~= 0
                serving_num(events(4, a_num) < events(1, i)) = 0;
            end
        end
        %其等待时间为 0
        events(3, i) = 0;
        %其离开时刻等于到达时刻与服务时间之和
        events(4, i) = events(1, i) + events(2, i);
        %其标志位置 1
        events(5, i) = serve_number + 1;
        ind = find(serving_num == 0);
        %只要找到一个空着的服务台就可以了
        serving_num(ind(1)) = i;      
    %如果系统有顾客正在接受服务，且系统等待队列未满，则第 i 个顾客进入系统
    else
        %如果第i个人需要等待，则他选择的服务台的序号和i-1,i-2,i-3这三个人有关
        %3个服务台中最先结束的那个服务台是哪个以及离开的时间
        [m, index] = min(events(4, serving_num));
        %其等待时间等于队列中前一个顾客的离开时间减去其到达时刻
        events(3, i) = m - events(1, i);
        %其离开时刻等于队列中前一个顾客的离开时刻加上其服务时间
        events(4, i) = m + events(2, i);
        %标识位表示其进入系统后，系统内共有的顾客数
        events(5, i) = wait_number + 4;   
        %哪个服务台最先结束，就去哪里
        serving_num(index) = i;
    end
    len_mem = len_mem+1;
end
%%
%***************************************
%输出结果
%***************************************
%绘制在仿真时间内，进入系统的所有顾客的到达时刻和离开时刻曲线图（stairs：绘制二维阶梯图）
stairs(0 : len_mem, [0, events(1, 1:len_mem)]);
hold on;
stairs(0 : len_mem, [0, events(4, 1:len_mem)], '.-r');
legend('到达时间', '离开时间');
%设置横纵轴名称及字体大小
xlabel('第几个顾客','FontSize',16);
ylabel('时间(小时)','FontSize',16);
hold off;
grid on;
%绘制在仿真时间内，进入系统的所有顾客的停留时间和等待时间曲线图（plot, 绘制二维线性图）
figure;
plot(1 : len_mem, events(3, 1:len_mem), 'r-*', 1 : len_mem, events(2, 1:len_mem) + events(3, 1:len_mem), 'k-');
legend('等待时间', '停留时间');
%设置横纵轴名称及字体大小
xlabel('第几个顾客','FontSize',16);
ylabel('时间(小时)','FontSize',16);
grid on;
