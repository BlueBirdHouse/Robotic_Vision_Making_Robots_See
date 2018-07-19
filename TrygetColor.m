load('./data/fig4.mat')
figure;
idisp(image);

%% ͼ��Ԥ����
im_gama = igamm(image, 'sRGB');
image_illuminant = illumgray(im_gama, 0);
im_gama = chromadapt(im_gama, image_illuminant, 'ColorSpace', 'linear-rgb');
im_lab = rgb2lab(im_gama);

%% ��ͼ���������࣬��ɫ�Ļ�͹�Գ������Ӷ���ö�λ��
im_ab = im_lab(:,:,2:3);
ncols = size(im_ab,2);
nrows = size(im_ab,1);
im_ab = reshape(im_ab,nrows*ncols,2);
nColors = 2;
[cluster_idx, ~] = kmeans(im_ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
figure;
idisp(pixel_labels);

%% �ҵ���ʱ���Զ�λ�ĵ㣬�Ʋⲻ�ܶ�λ�ĵ��λ��
b = iblobs(pixel_labels);
b_found = b([b.area] > 100);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');

num_b_found = length(b_found);
%�����Щ����������
combineBlobs = nchoosek((1:1:num_b_found),4);
b_found_coordinate = (b_found.p)';

%ʹ�������ٷֵķ����������ı���
polyins = [];
for i = 1:1:size(combineBlobs,1)
    a_combineBlob = combineBlobs(i,:);
    a_poly_points = b_found_coordinate(a_combineBlob,:);
    %�������ٷ������¹滮��Щ���˳���Ա��ܹ����һ��͹�����
    DT = delaunayTriangulation(a_poly_points);
    a_poly_points_rearrange = convexHull(DT);
    if(size(a_poly_points_rearrange,1) <= 4)
        %ȥ�������εİ���͹�����
        continue;
    end
     a_poly_points_rearrange = a_poly_points_rearrange(1:end-1,1);
     a_poly_points = a_poly_points(a_poly_points_rearrange,:);
     a_polyin = polyshape(a_poly_points);

     %�������ɵ��ı���
     polyins = [polyins a_polyin];
end

%% Ѱ���ı����ڽ�,���޳��ڽǱ仯������ı���
InternalAngle_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    InternalAngle_list(:,i) = rad2deg(InternalAngle(polyins(i)));
end
var_InternalAngle = var(InternalAngle_list,0,1);
right_angle_poly = find(var_InternalAngle < 200);
polyins = polyins(1,right_angle_poly);

%% Ѱ���ı��εı߳�,���޳��ڽǱ仯������ı���
SideLength_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    SideLength_list(:,i) = SideLength(polyins(i));
end
var_SideLength = var(SideLength_list,0,1);
same_Length_poly = find(var_SideLength < 300);
polyins = polyins(1,same_Length_poly);

%% ����������
%�ҵ���ӽ�ԭ����ı���
[polyins_Cx,polyins_Cy] = polyins.centroid;
polyins_dist = sqrt(polyins_Cx.^2 + polyins_Cy.^2);
[~,zero_polyin] = min(polyins_dist);
zero_polyin = polyins(zero_polyin);
P_model = [270 100 100 270; 100 100 270 270];
H = homography((zero_polyin.Vertices)',P_model);
image_fixed = homwarp(H, image,'full');

%�ٴ����ָ�
%% ���ͼ���ڵ�NaN��Ϣ��
image = image_fixed;
image(isnan(image) == true) = 0; 
h_figure = figure;
h_image = imshow(image);

%% ͼ��Ԥ����
im_gama = igamm(image, 'sRGB');
im_lab = rgb2lab(im_gama);

%% ��ͼ���������࣬��ɫ�Ļ�͹�Գ������Ӷ���ö�λ��
im_ab = im_lab(:,:,2:3);
ncols = size(im_ab,2);
nrows = size(im_ab,1);
im_ab = reshape(im_ab,nrows*ncols,2);
nColors = 2;
[cluster_idx, cluster_center] = kmeans(im_ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);
figure;
idisp(pixel_labels);

%% �ҵ���ʱ���Զ�λ�ĵ㣬�Ʋⲻ�ܶ�λ�ĵ��λ��
b = iblobs(pixel_labels);
b_found = b([b.area] > 300);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');
num_b_found = length(b_found);
%�����Щ����������
combineBlobs = nchoosek((1:1:num_b_found),4);
b_found_coordinate = (b_found.p)';

%ʹ�������ٷֵķ����������ı���
polyins = [];
for i = 1:1:size(combineBlobs,1)
    a_combineBlob = combineBlobs(i,:);
    a_poly_points = b_found_coordinate(a_combineBlob,:);
    %�������ٷ������¹滮��Щ���˳���Ա��ܹ����һ��͹�����
    DT = delaunayTriangulation(a_poly_points);
    a_poly_points_rearrange = convexHull(DT);
    if(size(a_poly_points_rearrange,1) <= 4)
        %ȥ�������εİ���͹�����
        continue;
    end
     a_poly_points_rearrange = a_poly_points_rearrange(1:end-1,1);
     a_poly_points = a_poly_points(a_poly_points_rearrange,:);
     a_polyin = polyshape(a_poly_points);

     %�������ɵ��ı���
     polyins = [polyins a_polyin];
end

%% Ѱ���ı����ڽ�,���޳��ڽǱ仯������ı���
InternalAngle_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    InternalAngle_list(:,i) = rad2deg(InternalAngle(polyins(i)));
end
var_InternalAngle = var(InternalAngle_list,0,1);
right_angle_poly = find(var_InternalAngle < 200);
polyins = polyins(1,right_angle_poly);

%% Ѱ���ı��εı߳�,���޳��ڽǱ仯������ı���
SideLength_list = zeros(4,size(polyins,2));
for i = 1:1:size(polyins,2)
    SideLength_list(:,i) = SideLength(polyins(i));
end
var_SideLength = var(SideLength_list,0,1);
same_Length_poly = find(var_SideLength < 300);
polyins = polyins(1,same_Length_poly);

%% ��ʼ����С��ROI
max_b_found_area = max([b_found.area]);
ROI_R = sqrt(max_b_found_area/pi) + 10;

ROI = zeros(size(h_image.CData,1),size(h_image.CData,2));
for i = 1:1:size(polyins,2)
    aPloy = polyins(i);
    [AROI] = ROI_estimate(aPloy,ROI_R,h_figure,h_image);
    ROI = AROI | ROI;
end

%% ��ROI���������·���
%Ӧ��Mask
maskedImage = image;
maskedImage(repmat(~ROI,[1 1 3])) = 0;
idisp(maskedImage);
[ROI,maskedImage] = segmentImage(maskedImage);
figure;
idisp(maskedImage);
figure;
idisp(ROI);

%% ��ROI����������γ������
b = iblobs(ROI);
b_found = b([b.area] > 100);
[~,index] = max([b_found.area]);
b_found(index) = [];
b_found.plot_centroid('sequence');





