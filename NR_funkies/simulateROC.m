
function simulateROC(inpStruct,info,params)

tStart = tic; % full runtime start

%%%% check params.rocTypes for errors
if any(~ismember(params.rocTypes,{'self','partner','derived_self','derived_partner'}))

    inp = input('One or more of params.rocTypes does not match main list, would you like to continue? (y/n) ','s');
    if strcmp(inp,'y')
        params.rocTypes(~ismember(params.rocTypes,{'self','partner','derived_self','derived_partner'})) = [];
    else
        fprintf('Run cancelled.\n');
        return
    end
    
end

%%%% set parallel pool
poolInfo = gcp('nocreate'); % check for parallel pool

if isempty(poolInfo) || poolInfo.Connected ~= true
    
    parpool(params.nWorkers); % open parallel pool
    fprintf('\n');
    
elseif poolInfo.NumWorkers ~= params.nWorkers

    delete(gcp('nocreate')); % end current pool
    parpool(params.nWorkers); % open parallel pool
    fprintf('\n');
    
end

%%%% run ROC on pair(s)
for pair = params.pairSet
    
    % check for existing file
    rocDir = dir([info.rocPath]);
    rocNames = {rocDir.name};
    
    sessionNames = transpose(inpStruct{pair}{1}.videoInfo.session);
    expID = inpStruct{pair}{1}.ExperimentID;
    
    if strcmp(info.loadROC,'get') && any(contains(rocNames,expID))
        
        tempLoad = load([info.rocPath,rocNames{contains(rocNames,expID)}]);
        rocStruct = tempLoad.rocStruct;
        rocLoaded = true;
        
        fprintf('Loaded ROC file %s from %s, updating existing ROC structure.\n',rocNames{contains(rocNames,expID)},info.rocPath);
        fprintf('\n');
        
    else
        
        rocStruct = cell(1,2); % initialize rocStruct for pair, to be saved out
        rocLoaded = false;
        
        fprintf('No existing ROC file found, creating new ROC structure.\n');
        fprintf('\n');
        
    end

    % set session information
    nSessions = numel(sessionNames);
%     sessionList = {'sep','toy','exp'};
    runSessions = find(contains(sessionNames,params.sessionSet));

    %%%% run ROC on animals
    for animal = 1:2

        if rocLoaded == true
            rocOut = rocStruct{animal}.ROC;
        else
            rocOut = []; % initialize temporary ROC structure for animal
        end

        anSeedSet = false;

        fprintf('Pair %i (%i out of %i), Animal %i\n',pair,find(pair == params.pairSet),numel(params.pairSet),animal);
        fprintf('\n');
        
        %%%% iterate through ROC types
        for rocType = 1:numel(params.rocTypes) % self, partner, derived_self, derived_partner, or any combination
            
            currType = params.rocTypes{rocType}; % get the current type based on user request
            
            %%%% iterate through sessions
            for session = runSessions
                
                % initialize cells to store run information for updates table
                typeHist = {'','','',''};
                againstHist = {'',''};
                otherFrHist = {'-----','-----','-----','-----'};
                seedHist = {[]};
                
                %%%% check for necessary data in current session
                if isempty(inpStruct{pair}{animal}.Behavior{session}) % self behavior
                   
                    fprintf('Pair %i, Animal %i missing self behavior in %s, skipping session...\n',...
                        pair,animal,sessionNames{session});
                    fprintf('\n');
                    continue
                    
                elseif isempty(inpStruct{pair}{2/animal}.Behavior{session}) % partner animal behavior
                   
                    fprintf('Pair %i, Animal %i missing partner behavior in %s, skipping session...\n',...
                        pair,animal,sessionNames{session});
                    fprintf('\n');
                    continue
                    
