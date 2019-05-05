%% ----------【计算一张图片的检测正确率、误警率】-----------------
image_in = imread("dataset-1/1.bmp");
image_out = imread("result-1/1.bmp");
labelImgPath = 'dataset-1/';
locate_x = xlsread([labelImgPath 'x_coordinates.csv']);
locate_y = xlsread([labelImgPath 'y_coordinates.csv']);
label = [locate_x(1,:)', locate_y(1,:)'];

% ------------------ 【label转boundingbox形式】------------------
label_box = {};


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




