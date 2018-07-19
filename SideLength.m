function [lengths] = SideLength(aPloy)
    %输出四边形的边长
    num_sides = aPloy.numsides;
    poly_Vertices = aPloy.Vertices;
    lengths = zeros(num_sides,1);
    
    for i = 1:1:num_sides
        center_point = poly_Vertices(i,:);
        j = i + 1;
        if j > num_sides
            j = 1;
        end
        latter = poly_Vertices(j,:);
        
        a_side = latter - center_point;
        lengths(i) = norm(a_side,2);
    end
end