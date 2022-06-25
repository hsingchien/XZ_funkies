
function sigMat = getSigCells(rocStruct,sigThr,varargin)

    if nargin > 2
        behavList = varargin{1};
        exclBehavs = varargin{2};
    else
        behavList = [];
        exclBehavs = [];
    end
    
    exclBehavInds = find(ismember(behavList,exclBehavs));
    
    nCells = size(rocStruct.auROC,1);
    nBehav = size(rocStruct.auROC,2);
    nSims = numel(rocStruct.auROCrandDist{1,1});
    
    thrTails = [(1-((100-sigThr)/200))+0.001,(100-sigThr)/200];
    
    posThr = ceil(nSims*thrTails(1));
    negThr = ceil(nSims*thrTails(2));
    sigMat = zeros(nCells,nBehav); % z is activated, suppressed, mixed
    
    for neuron = 1:nCells
        
        clear randMat randCell
        
        randCell = rocStruct.auROCrandDist(neuron,:);

        randMat = horzcat(randCell{:}); % sim x behavior for each cell

        posThrMat = randMat(posThr,:);
        negThrMat = randMat(negThr,:);
        
        actCell = rocStruct.auROC(neuron,:) > posThrMat; % logical mat for activation across all behaviors (per cell)
        supCell = rocStruct.auROC(neuron,:) < negThrMat;
        
        actCell(exclBehavInds) = 0;
        supCell(exclBehavInds) = 0;
        
        sigMat(neuron,:) = (actCell-supCell);
        sigMat(neuron,isnan(posThrMat)) = NaN; % keep NaN
    end

    
end
