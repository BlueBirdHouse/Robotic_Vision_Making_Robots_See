function [AROI] = ROI_estimate(aPloy,ROI_R,h_figure,h_image)
%ROI_estimate 利用aPloy所表述的个点，预测所有可能的ROI，并生成一个大的ROI
    num_sides = aPloy.numsides;
    poly_Vertices = aPloy.Vertices;
    ROI_Centers = zeros(2,0);
    for i = 1:1:num_sides
        center_point = poly_Vertices(i,:);
        ROI_Centers = [ROI_Centers center_point'];
        j = i + 1;
        if j > num_sides
            j = 1;
        end
        latter = poly_Vertices(j,:);
        x1 = center_point(1);
        y1 = center_point(2);
        x2 = latter(1);
        y2 = latter(2);

        estimate_Ax = 2*x2-x1;
        estimate_Ay = 2*y2-y1;
        if ((estimate_Ax - ROI_R)>0) && ((estimate_Ay - ROI_R)>0)
            estimate_Ax = round(estimate_Ax);
            estimate_Ay = round(estimate_Ay);
            ROI_Centers = [ROI_Centers [estimate_Ax estimate_Ay]'];
        end

        estimate_Bx = 2*x1-x2;
        estimate_By = 2*y1-y2;
        if ((estimate_Bx - ROI_R)>0) && ((estimate_By - ROI_R)>0)
            estimate_Bx = round(estimate_Bx);
            estimate_By = round(estimate_By);
            ROI_Centers = [ROI_Centers [estimate_Bx estimate_By]'];
        end
    end
    AROI = zeros(size(h_image.CData,1),size(h_image.CData,2));
    for i = 1:1:size(ROI_Centers,2)
        h = imellipse(h_figure.CurrentAxes,[ROI_Centers(1,i)-ROI_R ROI_Centers(2,i)-ROI_R ROI_R*2 ROI_R*2]);
        AROI = AROI | h.createMask(h_image);
        Temp = 0;
    end
end

