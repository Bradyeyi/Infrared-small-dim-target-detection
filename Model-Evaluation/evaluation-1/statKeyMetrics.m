function [P_d, F_a] = statKeyMetrics(image_in, image_out, label)
% - 红外小目标检测
% - 统计单张图片检测目标检测正确的数目 TP
% - 统计单张图片背景检测出来的数目 FP
% - 计算背景检测成为目标的像素值 FN

%% 如果输入的元素仅有两个，则该张图片的 targetNum = 0
% - TP = 0 FP需要统计 FN也需要统计
% - label - 以boundingbox的格式记录下目标区域，当为空时，图像没有目标；

%--------------------【转换成二值图像】-----------------------
% 由于处理后的图像简单所以直接用canny算子提取边缘确定目标区域
image = edge(image_out,'canny');
% figure(1);
% imshow(image);

% -------------------【boundingbox框定目标】-----------------
L=logical(image); %P是二值图像
rec =regionprops(L, 'Boundingbox');
resultNum = size(rec);

% ------------------- 【计算图像P_d】------------------------
figure(2);
imshow(image_in);
for i = 1:resultNum
    rectangle('Position',rec(i).BoundingBox,'Curvature',[0,0],'EdgeColor','r');
end    

end

