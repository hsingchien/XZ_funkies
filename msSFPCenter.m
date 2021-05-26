function ms = msSFPCenter(ms)
        C = zeros([size(ms.SFPs, 3), 2]);
        [x_m, y_m] = meshgrid(1:size(ms.SFPs,2), 1:size(ms.SFPs,1)); % x mesh, dimension 2; y mesh dimension 1
        for j = 1:size(ms.SFPs, 3)           
            c_all = sum(ms.SFPs(:,:,j), 'all');
            x_c = round(sum(x_m .* ms.SFPs(:,:,j) / c_all, 'all'));
            y_c = round(sum(y_m .* ms.SFPs(:,:,j) / c_all, 'all'));
            C(j,:) = [x_c, y_c];        
        end
        ms.centroids_xz = C;
        
end

