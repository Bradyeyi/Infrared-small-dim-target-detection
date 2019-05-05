function [P_d, F_a] = statKeyMetrics(image_in, image_out, label)
% - ����СĿ����
% - ͳ�Ƶ���ͼƬ���Ŀ������ȷ����Ŀ TP
% - ͳ�Ƶ���ͼƬ��������������Ŀ FP
% - ���㱳������ΪĿ�������ֵ FN

%% ��������Ԫ�ؽ��������������ͼƬ�� targetNum = 0
% - TP = 0 FP��Ҫͳ�� FNҲ��Ҫͳ��
% - label - ��boundingbox�ĸ�ʽ��¼��Ŀ�����򣬵�Ϊ��ʱ��ͼ��û��Ŀ�ꣻ

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

end

