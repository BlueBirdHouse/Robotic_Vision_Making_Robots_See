load('./data/fig8.mat')
figure;
idisp(lin2rgb(image));

label = markColor(image);
figure;
idisp(label)



function label = markColor(img)
%¼���׼ͼ��
data = load('./data/fig1.mat');
image_std = data.image;
%¼������õ�Mask
data = load('./data/Masks.mat');
BackMask = data.BackMask;
BackWhiteMask = data.BackWhiteMask;
BlueMask = data.BlueMask;
GreenMask = data.GreenMask;
RedMask = data.RedMask;

%��ʾͼ��Ԥ����
im_gama = igamm(image_std, 'sRGB');
im_gama = idouble(im_gama);

%����������ɫ
sampled_back = applyMask(im_gama,BackMask);
sampled_Blue = applyMask(im_gama,BlueMask);
sampled_Green = applyMask(im_gama,GreenMask);
sampled_Red = applyMask(im_gama,RedMask);
sampled_BackWhite = applyMask(im_gama,BackWhiteMask);

%���ɶ�������ɫ�ľ�ֵ
[Back_a,Back_b] = RIOcolor(sampled_back,BackMask);
[Blue_a,Blue_b] = RIOcolor(sampled_Blue,BlueMask);
[Green_a,Green_b] = RIOcolor(sampled_Green,GreenMask);
[Red_a,Red_b] = RIOcolor(sampled_Red,RedMask);
[BackWhite_a,BackWhite_b] = RIOcolor(sampled_BackWhite,BackWhiteMask);

%���������ɫ��ֵ��һ������
color_markers = [Back_a Back_b ; BackWhite_a BackWhite_b; Blue_a Blue_b; Green_a Green_b; Red_a Red_b];

%׼�����������Ҫ�ı���
img = igamm(img, 'sRGB');
img = idouble(img);
%img = imgaussfilt(img,2);
im_lab = rgb2lab(img);
im_a = im_lab(:,:,2);
im_b = im_lab(:,:,3);
nColors = 5;
distance = zeros([size(im_a), nColors]);
%0 = Back; 1=BackWhite; 2=Blue; 3=Green; 4=Red
color_labels = 0:nColors-1;

%��ʼ������벢�����ɫ���
for count = 1:nColors
  distance(:,:,count) = ( (im_a - color_markers(count,1)).^2 + ...
                      (im_b - color_markers(count,2)).^2 ).^0.5;
end
[~, label] = min(distance,[],3);
label = color_labels(label);

end


function [masked] = applyMask(data,mask)
%��ͼƬdata����mask���Ĳ���ȫ���ĳ�0
masked = data;
masked(repmat(~mask,[1 1 size(masked,3)])) = 0;
end

function [fig_a,fig_b] = RIOcolor(fig,mask)
%����maskָ��λ�õ���ɫ�ľ�ֵ
fig_lab = rgb2lab(fig);
fig_a = fig_lab(:,:,2);
fig_b = fig_lab(:,:,3);
fig_a = mean2(fig_a(mask));
fig_b = mean2(fig_b(mask));
end

