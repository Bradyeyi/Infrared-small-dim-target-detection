function [P_d, F_a] = statKeyMetrics(image_in, image_out, colLeft, colRight, rowUp, rowDown)
% - ����СĿ����
% - ͳ�Ƶ���ͼƬ���Ŀ������ȷ����Ŀ TP
% - ͳ�Ƶ���ͼƬ��������������Ŀ FP
% - ���㱳������ΪĿ�������ֵ FN

%% ��������Ԫ�ؽ��������������ͼƬ�� targetNum = 0
% - TP = 0 FP��Ҫͳ�� FNҲ��Ҫͳ��
% - nargin - ����ͳ�ƺ�������Ԫ�صĸ���������������Ԫ��ʱ��û��Ŀ��������ĸ��㣻
if nargin == 2
    
    
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

