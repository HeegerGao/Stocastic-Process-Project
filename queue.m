%%
clear
clc
%************************************************
%��ʼ���˿�Դ
%************************************************
%�ܷ���ʱ��(����)
Total_time = 10;
%�������������(���������ڷ���̨���������ɳɱ���С lambda �Ĵ�С)
lambda = 40;
mu = 13;
s = 3;
%ƽ������ʱ����ƽ������ʱ��
arr_mean = 1 / lambda;
ser_mean = 1 / mu;
arr_num = round(Total_time * lambda * 2);
events = [];
%����ָ���ֲ��������˿͵����ʱ����
events(1, :) = exprnd(arr_mean, 1, arr_num);
%���˿͵ĵ���ʱ�̵���ʱ��۸���ۻ���
events(1, :) = cumsum(events(1, :));
%����ָ���ֲ��������˿ͷ���ʱ��
events(2, :) = exprnd(ser_mean, 1, arr_num);
%�������˿͸�����������ʱ���ڷ���ʱ���ڵĹ˿���
len_sim = sum(events(1, :) <= Total_time);

%%
%********************************
%����� 1 ���˿͵���Ϣ
%********************************
%�� 1 ���˿ͽ���ϵͳ��ֱ�ӽ��ܷ�������ȴ�
events(3, 1) = 0;
%���뿪ʱ�̵����䵽��ʱ�������ʱ��֮��
events(4, 1) = events(1, 1) + events(2, 1);
%��϶���ϵͳ���ɣ���ʱϵͳ�ڹ��� 1 ���˿ͣ��ʱ�־λ�� 1
events(5, 1) = 1;
%ϵͳ���ɵĹ˿���
len_mem = 1;
%���ڷ���Ĺ˿͵���ţ������� 3 ������̨�����˵�ʱ��˭����
serving_num = zeros(1,s);
serving_num(1) = 1;
% ����Ѿ������ں���������
% %����� 2 ���˿��ڵ� 1 ���˿��뿪֮ǰ������
% if events(1, 2) < events(4, 1) 
%     serving_num(1) = 1;
% end
%%
%���￪�����ϵ��ӽǣ�һ�ж��������
for i = 2 : len_sim
    %�� i ���˵���ʱ����ǰ���ڵȴ�������
    wait_number = sum((events(1, 1:len_mem)+events(3, 1:len_mem)) > events(1, i));
    %�� i ���˵���ʱ����ǰ���ڱ����������
    serve_number = sum(events(4, 1:len_mem) > events(1, i)) - wait_number; 
%     if sum(serving_num) ~= 0
%         a_num = serving_num(serving_num ~= 0);
%         a = sum(events(4, a_num) < events(1, i));
%         if a ~= 0
%             serving_num(events(4, a_num) < events(1, i)) = 0;
%         end
%     end
    %���ϵͳΪ�գ���� i ���˿�ֱ�ӽ��ܷ���
    if serve_number < s
        %���� i ���˲���ȴ�ֱ�ӽ��ܷ���ʱ����Ҫ����һ��serving_num
        %���i-1,i-2,i-3����һ�����������У�֮�������ڵ� i ���˵������̨֮ǰ���뿪
        %��Ҫ��serving_num�����ǵ�λ����Ϊ0
        if sum(serving_num) ~= 0
            a_num = serving_num(serving_num ~= 0);
            a = sum(events(4, a_num) < events(1, i));
            if a ~= 0
                serving_num(events(4, a_num) < events(1, i)) = 0;
            end
        end
        %��ȴ�ʱ��Ϊ 0
        events(3, i) = 0;
        %���뿪ʱ�̵��ڵ���ʱ�������ʱ��֮��
        events(4, i) = events(1, i) + events(2, i);
        %���־λ�� 1
        events(5, i) = serve_number + 1;
        ind = find(serving_num == 0);
        %ֻҪ�ҵ�һ�����ŵķ���̨�Ϳ�����
        serving_num(ind(1)) = i;      
    %���ϵͳ�й˿����ڽ��ܷ�����ϵͳ�ȴ�����δ������� i ���˿ͽ���ϵͳ
    else
        %�����i������Ҫ�ȴ�������ѡ��ķ���̨����ź�i-1,i-2,i-3���������й�
        %3������̨�����Ƚ������Ǹ�����̨���ĸ��Լ��뿪��ʱ��
        [m, index] = min(events(4, serving_num));
        %��ȴ�ʱ����ڶ�����ǰһ���˿͵��뿪ʱ���ȥ�䵽��ʱ��
        events(3, i) = m - events(1, i);
        %���뿪ʱ�̵��ڶ�����ǰһ���˿͵��뿪ʱ�̼��������ʱ��
        events(4, i) = m + events(2, i);
        %��ʶλ��ʾ�����ϵͳ��ϵͳ�ڹ��еĹ˿���
        events(5, i) = wait_number + 4;   
        %�ĸ�����̨���Ƚ�������ȥ����
        serving_num(index) = i;
    end
    len_mem = len_mem+1;
end
%%
%***************************************
%������
%***************************************
%�����ڷ���ʱ���ڣ�����ϵͳ�����й˿͵ĵ���ʱ�̺��뿪ʱ������ͼ��stairs�����ƶ�ά����ͼ��
stairs(0 : len_mem, [0, events(1, 1:len_mem)]);
hold on;
stairs(0 : len_mem, [0, events(4, 1:len_mem)], '.-r');
legend('����ʱ��', '�뿪ʱ��');
%���ú��������Ƽ������С
xlabel('�ڼ����˿�','FontSize',16);
ylabel('ʱ��(Сʱ)','FontSize',16);
hold off;
grid on;
%�����ڷ���ʱ���ڣ�����ϵͳ�����й˿͵�ͣ��ʱ��͵ȴ�ʱ������ͼ��plot, ���ƶ�ά����ͼ��
figure;
plot(1 : len_mem, events(3, 1:len_mem), 'r-*', 1 : len_mem, events(2, 1:len_mem) + events(3, 1:len_mem), 'k-');
legend('�ȴ�ʱ��', 'ͣ��ʱ��');
%���ú��������Ƽ������С
xlabel('�ڼ����˿�','FontSize',16);
ylabel('ʱ��(Сʱ)','FontSize',16);
grid on;
