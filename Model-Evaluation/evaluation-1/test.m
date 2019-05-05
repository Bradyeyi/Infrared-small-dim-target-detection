%% ----------������һ��ͼƬ�ļ����ȷ�ʡ����ʡ�-----------------
image_in = imread("dataset-1/1.bmp");
image_out = imread("result-1/1.bmp");
labelImgPath = 'dataset-1/';
locate_x = xlsread([labelImgPath 'x_coordinates.csv']);
locate_y = xlsread([labelImgPath 'y_coordinates.csv']);
label = [locate_x(1,:)', locate_y(1,:)'];

% ------------------ ��labelתboundingbox��ʽ��------------------
label_box = {};


%--------------------��ת���ɶ�ֵͼ��-----------------------
% ���ڴ�����ͼ�������ֱ����canny������ȡ��Եȷ��Ŀ������
image = edge(image_out,'canny');
% figure(1);
% imshow(image);

% -------------------��boundingbox��Ŀ�꡿-----------------
L=logical(image); %P�Ƕ�ֵͼ��
rec =regionprops(L, 'Boundingbox');
resultNum = size(rec);

% ------------------- ������ͼ��P_d��------------------------
figure(2);
imshow(image_in);
for i = 1:resultNum
    rectangle('Position',rec(i).BoundingBox,'Curvature',[0,0],'EdgeColor','r');
end




