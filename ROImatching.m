function ms = ROImatching(ms1,ms2)
% match ms1 ROIs with ms2 ROIs by their correlation
% copy the cell label of ms2 to ms1
% ms1, ms2 are path to ms files of 2 different experiments

ms1 = load(ms1);
ms1 = ms1.ms;
ms2 = load(ms2);
ms2 = ms2.ms;


ROI1 = ms1.SFPs; % X x Y x Num
ROI2 = ms2.SFPs;
% linearize SFPs
ROI1_li = reshape(ROI1, [], size(ROI1,3));
ROI2_li = reshape(ROI2, [], size(ROI2,3));  % NumPix x NumROI

cell_label1 = zeros(size(ROI1,3),1);
cell_label2 = ms2.cell_label;

% correlation matrix
ROIcov = transpose(ROI1_li) * ROI2_li; % row: ROI1 column: ROI2

% for all good ROI2s, find the most correlated ROI1 and set its label to 1
[~, ROI1order] = sort(ROIcov, 1);
ROI1_highest_cov_idx = ROI1order(end,:);
ROI1_putative_good_idx = ROI1_highest_cov_idx(cell_label2>0);
cell_label1(ROI1_putative_good_idx) = 1;
ms = ms1;
ms.cell_label = cell_label1;
save(ms1, 'ms');

end

