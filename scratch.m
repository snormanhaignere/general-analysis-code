clear S;
S.a = '1';
S.b = [2,3,4];
struct2string(S, 'maxlen', 2, 'delimiter', '/')




switch group_or_individ
    case 'group'
        
        load([root_directory '/spectrotemporal-synthesis-fMRI/analysis/tonotopy-centroids/all-centroids.mat'], ...
            'lowfreq_voxels_group_XY');
        
        % x and y position of low-frequency centroid
        mask_dims = lowfreq_voxels_group_XY(q,:); %#ok<NODEF>
        clear lowfreq_voxels_group_XY;
        
    case 'individ'
        
load([root_directory '/spectrotemporal-synthesis-fMRI/analysis/tonotopy-centroids/all-centroids.mat'], ...
    'lowfreq_voxels_individ_XY');

% select relevant voxel
xi = ...
    I.usubs(k) == lowfreq_voxels_individ_XY(:,1) & ...
    q == lowfreq_voxels_individ_XY(:,2); %#ok<NODEF>
assert(sum(xi)==1);
mask_dims = lowfreq_voxels_individ_XY(xi, 3:4);
clear xi lowfreq_voxels_individ_XY;
end

spatial_dims = size(G.grid_data{q});
distance_maps{k,q} = nan(spatial_dims);
for i = 1:spatial_dims(1)
    for j = 1:spatial_dims(2)
        if ~isnan(G.grid_data{q}(i,j))
            
            % distance to the nearest voxel in the mask
            X = bsxfun(@minus, [G.grid_x{q}(i,j), G.grid_y{q}(i,j)], mask_dims);
            distance_maps{k,q}(i,j) = min(sqrt(sum(X.^2,2)));
            
        end
    end
end