%                 else % check EventNames against params.fullBvList
%                     
%                     % check self behavior EventNames against params.fullBvList
%                     [~,bvMatch] = ismember(inpStruct{pair}{animal}.Behavior{session}.EventNames,params.fullBvList); % check whether event names match fullBvList
%                     if ~issorted(bvMatch) || nnz(bvMatch) < numel(params.fullBvList)
% 
%                         fprintf('Pair %i, Animal %i self event names do not match fullBvList, skipping %s session\n',...
%                             pair,animal,sessionNames{session});
%                         fprintf('\n');  
%                         continue
% 
%                     end
%                     
%                     % check partner behavior EventNames against params.fullBvList
%                     [~,bvMatch] = ismember(inpStruct{pair}{2/animal}.Behavior{session}.EventNames,params.fullBvList); % check whether event names match fullBvList
%                     if ~issorted(bvMatch) || nnz(bvMatch) < numel(params.fullBvList)
% 
%                         fprintf('Pair %i, Animal %i partner event names do not match fullBvList (cannot match pair), skipping %s session\n',...
%                             pair,animal,sessionNames{session});
%                         fprintf('\n');
%                         continue
% 
%                     end
                    
                end
                
                %%%% get calcium traces and number of cells for current animal in session
                Z = zscore(inpStruct{pair}{animal}.MS{session}.FiltTraces,0,1);
                nCells = size(Z,2);
                
                %%%% get behavior data for rocType and assign behavior, timestamp, and traces to rocStruct
                switch currType
                    
                    case 'self'

                        B = TimeMatch(inpStruct{pair}{animal}, session);
                        Bpartner = TimeMatch(inpStruct{pair}{2/animal}, session);
                        selfOtherFr = find(B.LogicalVecs{find(strcmp(B.EventNames,'other'))}); % get self other frames for running against other
                        partnerOtherFr = find(Bpartner.LogicalVecs{find(strcmp(Bpartner.EventNames,'other'))}); % get partner other frames for running against other
                        
                        otherFr = intersect(selfOtherFr,partnerOtherFr);
                        if strcmp(params.runAgainst,'other')
                            fracOtherFrames = numel(otherFr)/size(B.LogicalVecs,1);
                            rocOut.(sessionNames{session}).(params.runAgainst).self.Encoding.fracOtherFrames = fracOtherFrames;
                            otherFrHist{1} = fracOtherFrames;
                        end
                        
                        rocOut.(sessionNames{session}).(params.runAgainst).self.zCalciumTraces = Z;
                        rocOut.(sessionNames{session}).(params.runAgainst).self.Behavior = B;
                        rocOut.(sessionNames{session}).(params.runAgainst).self.Encoding.EventNames = B.EventNames;
                        
                        typeHist{1} = 'self'; % data for updates table

                    case 'partner'

                        B = TimeMatch(inpStruct{pair}{2/animal}, session);
                        Bself = TimeMatch(inpStruct{pair}{animal}, session);
                        if animal == 1
                            for bb = 1:numel(B.LogicalVecs)
                                B.LogicalVecs{bb} = B.LogicalVecs{bb}(inpStruct{pair}{animal}.TimeStamp.mapTs{session}.M2toM1);
                            end
                        else
                            for bb = 1:numel(B.LogicalVecs)
                                B.LogicalVecs{bb} = B.LogicalVecs{bb}(inpStruct{pair}{animal}.TimeStamp.mapTs{session}.M1toM2);
                            end
                        end

                        selfOtherFr = find(Bself.LogicalVecs{find(strcmp(Bself.EventNames,'other'))}); % get self other frames for running against other
                        partnerOtherFr = find(B.LogicalVecs{find(strcmp(B.EventNames,'other'))}); % get partner other frames for running against other
                        
                        otherFr = intersect(selfOtherFr,partnerOtherFr);
                        if strcmp(params.runAgainst,'other')
                            fracOtherFrames = numel(otherFr)/size(B.LogicalVecs,1);
                            rocOut.(sessionNames{session}).(params.runAgainst).partner.Encoding.fracOtherFrames = fracOtherFrames;
                            otherFrHist{2} = fracOtherFrames;
                        end
                        
                        rocOut.(sessionNames{session}).(params.runAgainst).partner.zCalciumTraces = Z;
                        rocOut.(sessionNames{session}).(params.runAgainst).partner.Behavior = B;
                        rocOut.(sessionNames{session}).(params.runAgainst).partner.Encoding.EventNames = B.EventNames;
                        
                        typeHist{2} = 'partner'; % data for updates table

                    case 'derived_self'
                        
                        inB = TimeMatch(inpStruct{pair}{animal}, session);
                        inBpartner = TimeMatch(inpStruct{pair}{2/animal}, session);

                        B = deriveBehavs(inB,params.fullBvList,params.deriveBvIdx);
                        Bpartner = deriveBehavs(inBpartner,params.fullBvList,params.deriveBvIdx);
                       
                        selfOtherFr = find(B.LogicalVecs{find(strcmp(B.EventNames,'other'))}); % get self other frames for running against other
                        partnerOtherFr = find(Bpartner.LogicalVecs{find(strcmp(Bpartner.EventNames,'other'))}); % get partner other frames for running against other
                        
                        otherFr = intersect(selfOtherFr,partnerOtherFr);
                        if strcmp(params.runAgainst,'other')
                            fracOtherFrames = numel(otherFr)/size(B.LogicalVecs,1);
                            rocOut.(sessionNames{session}).(params.runAgainst).derived_self.Encoding.fracOtherFrames = fracOtherFrames;
                            otherFrHist{3} = fracOtherFrames;
                        end
                        
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_self.zCalciumTraces = Z;
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_self.Behavior = B;
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_self.Encoding.EventNames = B.EventNames;
%                         rocOut.(sessionNames{session}).(params.runAgainst).derived_self.Encoding.DerivedIdx = B.DerivedIdx;
                        
                        typeHist{3} = 'derived_self'; % data for updates table
                        
                    case 'derived_partner'
                        
                        inB = TimeMatch(inpStruct{pair}{2/animal}, session);
                        inBself = TimeMatch(inpStruct{pair}{animal}, session);

                        B = deriveBehavs(inB,params.fullBvList,params.deriveBvIdx);
                        Bself = deriveBehavs(inBself,params.fullBvList,params.deriveBvIdx);
                        
                        if animal == 1
                            for bb = 1:numel(B.LogicalVecs)
                                B.LogicalVecs{bb} = B.LogicalVecs{bb}(inpStruct{pair}{animal}.TimeStamp.mapTs{session}.M2toM1);
                            end
                        else
                            for bb = 1:numel(B.LogicalVecs)
                                B.LogicalVecs{bb} = B.LogicalVecs{bb}(inpStruct{pair}{animal}.TimeStamp.mapTs{session}.M1toM2);
                            end
                        end

                        selfOtherFr = find(Bself.LogicalVecs{find(strcmp(Bself.EventNames,'other'))}); % get self other frames for running against other
                        partnerOtherFr = find(B.LogicalVecs{find(strcmp(B.EventNames,'other'))}); % get partner other frames for running against other
                        
                        otherFr = intersect(selfOtherFr,partnerOtherFr);
                        if strcmp(params.runAgainst,'other')
                            fracOtherFrames = numel(otherFr)/size(B.LogicalVecs,1);
                            rocOut.(sessionNames{session}).(params.runAgainst).derived_partner.Encoding.fracOtherFrames = fracOtherFrames;
                            otherFrHist{4} = fracOtherFrames;
                        end
                        
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_partner.zCalciumTraces = Z;
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_partner.Behavior = B;
                        rocOut.(sessionNames{session}).(params.runAgainst).derived_partner.Encoding.EventNames = B.EventNames;
