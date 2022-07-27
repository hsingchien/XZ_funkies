
% dependencies -- mapBehavs, matchPair, deriveBehavs

addpath D:\Xingjian\Repositories\NR_funkies % add simulateROC and dependencies to path

clearvars -except allPairs

%%%% set most important parameters

params.useMatfile = {};%{'allPairs','rocStruct'}; % uses matfile function for loading allPairs and/or rocStruct, no need to load full file

params.runType = 'write'; %%%% 'test' (writes test_ROC structure), 'write' (will prompt before saving), or 'return'

%%%% set ROC file information

info.dateTime = datetime; % write only

info.structPath = pwd; % allPairs F structure path
info.structName = 'allPairs_20220622_lite.mat'; % allPairs F structure filename

info.rocPath = 'D:\UCLA_data\ROC\'; % ROC file save path
info.loadROC = 'create'; % get (gets from rocPath), specify ROC file name, or create (to create new)

info.saveExtension = 'toy_exp'; %%%% extension for ROC filename (will be saved as ROC_saveExtension or test_ROC_saveExtension)

%%%% set ROC run parameters

% pair(s) and session(s)
params.pairSet = 14:19;
params.sessionSet = {'exp'}; % 'sep', 'exp', 'exp#' (e.g. 'exp2'), or any combination (will skip if session does not exist)
%%%% add traces or spikes

% ROC parameters
params.rocTypes = {'self','partner','derived_self','derived_partner'}; % 'self', 'partner', 'derived_self', 'derived_partner', or any combination
params.runAgainst = 'other'; % 'all' or 'other'
params.nSims = 1000; % number of simulations for null distribution
params.setSeed = true; % set seed (will use previous seed set for animal if updating)

% other parameters
params.nWorkers = 8; % number of workers for parallel pool

params.fullBvList = {'attack','approach','chasing','dig','escape','general-sniffing',...
    'sniff_genital','sniff_face','selfgrooming','socialgrooming','defend','exploreobj','climb',...
    'follow','mount','biteobj','flinch','stand','nesting','threaten','interaction','human_interfere','tussling','attention'};
                 
params.deriveBvIdx = {
                      [6,7,8]; % all kinds of sniffing, general-sniffing,sniff_genital,sniff_face
                      [1,3,14,20,23]; % aggressive behaviors, attack, chasing, threaten, tussling
                      [5,11,17,24]; % defensive behaviors, defend, escape, flinch, attention
                      [4,13,18,12,16]; % exploratory behaviors, climb, stand, dig, exploreobj, biteobj
                      [2, 14]; % initiative behaviors, approach, follow
%                       [6,16]; % sniff and bite, general obj investigation behavior
                              };
                      
%%%% load allPairs if requested and not loaded

if ~exist('allPairs','var') && ~any(strcmp(params.useMatfile,'allPairs'))
    disp(['Loading allPairs file ',info.structName,' from ',info.structPath,'......'])
    load([info.structPath,info.structName], 'allPairs');
elseif any(strcmp(params.useMatfile,'allPairs'))
    allPairs = [];
end

%%%% run ROC

simulateROC(allPairs,info,params);

