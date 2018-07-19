load('./data/fig4.mat')
figure;
idisp(image);

%% 图像预处理
im_gama = igamm(image, 'sRGB');
image_illuminant = illumgray(im_gama, 0);
im_gama = chromadapt(im_gama, image_illuminant, 'ColorSpace', 'linear-rgb');
im_lab = rgb2lab(im_gama);

%% 对图像做二分类，蓝色的会凸显出来，从而获得定位点
im_ab = im_lab(:,:,2:3);
ncols = size(im_ab,2);
nrows = size(im_ab,1);
im_ab = reshape(im_ab,nrows*ncols,2);
nColors = 2;
[cluster_idx, ~] = kmeans(im_ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
figure;
idisp(pixel_labels);

%% 找到暂时可以定位的点，推测不能定位的点的位置
b = iblobs(pixel_labels);
b_found = b([b.area] > 100);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');

num_b_found = length(b_found);
%求解这些点的排列组合
combineBlobs = nchoosek((1:1:num_b_found),4);
b_found_coordinate = (b_found.p)';

%使用三角刨分的方法来生成四边形
polyins = [];
for i = 1:1:size(combineBlobs,1)
    a_combineBlob = combineBlobs(i,:);
    a_poly_points = b_found_coordinate(a_combineBlob,:);
    %用三角刨分来重新规划这些点的顺序，以便能够组成一个凸多边形
    DT = delaunayTriangulation(a_poly_points);
    a_poly_points_rearrange = convexHull(DT);
    if(size(a_poly_points_rearrange,1) <= 4)
        %去掉三角形的包裹凸多边形
        continue;
    end
     a_poly_points_rearrange = a_poly_points_rearrange(1:end-1,1);
     a_poly_points = a_poly_points(a_poly_points_rearrange,:);
     a_polyin = polyshape(a_poly_points);

     %保存生成的四边形
     polyins = [polyins a_polyin];
end

%% 寻找四边形内角,并剔除内角变化过大的四边形
InternalAngle_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    InternalAngle_list(:,i) = rad2deg(InternalAngle(polyins(i)));
end
var_InternalAngle = var(InternalAngle_list,0,1);
right_angle_poly = find(var_InternalAngle < 200);
polyins = polyins(1,right_angle_poly);

%% 寻找四边形的边长,并剔除内角变化过大的四边形
SideLength_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    SideLength_list(:,i) = SideLength(polyins(i));
end
var_SideLength = var(SideLength_list,0,1);
same_Length_poly = find(var_SideLength < 300);
polyins = polyins(1,same_Length_poly);

%% 做初级修正
%找到最接近原点的四边形
[polyins_Cx,polyins_Cy] = polyins.centroid;
polyins_dist = sqrt(polyins_Cx.^2 + polyins_Cy.^2);
[~,zero_polyin] = min(polyins_dist);
zero_polyin = polyins(zero_polyin);
P_model = [270 100 100 270; 100 100 270 270];
H = homography((zero_polyin.Vertices)',P_model);
image_fixed = homwarp(H, image,'full');

%再次做分割
%% 填充图像内的NaN信息。
image = image_fixed;
image(isnan(image) == true) = 0; 
h_figure = figure;
h_image = imshow(image);

%% 图像预处理
im_gama = igamm(image, 'sRGB');
im_lab = rgb2lab(im_gama);

%% 对图像做二分类，蓝色的会凸显出来，从而获得定位点
im_ab = im_lab(:,:,2:3);
ncols = size(im_ab,2);
nrows = size(im_ab,1);
im_ab = reshape(im_ab,nrows*ncols,2);
nColors = 2;
[cluster_idx, cluster_center] = kmeans(im_ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
figure;
idisp(pixel_labels);

%% 找到暂时可以定位的点，推测不能定位的点的位置
b = iblobs(pixel_labels);
b_found = b([b.area] > 300);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');
num_b_found = length(b_found);
%求解这些点的排列组合
combineBlobs = nchoosek((1:1:num_b_found),4);
b_found_coordinate = (b_found.p)';

%使用三角刨分的方法来生成四边形
polyins = [];
for i = 1:1:size(combineBlobs,1)
    a_combineBlob = combineBlobs(i,:);
    a_poly_points = b_found_coordinate(a_combineBlob,:);
    %用三角刨分来重新规划这些点的顺序，以便能够组成一个凸多边形
    DT = delaunayTriangulation(a_poly_points);
    a_poly_points_rearrange = convexHull(DT);
    if(size(a_poly_points_rearrange,1) <= 4)
        %去掉三角形的包裹凸多边形
        continue;
    end
     a_poly_points_rearrange = a_poly_points_rearrange(1:end-1,1);
     a_poly_points = a_poly_points(a_poly_points_rearrange,:);
     a_polyin = polyshape(a_poly_points);

     %保存生成的四边形
     polyins = [polyins a_polyin];
end

%% 寻找四边形内角,并剔除内角变化过大的四边形
InternalAngle_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    InternalAngle_list(:,i) = rad2deg(InternalAngle(polyins(i)));
end
var_InternalAngle = var(InternalAngle_list,0,1);
right_angle_poly = find(var_InternalAngle < 200);
polyins = polyins(1,right_angle_poly);

%% 寻找四边形的边长,并剔除内角变化过大的四边形
SideLength_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    SideLength_list(:,i) = SideLength(polyins(i));
end
var_SideLength = var(SideLength_list,0,1);
same_Length_poly = find(var_SideLength < 300);
polyins = polyins(1,same_Length_poly);

%% 开始生成小的ROI
max_b_found_area = max([b_found.area]);
ROI_R = sqrt(max_b_found_area/pi) + 10;

ROI = zeros(size(h_image.CData,1),size(h_image.CData,2));
for i = 1:1:size(polyins,2)
    aPloy = polyins(i);
    [AROI] = ROI_estimate(aPloy,ROI_R,h_figure,h_image);
    ROI = AROI | ROI;
end

%% 在ROI基础上重新分类
%应用Mask
maskedImage = image;
maskedImage(repmat(~ROI,[1 1 3])) = 0;
idisp(maskedImage);
[ROI,maskedImage] = segmentImage(maskedImage);
figure;
idisp(maskedImage);
figure;
idisp(ROI);

%% 在ROI基础上做高纬度修正
b = iblobs(ROI);
b_found = b([b.area] > 100);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');





