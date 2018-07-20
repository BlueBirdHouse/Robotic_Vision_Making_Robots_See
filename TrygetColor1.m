load('./data/fig8.mat')
figure;
idisp(lin2rgb(image));

label = markColor(image);
figure;
idisp(label)



function label = markColor(img)
%录入标准图像
data = load('./data/fig1.mat');
image_std = data.image;
%录入采样用的Mask
data = load('./data/Masks.mat');
BackMask = data.BackMask;
BackWhiteMask = data.BackWhiteMask;
BlueMask = data.BlueMask;
GreenMask = data.GreenMask;
RedMask = data.RedMask;

%显示图像并预处理
im_gama = igamm(image_std, 'sRGB');
im_gama = idouble(im_gama);

%生成样本颜色
sampled_back = applyMask(im_gama,BackMask);
sampled_Blue = applyMask(im_gama,BlueMask);
sampled_Green = applyMask(im_gama,GreenMask);
sampled_Red = applyMask(im_gama,RedMask);
sampled_BackWhite = applyMask(im_gama,BackWhiteMask);

%生成对样本颜色的均值
[Back_a,Back_b] = RIOcolor(sampled_back,BackMask);
[Blue_a,Blue_b] = RIOcolor(sampled_Blue,BlueMask);
[Green_a,Green_b] = RIOcolor(sampled_Green,GreenMask);
[Red_a,Red_b] = RIOcolor(sampled_Red,RedMask);
[BackWhite_a,BackWhite_b] = RIOcolor(sampled_BackWhite,BackWhiteMask);

%组合样本颜色均值到一个矩阵
color_markers = [Back_a Back_b ; BackWhite_a BackWhite_b; Blue_a Blue_b; Green_a Green_b; Red_a Red_b];

%准备距离计算需要的变量
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

%开始计算距离并求出颜色标记
for count = 1:nColors
  distance(:,:,count) = ( (im_a - color_markers(count,1)).^2 + ...
                      (im_b - color_markers(count,2)).^2 ).^0.5;
end
[~, label] = min(distance,[],3);
label = color_labels(label);

end


function [masked] = applyMask(data,mask)
%将图片data里面mask掉的部分全部改成0
masked = data;
masked(repmat(~mask,[1 1 size(masked,3)])) = 0;
end

function [fig_a,fig_b] = RIOcolor(fig,mask)
%返回mask指定位置的颜色的均值
fig_lab = rgb2lab(fig);
fig_a = fig_lab(:,:,2);
fig_b = fig_lab(:,:,3);
fig_a = mean2(fig_a(mask));
fig_b = mean2(fig_b(mask));
end