%                         rocOut.(sessionNames{session}).(params.runAgainst).derived_partner.Encoding.DerivedIdx = B.DerivedIdx;
                        
                        typeHist{4} = 'derived_partner'; % data for updates table

                end
                
                nBehavs = size(B.LogicalVecs,2); % get number of behaviors (different than fullBvList for derived)
                
                %%%% initialize for storing auROC and auROCrandDist
                obsROC = zeros(nCells,nBehavs);
                randROC = cell(nCells,nBehavs);
    
                %%%% run ROC on behaviors
                for behav = 1:nBehavs
                    
                    % update user on progress
                    switch currType
                        
                        case 'derived_self'

                           tic
                           fprintf(['Pair %i (%i out of %i), Animal %i -- Running %s ROC on derived_self',num2str(behav),' (%i out of %i) in %s session against %s...\n'],...
                                pair,find(pair == params.pairSet),numel(params.pairSet),animal,currType,behav,size(B.LogicalVecs,2),sessionNames{session},params.runAgainst);
                            
                       case 'derived_partner'

                           tic
                           fprintf(['Pair %i (%i out of %i), Animal %i -- Running %s ROC on derived_partner',num2str(behav),' (%i out of %i) in %s session against %s...\n'],...
                                pair,find(pair == params.pairSet),numel(params.pairSet),animal,currType,behav,size(B.LogicalVecs,2),sessionNames{session},params.runAgainst);
                            
                        otherwise

                            tic
                            fprintf('Pair %i (%i out of %i), Animal %i -- Running %s ROC on %s (%i out of %i) in %s session against %s...\n',...
                                pair,find(pair == params.pairSet),numel(params.pairSet),animal,currType,B.EventNames{behav},behav,size(B.LogicalVecs,2),sessionNames{session},params.runAgainst);
                            
                    end
                    
                    %%%% get behavior vector for current behavior
                    switch params.runAgainst
                        
                        case 'all'
                    
                            bvVec = B.LogicalVecs{behav};
                            L = length(bvVec);
                            runZ = Z;
                            againstHist{1} = 'all'; % data for updates table
                            
                        case 'other'
                            
                            runFr = find(B.LogicalVecs{behav} + B.LogicalVecs{find(strcmp(B.EventNames,'other'))}); % stack and sort indices of other and current behavior
                            bvVec = B.LogicalVecs{behav}(runFr); % get indices of other and current behavior
                            L = length(bvVec);
                            runZ = Z(runFr,:); % get traces with indices of other and current behavior
                            againstHist{2} = 'other'; % data for updates table

                    end

                    %%%% get number of simulations and initialize auROC simulation vector
                    nSims = params.nSims;
                    shft = zeros(nSims,1);
                    
                    %%%% get or generate seed if params.setSeed is true and set the seed
                    if params.setSeed && isfield(rocOut.(sessionNames{session}).(params.runAgainst).(currType),'StructureInfo') && ... % get seed if seed was previously set for animal
                            ~strcmp((rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo(1,strcmp(rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo.Properties.VariableNames,'Rng Seed'))),'none')
                        
                        seedIdx = strcmp(rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo.Properties.VariableNames,'Rng Seed');
                        getSeed = table2cell(rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo(1,seedIdx));
                        
                        rocSeed = getSeed{1}; % data for updates table
                        
                        rng(rocSeed);
                        
                    elseif params.setSeed == true && isfield(rocOut.(sessionNames{session}).(params.runAgainst).(currType),'StructureInfo') && ... % get seed if seed was previously none for animal
                            strcmp((rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo(1,strcmp(rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo.Properties.VariableNames,'Rng Seed'))),'none')
                        
                        initSeed = randperm(1000,1);
                        
                        anSeedSet = true;
                        
                        rng(initSeed);
                        rocSeed = rng;
                        
                    elseif params.setSeed == true && ~isfield(rocOut.(sessionNames{session}).(params.runAgainst).(currType),'StructureInfo') && anSeedSet == false % generate new seed if seed was not previously set for animal
                        
                        initSeed = randperm(1000,1);
                        
                        anSeedSet = true;
                        
                        rng(initSeed);
                        rocSeed = rng;
                        
                    elseif params.setSeed == false % don't set seed if not requested
                        
                        rocSeed = 'none'; % data for updates table
                        
                    end

                    %%%% generate random permutations for traces
                    for sim = 1:nSims
                        shft(sim,1) = randperm(L-120,1) + 60;
                    end
                    
                    seedHist = {rocSeed}; % data for updates table
                    
                    %%%% run ROC simulations
                    if nnz(bvVec) > 0 && sum(bvVec == 0) > 0 % check whether current behavior has positive or negative (other against other) class
                    
                        parfor neuron = 1:nCells

                            [~,~,~,obsROC(neuron,behav)] = perfcurve(bvVec,runZ(:,neuron),1);

                            for sim = 1:nSims                  
                                [~,~,~,randROC{neuron,behav}(sim,1)] = perfcurve(bvVec,circshift(runZ(:,neuron),shft(sim,1)),1);
                            end

                            randROC{neuron,behav} = sort(randROC{neuron,behav},'ascend');

                        end
                    
                    else % fill with nans if behavior has no positive or negative (other against other) class
                    
                        obsROC(:,behav) = nan(nCells,1);
                        for neuron = 1:nCells
                            randROC{neuron,behav}(1:nSims,1) = nan;
                        end
                    
                    end
                    
                    toc
                    fprintf('\n');

                end
                
                %%%% store ROC data for rocType and session in temporary rocStruct
                rocOut.(sessionNames{session}).(params.runAgainst).(currType).Encoding.auROC = obsROC;
                rocOut.(sessionNames{session}).(params.runAgainst).(currType).Encoding.auROCrandDist = randROC;
                rocOut.(sessionNames{session}).(params.runAgainst).(currType).RunInfo.info = info;
                rocOut.(sessionNames{session}).(params.runAgainst).(currType).RunInfo.params = params;
                
                %%%% update run history table
                
                structName = {info.structName};
                
                pairID = {inpStruct{pair}{animal}.ExperimentID};
                animalID = {inpStruct{pair}{animal}.AnimalID};
                try
                    genType = {inpStruct{pair}{animal}.GenType};
                end
                typeHist(cellfun(@isempty,typeHist)) = [];
                typeFld = {'------','------','------','------'};
                [typeFld{ismember({'self','partner','derived_self','derived_partner'},typeHist)}] = deal(typeHist{:});

                sessionFld = sessionNames(session);

                againstHist(cellfun(@isempty,againstHist)) = [];
                againstFld = {'-----','-----'};
                [againstFld{ismember({'all','other'},againstHist)}] = deal(againstHist{:});

                otherFrFld = otherFrHist;

                seedFld = seedHist;

                dateTime = {datetime};
                
