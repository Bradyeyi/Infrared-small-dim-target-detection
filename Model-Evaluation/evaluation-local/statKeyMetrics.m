function [P_d, F_a] = statKeyMetrics(image_in, image_out, colLeft, colRight, rowUp, rowDown)
% - 红外小目标检测
% - 统计单张图片检测目标检测正确的数目 TP
% - 统计单张图片背景检测出来的数目 FP
% - 计算背景检测成为目标的像素值 FN

%% 如果输入的元素仅有两个，则该张图片的 targetNum = 0
% - TP = 0 FP需要统计 FN也需要统计
% - nargin - 用于统计函数输入元素的个数，当仅有两个元素时，没有目标区域的四个点；
if nargin == 2
    
    
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

