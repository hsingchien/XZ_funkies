function cvout = cvPCA(Trace,k,nullrepeats,kspacing,p)
    if ~exist('kspacing','var') || isempty(kspacing)
        kspacing = 30;
    end
    if ~exist('k','var') || isempty(k)
        k = 5;
    end
    if ~exist('nullrepeats','var') || isempty(nullrepeats)
        nullrepeats = 2000;
    end
        
    Trace = zscore(Trace); % zscore Trace
    % get trainingsets & testsets
    Y = ones([size(Trace,1),1]); % generate fake labels
    [trainingsets, testsets] = CVPartition_Spacing(Y,kspacing,k);
    cvout = struct();
    cvout.trainingsets = trainingsets; cvout.testsets = testsets;
    pcCoeff = cell(1,k); pcExp = cell(1,k); nullExp = cell(1,k);
    dimensionLogic = cell(1,k);
    for i = 1:k
        trainingTrace = Trace(trainingsets{i},:);
        trainingTrace = zscore(trainingTrace); % only zscore training
        testTrace = Trace(testsets{i},:); % test trace use original
        [coeff_tr,~,~,~,varexp_tr] = pca(trainingTrace);
        test_proj = testTrace * coeff_tr;
        varexp_test = diag(cov(test_proj))/trace(cov(test_proj)) * 100;
        pcCoeff{i} = coeff_tr; pcExp{i} = [varexp_tr'; varexp_test'];
        
        %% generate null distribution
        varexp_null = [];
        for j = 1:nullrepeats
            % permute test before projection
            test_perm = testTrace(:, randperm(size(testTrace,2)));
            test_perm_proj = test_perm * coeff_tr;
            varexp_test_perm = diag(cov(test_perm_proj))/trace(cov(test_perm_proj)) * 100;
            varexp_null = cat(1,varexp_null, varexp_test_perm');
        end
        nullExp{i} = varexp_null;
        %% compare the var_explained to null distribution
        if ~exist('p','var') || isempty(p)
            p = 1/size(trainingTrace,2);
        end
        thresholdlow = quantile(varexp_null,p,1);
        thresholdhigh = quantile(varexp_null,1-p,1);
        dimensionhigh = varexp_test' >= thresholdhigh;
        dimensionlow = varexp_test' <= thresholdlow; 
        dimensionLogic{i} = [dimensionhigh; dimensionlow];

    end
    cvout.pcCoeff = pcCoeff; cvout.pcExp = pcExp; cvout.nullExp = nullExp;
    cvout.dimensionLogic = dimensionLogic;


end


