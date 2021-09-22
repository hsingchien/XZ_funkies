function PlotSelectedCells(estructs, aID, sessionID, clist, behav_patch, patchOpp)
% plot behavior bouts and gcamp signal of selected cells in clist
% estruct: struct of a single animal, containing cell traces, behavior
% info, etc.
% clist: indices of cells you want to plot
% behav_patch: 1x2 cell of string, behaviors you want to patch, parsed by ',',
% first one is subject animal, second one is opponent animal. default 'all'
% patchOpp: default false. whether you want to patch the Opp instead of Sbj
% behaviors upon GCamp traces


fr = 15;




estruct = estructs{aID};
opponent = estructs{setdiff(1:length(estructs),aID)};

[tm, cellNum] = size(estruct.MS{sessionID}.FiltTraces);
 
if ~tm
    tm = length(estruct.Behavior{sessionID}.LogicalVecs{1});
end

if nargin < 2
    clist = 'all';
    behav_patch = {'all','all'};
    patchOpp = false;
elseif nargin < 3
    behav_patch = {'all','all'};
    patchOpp = false;
elseif nargin < 4
    patchOpp = false;
end

if strcmp(clist, 'all')
    clist = 1:cellNum;
end
for i = 1:length(behav_patch)
    temp = behav_patch{i};
    behav_patch{i} = temp(~isspace(temp));
end


DM = zscore(estruct.MS{sessionID}.FiltTraces);
selDM = DM(:, clist);
figure('position', [1 1 1000 1000]);
a = axes('NextPlot', 'add');
space = 9;
if ~isempty(selDM)
    selDM_plot = selDM - repmat(0:space: space*(length(clist)-1), [tm, 1]);
    plot(a, estruct.TimeStamp.Ts{sessionID}.Ms/1000, selDM_plot, 'black');
end


for i = 1:length(clist)
    text(tm/fr+20, -space*(i-1), num2str(clist(i)), 'FontSize', 5);
end

% patch behaviors
if ~isempty(estruct.Behavior{sessionID})
    allTypes = estruct.Behavior{sessionID}.EventNames;
    
    % find behaviors that showed up in this session (both sbj and opp)
    behavior_in_this_session_sbj = allTypes(~cellfun(@isempty, estruct.Behavior{sessionID}.OnsetTimes));
    behavior_in_this_session_opp = opponent.Behavior{sessionID}.EventNames(~cellfun(@isempty, opponent.Behavior{sessionID}.OnsetTimes));
    behavior_in_this_session = unique([behavior_in_this_session_sbj, behavior_in_this_session_opp]);
    behav_to_plot = {};
    for i = 1:length(behav_patch)       
        if and(strcmp(behav_patch{i}, 'all'), i==aID)
            temp_behav_to_plot = behavior_in_this_session_sbj;
            behav_to_plot_sbj = temp_behav_to_plot;
        elseif strcmp(behav_patch{i}, 'all')
            temp_behav_to_plot = behavior_in_this_session_sbj;
            behav_to_plot_opp = temp_behav_to_plot;
        elseif i==aID
            temp_behav_to_plot = intersect(strsplit(behav_patch{i}, ','), behavior_in_this_session_sbj);
            behav_to_plot_sbj = temp_behav_to_plot;
        else
            temp_behav_to_plot = intersect(strsplit(behav_patch{i}, ','), behavior_in_this_session_opp);
            behav_to_plot_opp = temp_behav_to_plot;
        end
        behav_to_plot = [behav_to_plot,temp_behav_to_plot];
    end
    behav_to_plot = unique(behav_to_plot);
    
    if exist('maxdistcolor')
        cls = maxdistcolor(length(behav_to_plot), @sRGB_to_CIELab);
    else
        error('add maxdistcolor to the path');
    end




    for l = 1:length(behav_to_plot_sbj)
        ind = find(strcmp(behav_to_plot, behav_to_plot_sbj{l})); % index for color map
        indd = find(strcmp(estruct.Behavior{sessionID}.EventNames, behav_to_plot_sbj{l})); % index in Behavior Structure
        onsets=estruct.Behavior{sessionID}.OnsetTimes{indd};
        offsets=estruct.Behavior{sessionID}.OffsetTimes{indd};

        for n = 1:length(onsets)
            onsetTime = estruct.TimeStamp.Ts{sessionID}.Bv(onsets(n)+1)/1000;
            offsetTime = estruct.TimeStamp.Ts{sessionID}.Bv(offsets(n)+1)/1000;
            P(l)= patch([onsetTime onsetTime offsetTime offsetTime],[18, 23, 23, 18],cls(ind,:),'EdgeColor',cls(ind,:), 'FaceAlpha', 0.5);
            if ~patchOpp
                ystopper = -space*(length(clist)-1)-2;
                PP(l)= patch([onsetTime onsetTime offsetTime offsetTime],[0, ystopper, ystopper, 0],cls(ind,:),'EdgeColor',cls(ind,:), 'FaceAlpha', 0.15,'EdgeAlpha',0.05);
            end
        end       
    end
    text(tm/fr+20, 20.5, 'Sbj');
    % patch([1 1 tm tm],[0 50 50 0],[0.1 0.4 0.1],'FaceAlpha',0.06)
    % hold on

    % patch opp behavior bouts

    for l = 1:length(behav_to_plot_opp)
        indc = find(strcmp(behav_to_plot, behav_to_plot_opp{l}));
        indd = find(strcmp(opponent.Behavior{sessionID}.EventNames, behav_to_plot_opp{l}));
        onsets = opponent.Behavior{sessionID}.OnsetTimes{indd};
        offsets= opponent.Behavior{sessionID}.OffsetTimes{indd};

        for n = 1:length(onsets)
            onsetTime = opponent.TimeStamp.Ts{sessionID}.Bv(onsets(n)+1)/1000;
            offsetTime = opponent.TimeStamp.Ts{sessionID}.Bv(offsets(n)+1)/1000;
            P(l)= patch([onsetTime onsetTime offsetTime offsetTime],[25,30,30,25],cls(indc,:),'EdgeColor',cls(indc,:), 'FaceAlpha', 0.5); 
            if patchOpp
               ystopper = -space*(length(clist)-1)-2;
               PP(l)= patch([onsetTime onsetTime offsetTime offsetTime],[0, ystopper, ystopper, 0],cls(indc,:),'EdgeColor',cls(indc,:), 'FaceAlpha', 0.15,'EdgeAlpha',0.05);
            end
        end

    end
    end

    % patch for behavior legend
    block = round(tm/fr/length(behav_to_plot));
    for i = 1:length(behav_to_plot)
       ll = (i-1) * block; 
       patch([ll, ll, ll+block, ll+block], [32, 35, 35, 32], cls(i,:),'EdgeColor',cls(i,:), 'FaceAlpha', 0.5);
       text(ll, 34, behav_to_plot{i},'FontSize', 10);

    end


    a.YLim = [-space*(length(clist)-1)-2, 37];
    a.XLim = [0,tm/fr+20];
    text(tm/fr+20, 27.5, 'Opp');





end

