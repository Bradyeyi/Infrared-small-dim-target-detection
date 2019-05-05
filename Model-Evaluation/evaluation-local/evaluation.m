clc;
close all;
%ͼ���ע���ݵ�·��
labelImgPath = 'sequence-2/';
resultImgPath = 'results/E/';
%% ��ȡ�ļ���ͼ��2�µĻҶ�ͼ�񲢱���
File = dir(fullfile(labelImgPath, '*.jpg'));%��ȡ�ļ����µ�����.jpg��ʽ�ļ�
FileName = {File.name}';%���ļ���ת����n * 1
lengthFolder = size(FileName, 1);
%% ------------Evaluation Metrics - �����������----------------------
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

%����һ�����ݼ���С lengthFolder + 1 * 5�ľ������ڱ���SCR_in_l��SCRG_l��BSF��P_d��F_a
% - ���һ�е����ֵΪÿ��������ƽ��ֵ�����ڱ�ʾͼ��ĸ��ӳ̶ȡ��㷨��Ŀ���ͻ���̶ȡ��Ա������Ƴ̶ȡ�׼ȷ�ʡ�����
metrics = zeros(lengthFolder + 1, 5);
%% --------�������ݼ���ÿһ��ͼƬ������ͼƬ������ȡ���������桢�������Ƴ̶�------
%Traverse every picture in the data set and calculate the SCR, SCRG and BSF of the picture
for i=1:lengthFolder
    %�����ǰ����ͼ�������
   fprintf('%d/%d: %s\n', lengthFolder, i, [num2str(i) '.jpg']);
   image_in = imread([labelImgPath num2str(i) '.jpg']);
   image_out = imread([resultImgPath num2str(i) '.jpg']);
   %if size(image_in, 3) == 3
   %   image_in = rgb2gray(image_in)
   
   %ͨ���жϱ�ע�ļ��Ĵ��ڣ��ж��Ƿ����Ŀ�ꣻ
   %���.xml��ʽ���ļ����ڣ����ȡĿ����ĸ�����λ�ã�����SCR_in��SCR_out��G......
   %���.xml��ʽ�ļ������ڣ����������ͼƬ�ľ�ֵ�ͱ�׼�����ave_b��sd_b......
   if ~exist([num2str(i) '.xml'], labelImgPath) % .xml��ʽ�ļ������ڣ�ͼƬ������Ŀ��
       %��������ͼƬ�������
       ave_t = 0;
       ave_b = mean(image_in(:)); %ԭʼͼƬ�ľ�ֵ
       sd_b = std2(image_in); %ԭʼͼƬ�ı�׼��
      %% SCR_in_l = |ave_t_in - ave_lb_in| / sd_lb_in
       SCR_in_l = abs(ave_t - ave_b) / sd_b; % ԭʼͼƬ�������
       metrics(i, 1) = SCR_in_l;
       % ���㴦���ͼƬ�������
       avt_t_out = 0; %�����Ŀ�����صľ�ֵ
       ave_b_out = mean(image_out(:)); %���ͼƬ�ľ�ֵ
       sd_b_out = std2(image_out); % ���ͼƬ�ı�׼��
       % SCR_out_l = |ave_t_out - ave_lb_out| / sd_lb_out
       SCR_out_l = abs(ave_t_out - ave_b_out) / sd_b_out;
      %% �������������SCRG_l = SCR_out_l / SCR_in_l
       SCRG_l = SCR_out_l / SCR_in_l;
       metrics(i, 2) = SCRG_l;
      %% ����BSF - BSF = sd_in /sd_out
       sd_in = std2(image_in);
       sd_out = std2(image_out);
       BSF = sd_in / sd_out;
       metrics(i, 3) = BSF;
      %% ����TP, FP��P_d, F_a 
       [P_d, F_a] = statKeyMetrics(image_in, image_out); 
   else %Ŀ����ڵ������1
       xmlDoc = xmlread([labelImgPath num2str(i) '.xml']);
       %read elements
       target_array = xmlDoc.getElementsByTagName('object');
       target = target_array.item(0);
       bndbox_array = target.getElementsByTagName('bndbox');
       bndbox = bndbox_array.item(0);
       %0-2-4-6��ŵ��ǽڵ�����ݣ�1-3-5-7
       colLeft = str2double(bndbox.item(1).getTextContent());
       colRight = str2double(bndbox.item(3).getTextContent());
       rowUp = str2double(bndbox.item(5).getTextContent());
       rowDown = str2double(bndbox.item(7).getTextContent());
       %% ����ͼƬ�ľֲ������
   end 
end