clc;
close all;
%-----------------------��ͼ���ע���ݵ�·����--------------------------
labelImgPath = 'dataset-1/';
resultImgPath = 'result-1/';
%% ----------- ����ȡ�ļ���ͼ��2�µĻҶ�ͼ�񲢱��桿--------------
File = dir(fullfile(labelImgPath, '*.bmp'));%��ȡ�ļ����µ�����.jpg��ʽ�ļ�
FileName = {File.name}';%���ļ���ת����n * 1
lengthFolder = size(FileName, 1);
% -----------------------����ȡĿ��ı�ע��Ϣ��--------------------------
locate_x = xlsread([labelImgPath 'x_coordinates.csv']);
locate_y = xlsread([labelImgPath 'y_coordinates.csv']);

%% ------------��Evaluation Metrics - �������������-------------
% varianceName_? - _in original image   - _out result image
%                - ���������_inΪԭʼͼƬ ,��_outΪ������ͼƬ
% ave_t - the average pixelvalue of the target region
%       - Ŀ����������ؾ�ֵ 
% avt_lb - the average pixelvalue of the surrounding local neighborhood
%          region.
%       - Ŀ����������ؾ�ֵ
% sd_lb - the standard deviation of the surrounding local neighborhood region
%       - Ŀ������ı�׼��
% SCR_in_l - the signal-to-clutter ratio of the original image's local region
%          - ԭʼͼƬ�ľֲ������
%        - SCR_in_l = |ave_t_in - ave_lb_in| / sd_lb_in
% SCR_out_l - the signal-to-clutter ratio of the result image's local region
%           - ���ͼƬ�ľֲ������
%           - SCR_out_l = |ave_t_out - ave_lb_out| / sd_lb_out
% SCRG_l - the signal-to-clutter ratio gain of local region with the current methods
%        - ��ǰ����СĿ���ⷽ���Ը�ͼ��Ŀ����������������
%        - SCRG_l = SCR_out_l / SCR_in_l
% sd_in - the standard deviation of the original image
%       - ����ǰ����ͼ��ı�׼��
% sd_out - the standard deviation of the result image
%       - ���������ͼ��ı�׼��
% BSF - background suppression factor between the original and result image
%     - ������ͼ��ı������Ƴ̶�
%     - BSF = sd_in /sd_out
% ����һ���������ڱ����������ݣ�SCR_in_l��SCRG_l��BSF��TP��FP
% TP - true positive ����ȷĿ�����������Ŀ
% FP - false psitive �ѱ�������Ŀ�����������Ŀ
% P_d - the detection probability  
%     - ׼ȷ��
%     - P_d = TP / (TP + FP)
% F_a - false-alarm rate  
%     - �龯��
%     - F_a = FP / (TP + FP)
% ROC Curve -  construct a ROC curve through P_d and F_a
% ROC���� - ͨ��׼ȷ�ʺ��龯�ʲ�����һ���ά���ݵ㹹��ROC����
% AUC - ͨ������ROC�����µ�����õ�AUC��ֵ��ֵԽ��˵�������ļ��Ч��Խ��
% --׼ȷ�ʺ��龯�ʵļ��㹫ʽ����.............???????????

%����һ�����ݼ���С lengthFolder * 5�ľ������ڱ���SCR_in_l��SCRG_l��BSF��P_d��F_a
metrics = zeros(lengthFolder, 5);
%% --------���������ݼ���ÿһ��ͼƬ������ͼƬ������ȡ���������桢�������Ƴ̶ȡ�P_d��F_a��------
%Traverse every picture in the data set and calculate the SCR, SCRG and BSF of the picture
for i=1:lengthFolder
   % ----------����ȡ����ǰ�ʹ�����ͼ��------------------------------
   fprintf('%d/%d: %s\n', lengthFolder, i, [num2str(i) '.bmp']);
   image_in = imread([labelImgPath num2str(i) '.bmp']);
   image_out = imread([resultImgPath num2str(i) '.bmp']);
   %if size(image_in, 3) == 3
   %   image_in = rgb2gray(image_in)
   
   %---------�������ע��Ϣ,��ÿ��ͼƬ��Ŀ��������һ�������ʾ��-----------
   label = [locate_x(i,:)', locate_y(i,:)'];
   
   %-------------������ͼƬ�ľֲ�����ȡ�-----------------------------
   [targetNum, ~] = size(label); %ͳ��ͼƬ��Ŀ����
   SCR_in = 0;
   SCR_out = 0;
   for j = 1:targetNum
       x = label(j, 1);
       y = label(j, 2);
       %--------------����������ͼƬ�ľֲ�����ȡ�------------------
       ave_t = image_in(x, y);% Ŀ������ؾ�ֵ
       ave_b = image_in(x-10:x+10, y-10:y+10);% �ֲ����������ؾ�ֵ
       sd_b = std2(image_in(x-10:x+10, y-10:y+10)); % �ֲ�������׼��
       SCR_in_l = abs(ave_t - ave_b) / sd_b; % һ��Ŀ��ľֲ������
       SCR_in = SCR_in + SCR_in_l;
       
       %--------------���������ͼƬ�ľֲ�����ȡ�------------------
       ave_t_out = image_out(x, y); %Ŀ�������ֵ
       ave_b_out = image_out(x-10:x+10, y-10:y+10);% �ֲ����������ؾ�ֵ
       sd_b_out = std2(image_out(x-10:x+10, y-10:y+10)); % �ֲ�������׼��
       SCR_out_l = abs(ave_t_out - ave_b_out) / sd_b_out; % һ��Ŀ��ľֲ������
       SCR_out = SCR_out + SCR_out_l;
   end
   SCR_in = SCR_in / targetNum;
   metrics(i, 1) = SCR_in; %��ÿ��ͼƬ������ȱ���
   
   SCR_out = SCR_out /targetNum;
  % ----------------���������������SCRG��--------------------
   SCRG = SCR_out_l / SCR_in_l;
   metrics(i, 2) = SCRG;
   
  % ---------------------������BSF��-------------------------
   sd_in = std2(image_in);
   sd_out = std2(image_out);
   BSF = sd_in / sd_out;
   metrics(i, 3) = BSF;
   
  % -------------------������P_d ������F_a��-----------------
   [P_d, F_a] = statKeyMetrics(image_in, image_out, label); 
   
end