%                 dependencyStruct = getDependencyStruct();
%                 dependFld = {dependencyStruct};

                versionFld = {version};
                if exist("genType",'var')
                    tempInfo = table(structName,pairID,animalID,genType,sessionFld,againstFld,typeFld,otherFrFld,seedFld,dateTime,...%dependFld, 
                        versionFld,...
                            'VariableNames',...
                            {'E Structure Name','Pair ID','Animal ID','GenType','Session(s)','Run Against','Type(s)','Frac. Other Frames','Rng Seed','Date/Time',...%'Dependency Struct.',
                            'MATLAB Version'});
                else
                    tempInfo = table(structName,pairID,animalID,sessionFld,againstFld,typeFld,otherFrFld,seedFld,dateTime,...%dependFld, 
                        versionFld,...
                            'VariableNames',...
                            {'E Structure Name','Pair ID','Animal ID','Session(s)','Run Against','Type(s)','Frac. Other Frames','Rng Seed','Date/Time',...%'Dependency Struct.',
                            'MATLAB Version'});
                end
                rocOut.(sessionNames{session}).(params.runAgainst).(currType).StructureInfo = tempInfo;
                
                %%%% order fieldnames
                fieldOrder = {'Encoding','StructureInfo','RunInfo','zCalciumTraces','Behavior'};

                if ~isempty(rocOut.(sessionNames{session}).(params.runAgainst).(currType))

                    [~,fieldIdx] = ismember(fieldnames(rocOut.(sessionNames{session}).(params.runAgainst).(currType)),fieldOrder);
                    [~,fieldSort] = sort(fieldIdx(fieldIdx > 0),'ascend');
                    rocOut.(sessionNames{session}).(params.runAgainst).(currType) = orderfields(rocOut.(sessionNames{session}).(params.runAgainst).(currType),fieldSort);

                end
                
            end
    
        end
        
        %%%% assign data to rocStruct for current animal
        rocStruct{animal}.ROC = rocOut; % temporary rocStruct
        rocStruct{animal}.ExperimentID = inpStruct{pair}{animal}.ExperimentID;
        rocStruct{animal}.AnimalID = inpStruct{pair}{animal}.AnimalID;
        try rocStruct{animal}.GenType = inpStruct{pair}{animal}.GenType; end

    end
    
    %%%% save current pair to file
    
    sessionNames = inpStruct{pair}{animal}.videoInfo.session;
    expID = inpStruct{pair}{animal}.ExperimentID;
    
    outName = ['ROC_',expID,'_',date];
    
    fprintf('Pair %i (%i out of %i) -- saving ROC file %s in %s...\n',...
    pair,find(pair == params.pairSet),numel(params.pairSet),outName,info.rocPath);

    savePath = [info.rocPath,'\',outName,'.mat'];
    
    save(savePath,'rocStruct','-v7.3');
    
    fprintf('\n');
    fprintf('ROC file %s saved in %s!\n',outName,info.rocPath);
    
    %%%% delete previous file if loaded and not overwritten
    
    % check for existing file
    rocDir = dir([info.rocPath]);
    rocNames = {rocDir.name};
    
    if nnz(contains(rocNames,expID)) > 1
        
        fileIdx = setdiff(find(contains(rocNames,expID)),find(contains(rocNames,outName)));
        delete([info.rocPath,rocNames{fileIdx}]);
        
    end

end

%%%% display full runtime
tEnd = toc(tStart);

if tEnd < 3600
    
    fprintf('\n');
    fprintf('Done running ROC analysis, full runtime was %i minute(s) and %i second(s).\n',floor(tEnd/(60)),floor(rem(tEnd,60)));
    
else

    fprintf('\n');
    fprintf('Done running ROC analysis, full runtime was %i hour(s) and %i minute(s).\n',floor(tEnd/(3600)),floor(rem(tEnd,3600)/60));

end

end

function B = deriveBehavs(inB,fullBvList,drvidx)
    B = inB;
    B.LogicalVecs = {};
    B.EventNames = {};
    for i = 1:numel(drvidx)
        tempLogicalVecs = zeros(size(inB.LogicalVecs{1}));
        BVids = [];
        for j = drvidx{i}
            curBV = fullBvList{j};
            BVid = find(strcmp(inB.EventNames, curBV));
            if ~isempty(BVid)
                tempLogicalVecs = tempLogicalVecs + inB.LogicalVecs{BVid};
                BVids = [BVids, BVid];
            end
        end
        B.LogicalVecs = [B.LogicalVecs, tempLogicalVecs];
        B.EventNames{i} = strjoin(inB.EventNames(BVids),',');

    end
    B.LogicalVecs = [B.LogicalVecs, inB.LogicalVecs{find(strcmp(inB.EventNames,'other'))}];
    B.EventNames = [B.EventNames,'other'];

end

function B = TimeMatch(iptstr, session)
    B = iptstr.Behavior{session};
    mapT = iptstr.TimeStamp.mapTs{session}.B2M;
    tlength = size(iptstr.MS{session}.FiltTraces,1);
    if mapT < tlength
        mapT = vertcat(mapT, ones([tlength-length(mapT),1])*mapT(end));
    else
        mapT = mapT(1:tlength);
    end
    for i = 1:numel(B.LogicalVecs)
        B.LogicalVecs{i} = B.LogicalVecs{i}(mapT);
    end

end