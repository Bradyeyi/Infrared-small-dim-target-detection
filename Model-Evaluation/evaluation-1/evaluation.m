clc;
close all;
%-----------------------【图像标注数据的路径】--------------------------
labelImgPath = 'dataset-1/';
resultImgPath = 'result-1/';
%% ----------- 【读取文件夹图像2下的灰度图像并保存】--------------
File = dir(fullfile(labelImgPath, '*.bmp'));%读取文件夹下的所有.jpg格式文件
FileName = {File.name}';%将文件名转换成n * 1
lengthFolder = size(FileName, 1);
% -----------------------【读取目标的标注信息】--------------------------
locate_x = xlsread([labelImgPath 'x_coordinates.csv']);
locate_y = xlsread([labelImgPath 'y_coordinates.csv']);

%% ------------【Evaluation Metrics - 相关评估参数】-------------
% varianceName_? - _in original image   - _out result image
%                - 变量名后加_in为原始图片 ,加_out为处理后的图片
% ave_t - the average pixelvalue of the target region
%       - 目标区域的像素均值 
% avt_lb - the average pixelvalue of the surrounding local neighborhood
%          region.
%       - 目标邻域的像素均值
% sd_lb - the standard deviation of the surrounding local neighborhood region
%       - 目标领域的标准差
% SCR_in_l - the signal-to-clutter ratio of the original image's local region
%          - 原始图片的局部信噪比
%        - SCR_in_l = |ave_t_in - ave_lb_in| / sd_lb_in
% SCR_out_l - the signal-to-clutter ratio of the result image's local region
%           - 结果图片的局部信噪比
%           - SCR_out_l = |ave_t_out - ave_lb_out| / sd_lb_out
% SCRG_l - the signal-to-clutter ratio gain of local region with the current methods
%        - 当前红外小目标检测方法对该图像目标区域的信噪比增益
%        - SCRG_l = SCR_out_l / SCR_in_l
% sd_in - the standard deviation of the original image
%       - 处理前整幅图像的标准差
% sd_out - the standard deviation of the result image
%       - 处理后整幅图像的标准差
% BSF - background suppression factor between the original and result image
%     - 对整幅图像的背景抑制程度
%     - BSF = sd_in /sd_out
% 定义一个数组用于保存评估数据：SCR_in_l、SCRG_l、BSF、TP、FP
% TP - true positive 把正确目标检测出来的数目
% FP - false psitive 把背景当成目标检测出来的数目
% P_d - the detection probability  
%     - 准确率
%     - P_d = TP / (TP + FP)
% F_a - false-alarm rate  
%     - 虚警率
%     - F_a = FP / (TP + FP)
% ROC Curve -  construct a ROC curve through P_d and F_a
% ROC曲线 - 通过准确率和虚警率产生的一组二维数据点构造ROC曲线
% AUC - 通过计算ROC曲线下的面积得到AUC的值，值越大说明方法的检测效果越好
% --准确率和虚警率的计算公式待定.............???????????

%申请一个数据集大小 lengthFolder * 5的矩阵用于保存SCR_in_l、SCRG_l、BSF、P_d、F_a
metrics = zeros(lengthFolder, 5);
%% --------【遍历数据集的每一张图片，计算图片的信噪比、信噪比增益、背景抑制程度、P_d、F_a】------
%Traverse every picture in the data set and calculate the SCR, SCRG and BSF of the picture
for i=1:lengthFolder
   % ----------【读取处理前和处理后的图像】------------------------------
   fprintf('%d/%d: %s\n', lengthFolder, i, [num2str(i) '.bmp']);
   image_in = imread([labelImgPath num2str(i) '.bmp']);
   image_out = imread([resultImgPath num2str(i) '.bmp']);
   %if size(image_in, 3) == 3
   %   image_in = rgb2gray(image_in)
   
   %---------【处理标注信息,将每张图片的目标坐标用一个矩阵表示】-----------
   label = [locate_x(i,:)', locate_y(i,:)'];
   
   %-------------【计算图片的局部信噪比】-----------------------------
   [targetNum, ~] = size(label); %统计图片的目标数
   SCR_in = 0;
   SCR_out = 0;
   for j = 1:targetNum
       x = label(j, 1);
       y = label(j, 2);
       %--------------【计算输入图片的局部信噪比】------------------
       ave_t = image_in(x, y);% 目标的像素均值
       ave_b = image_in(x-10:x+10, y-10:y+10);% 局部背景的像素均值
       sd_b = std2(image_in(x-10:x+10, y-10:y+10)); % 局部背景标准差
       SCR_in_l = abs(ave_t - ave_b) / sd_b; % 一个目标的局部信噪比
       SCR_in = SCR_in + SCR_in_l;
       
       %--------------【计算输出图片的局部信噪比】------------------
       ave_t_out = image_out(x, y); %目标的像素值
       ave_b_out = image_out(x-10:x+10, y-10:y+10);% 局部背景的像素均值
       sd_b_out = std2(image_out(x-10:x+10, y-10:y+10)); % 局部背景标准差
       SCR_out_l = abs(ave_t_out - ave_b_out) / sd_b_out; % 一个目标的局部信噪比
       SCR_out = SCR_out + SCR_out_l;
   end
   SCR_in = SCR_in / targetNum;
   metrics(i, 1) = SCR_in; %将每张图片的信噪比保存
   
   SCR_out = SCR_out /targetNum;
  % ----------------【计算信噪比增益SCRG】--------------------
   SCRG = SCR_out_l / SCR_in_l;
   metrics(i, 2) = SCRG;
   
  % ---------------------【计算BSF】-------------------------
   sd_in = std2(image_in);
   sd_out = std2(image_out);
   BSF = sd_in / sd_out;
   metrics(i, 3) = BSF;
   
  % -------------------【计算P_d 、计算F_a】-----------------
   [P_d, F_a] = statKeyMetrics(image_in, image_out, label); 
   
end

