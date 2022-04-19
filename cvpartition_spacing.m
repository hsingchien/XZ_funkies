function [trainingsets,validationsets] = cvpartition_spacing(Y, spacing, fold)
% input timeseries label, spacing (units data points) and fold
% output cross validation partition index, stratified
    trainingsets = cell(1,fold);
    validationsets = cell(1,fold);
    labels = unique(Y);
    label_idx = cell(1,length(labels));
    for i = 1:length(labels)
        label_idx{i} = find(Y == labels(i));
    end
    for m = 1:length(label_idx)
        % generate random starting point
        vali_start = randi(length(label_idx{m}));
        for i = 1:fold
            numvali = floor((length(label_idx{m})-2*spacing)/fold);
            if vali_start+numvali-1 <= length(label_idx{m})
                validationsets{i} = [validationsets{i}; label_idx{m}(vali_start:vali_start+numvali-1)];
                trainingsets{i} = [trainingsets{i}; label_idx{m}([1:vali_start-spacing-1, vali_start+numvali+spacing:length(label_idx{m})])];
                vali_start = vali_start + numvali;
            else
                vali_end = numvali-(length(label_idx{m})-vali_start + 1);
                validationsets{i} = [validationsets{i}; label_idx{m}(vali_start:end); label_idx{m}(1:vali_end)];
                trainingsets{i} = [trainingsets{i}; label_idx{m}(vali_end+spacing+1:vali_start-spacing-1)];
                vali_start = vali_end+1;
            end
        end
    end
end