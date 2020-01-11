serve = 10;
L_list = zeros(1,10);
delta_L_list = zeros(1,10);
mu = 12;
lambda = 40;
% һ�㵥λʱ��ΪСʱ
for s = 1:serve
    ro = lambda / mu;
    ros = ro / s;
    sum1 = 0;

    for i = 0 : (s - 1)
        sum1 = sum1 + ro .^ i / factorial(i);
    end

    sum2 = ro .^ s / factorial(s) / (1 - ros);

    p0 = 1 / (sum1 + sum2);
    p = ro .^ s .* p0 / factorial(s) / (1 - ros);
    Lq = p .* ros / (1 - ros);
    L = Lq + ro;
    L_list(s) = L; 
end
for s = 1:(serve-1)
   delta_L_list(s) = L_list(s) - L_list(s+1);
end
c = 1:serve;
z = 10*c+50*L_list;
figure;
plot(c, z, 'r-*');
legend('��λʱ�����ܷ���');
xlabel('�ܲ�������','FontSize',16);
ylabel('��λʱ��ķ���','FontSize',16);
grid on;

L_list
delta_L_list