clc;
close all;
%图像标注数据的路径
labelImgPath = 'sequence-2/';
resultImgPath = 'results/E/';
%% 读取文件夹图像2下的灰度图像并保存
File = dir(fullfile(labelImgPath, '*.jpg'));%读取文件夹下的所有.jpg格式文件
FileName = {File.name}';%将文件名转换成n * 1
lengthFolder = size(FileName, 1);
%% ------------Evaluation Metrics - 相关评估参数----------------------
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

%申请一个数据集大小 lengthFolder + 1 * 5的矩阵用于保存SCR_in_l、SCRG_l、BSF、P_d、F_a
% - 最后一行的五个值为每个参数的平均值，用于表示图像的复杂程度、算法对目标的突出程度、对背景抑制程度、准确率、误警率
metrics = zeros(lengthFolder + 1, 5);
%% --------遍历数据集的每一张图片，计算图片的信噪比、信噪比增益、背景抑制程度------
%Traverse every picture in the data set and calculate the SCR, SCRG and BSF of the picture
for i=1:lengthFolder
    %输出当前计算图像的名称
   fprintf('%d/%d: %s\n', lengthFolder, i, [num2str(i) '.jpg']);
   image_in = imread([labelImgPath num2str(i) '.jpg']);
   image_out = imread([resultImgPath num2str(i) '.jpg']);
   %if size(image_in, 3) == 3
   %   image_in = rgb2gray(image_in)
   
   %通过判断标注文件的存在，判断是否存在目标；
   %如果.xml格式的文件存在，则读取目标的四个坐标位置，计算SCR_in、SCR_out、G......
   %如果.xml格式文件不存在，则计算整张图片的均值和标准差代替ave_b、sd_b......
   if ~exist([num2str(i) '.xml'], labelImgPath) % .xml格式文件不存在，图片不存在目标
       %计算输入图片的信噪比
       ave_t = 0;
       ave_b = mean(image_in(:)); %原始图片的均值
       sd_b = std2(image_in); %原始图片的标准差
      %% SCR_in_l = |ave_t_in - ave_lb_in| / sd_lb_in
       SCR_in_l = abs(ave_t - ave_b) / sd_b; % 原始图片的信噪比
       metrics(i, 1) = SCR_in_l;
       % 计算处理后图片的信噪比
       avt_t_out = 0; %处理后目标像素的均值
       ave_b_out = mean(image_out(:)); %结果图片的均值
       sd_b_out = std2(image_out); % 结果图片的标准差
       % SCR_out_l = |ave_t_out - ave_lb_out| / sd_lb_out
       SCR_out_l = abs(ave_t_out - ave_b_out) / sd_b_out;
      %% 计算信噪比增益SCRG_l = SCR_out_l / SCR_in_l
       SCRG_l = SCR_out_l / SCR_in_l;
       metrics(i, 2) = SCRG_l;
      %% 计算BSF - BSF = sd_in /sd_out
       sd_in = std2(image_in);
       sd_out = std2(image_out);
       BSF = sd_in / sd_out;
       metrics(i, 3) = BSF;
      %% 计算TP, FP，P_d, F_a 
       [P_d, F_a] = statKeyMetrics(image_in, image_out); 
   else %目标存在的情况下1
       xmlDoc = xmlread([labelImgPath num2str(i) '.xml']);
       %read elements
       target_array = xmlDoc.getElementsByTagName('object');
       target = target_array.item(0);
       bndbox_array = target.getElementsByTagName('bndbox');
       bndbox = bndbox_array.item(0);
       %0-2-4-6存放的是节点的数据，1-3-5-7
       colLeft = str2double(bndbox.item(1).getTextContent());
       colRight = str2double(bndbox.item(3).getTextContent());
       rowUp = str2double(bndbox.item(5).getTextContent());
       rowDown = str2double(bndbox.item(7).getTextContent());
       %% 计算图片的局部信噪比
   end 
end