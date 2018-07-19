function [Angles] = InternalAngle(aPloy)
%产生多边形的内角
    num_sides = aPloy.numsides;
    poly_Vertices = aPloy.Vertices;
    Angles = zeros(num_sides,1);
    
    for i = 1:1:num_sides
        center_point = poly_Vertices(i,:);
        j = i-1;
        if j <= 0
            j = num_sides;
        end
        previous = poly_Vertices(j,:);
        j = i + 1;
        if j > num_sides
            j = 1;
        end
        latter = poly_Vertices(j,:);
        
        Vector_A = previous - center_point;
        Vector_B = latter - center_point;
        norm_A = norm(Vector_A,2);
        norm_B = norm(Vector_B,2);
        Angles(i) = acos(dot(Vector_A,Vector_B)/(norm_A * norm_B));
    end
end
