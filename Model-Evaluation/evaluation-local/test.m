labelImgPath = 'sequence-2/';
xmlDoc = xmlread([labelImgPath num2str(1) '.xml']);

%read elements
target_array = xmlDoc.getElementsByTagName('object');
target = target_array.item(0);
bndbox_array = target.getElementsByTagName('bndbox');
bndbox = bndbox_array.item(0);
colLeft = str2double(bndbox.item(1).getTextContent());
colRight = str2double(bndbox.item(3).getTextContent());
rowUp = str2double(bndbox.item(5).getTextContent());
rowDown = str2double(bndbox.item(7).getTextContent());
