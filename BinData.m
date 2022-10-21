function binedData = BinData(inputData,bwindow,method)
% Bin input data along dimension 1
% inputData t x n matrix
% bwindow int
% method: string 'mean'/'median'



binedData = [];
steps = floor(size(inputData)/bwindow);
for i = 1:steps
    
    thisPiece = GetBlock2(inputData, [(i-1)*bwindow+1, i*bwindow]);
    switch method
        case 'mean'
            thisbin = mean(thisPiece, 1);
        case 'median'
            thisbin = median(thisPiece, 1);
        case 'max'
            thisbin = max(thisPiece,[],1);
    end
    binedData = cat(1, binedData, thisbin);
end


end