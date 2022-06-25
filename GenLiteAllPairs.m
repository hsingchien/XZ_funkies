%% remove bad cells, unnecessary fields etc.
% transpose S. 
m_fields_to_keep = {'FiltTraces','S','centroids_xz','SFPs'};
animal_fields_to_remove = {'Annotation','Event'};

for i = 1:length(allPairs);
    for j = 1:2
        allPairs{i}{j} = rmfield(allPairs{i}{j}, animal_fields_to_remove);
        for m = 1:length(allPairs{i}{j}.MS)
            allPairs{i}{j}.MS{m}.FiltTraces = allPairs{i}{j}.MS{m}.FiltTraces(:, logical(allPairs{i}{j}.MS{m}.goodCellVec));
            allPairs{i}{j}.MS{m}.S = transpose(allPairs{i}{j}.MS{m}.S);
            allPairs{i}{j}.MS{m}.S = allPairs{i}{j}.MS{m}.S(:, logical(allPairs{i}{j}.MS{m}.goodCellVec));
            allPairs{i}{j}.MS{m} = rmfield(allPairs{i}{j}.MS{m}, setdiff(fields(allPairs{i}{j}.MS{m}), m_fields_to_keep));

        end
    end
end


for i = 1:length(allPairs)
    toyid = find(contains(allPairs{i}{1}.videoInfo.session,'toy'));
    toyid = toyid';
    for k = toyid
        if ~isempty(allPairs{i}{1}.Behavior{k})
            fprintf('Pair%d\n',i);
        end
    end
end