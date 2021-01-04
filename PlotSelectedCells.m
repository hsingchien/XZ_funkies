function PlotSelectedCells(estruct, clist, patchOpp)
% plot behavior bouts and gcamp signal of selected cells in clist
% estruct: struct of a single animal, containing cell traces, behavior
% info, etc.
% clist: indices of cells you want to plot
% patchOpp: default false. whether you want to patch the Opp instead of Sbj
% behaviors upon GCamp traces


fr = 30;
[tm, cellNum] = size(estruct.DataMatrix);


if nargin < 2
    clist = 'all';
    patchOpp = false;
elseif nargin < 3
    patchOpp = false;
end

if strcmp(clist, 'all')
    clist = 1:cellNum;
end

DM = zscore(estruct.DataMatrix);
selDM = DM(:, clist);
figure('position', [1 1 1000 1000]);
a = axes('NextPlot', 'add');
space = 9;

selDM_plot = selDM - repmat(0:space: space*(length(clist)-1), [tm, 1]);

plot(a, (1:tm)/fr, selDM_plot, 'black');

for i = 1:length(clist)
    text(tm/fr+20, -space*(i-1), num2str(clist(i)), 'FontSize', 5);
end

% patch behaviors

allTypes = estruct.Behavior.EventNames;
if exist('maxdistcolor')
    cls = maxdistcolor(length(allTypes), @sRGB_to_CIELab);
else
    error('add maxdistcolor to the path');
end

fn=fieldnames(estruct.behaviorStruct);
behav_in_this_m = intersect(allTypes, fn);


% patch sbj behavior bouts


for l = 1:length(behav_in_this_m)
    ind = find(strcmp(allTypes, behav_in_this_m{l}));
    onsets=estruct.behaviorStruct.(behav_in_this_m{l}).start;
    offsets=estruct.behaviorStruct.(behav_in_this_m{l}).end;

    for n = 1:length(onsets)
        P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[20, 40, 40, 20],cls(ind,:),'EdgeColor',cls(ind,:), 'FaceAlpha', 0.5);
        if ~patchOpp
            ystopper = -space*(length(clist)-1)-2;
            PP(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[0, ystopper, ystopper, 0],cls(ind,:),'EdgeColor',cls(ind,:), 'FaceAlpha', 0.05,'EdgeAlpha',0.05);
        end
    end       
end
text(tm/fr+20, 30, 'Sbj behavior');
% patch([1 1 tm tm],[0 50 50 0],[0.1 0.4 0.1],'FaceAlpha',0.06)
% hold on

% patch opp behavior bouts
if isfield(estruct, 'OppBehavior') % check if this is the dual animal case
    fn=estruct.OppBehavior.EventNames;
    op_behav_in_this_m = intersect(allTypes, fn);

    for l = 1:length(op_behav_in_this_m)
        indc = find(strcmp(allTypes, op_behav_in_this_m{l}));
        indd = find(strcmp(estruct.OppBehavior.EventNames, op_behav_in_this_m{l}));
        onsets=estruct.OppBehavior.OnsetTimes{indd};
        offsets=estruct.OppBehavior.OffsetTimes{indd};

        for n = 1:length(onsets)
            P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[50,70,70,50],cls(indc,:),'EdgeColor',cls(indc,:), 'FaceAlpha', 0.5); 
            if patchOpp
                ystopper = -space*(length(clist)-1)-2;
                PP(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[0, ystopper, ystopper, 0],cls(indc,:),'EdgeColor',cls(indc,:), 'FaceAlpha', 0.05,'EdgeAlpha',0.05);
            end
        end

    end
end

% patch for behavior legend
block = round(tm/fr/length(allTypes));
for i = 1:length(allTypes)
   ll = (i-1) * block; 
   patch([ll, ll, ll+block, ll+block], [80, 90, 90, 80], cls(i,:),'EdgeColor',cls(i,:), 'FaceAlpha', 0.5);
   text(ll, 85, allTypes{i},'FontSize', 8);
    
end



a.YLim = [-space*(length(clist)-1)-2, 90];
text(tm/fr+20, 60, 'Opp behavior');





end

