function BehavRaster(estruct, behav_patch)

fr=30;
tm = length(estruct.Behavior.LogicalVecs{1});

figure('position', [1 1 1000 1000]);
a = axes('NextPlot', 'add');
% patch behaviors

    allTypes = setdiff(estruct.Behavior.EventNames,'pooled');

    if exist('maxdistcolor')
        cls = maxdistcolor(length(allTypes), @sRGB_to_CIELab);
    else
        error('add maxdistcolor to the path');
    end

    fn=fieldnames(estruct.behaviorStruct);



    % patch sbj behavior bouts
    if strcmp(behav_patch{1}, 'all')
        behav_in_this_m = intersect(allTypes, fn);
    else
        behav_in_this_m = intersect(strsplit(behav_patch{1}, ','), fn);
    end


    beh_height = 0;
    
    for l = 1:length(behav_in_this_m)
        ind = find(strcmp(allTypes, behav_in_this_m{l}));
        onsets=estruct.behaviorStruct.(behav_in_this_m{l}).start;
        offsets=estruct.behaviorStruct.(behav_in_this_m{l}).end;
        for n = 1:length(onsets)
            P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[beh_height, beh_height+2, beh_height+2, beh_height],cls(ind,:),'EdgeColor',cls(ind,:), 'FaceAlpha', 0.5);
        end
        if ~isempty(onsets)
            text(tm/fr+20, beh_height, behav_in_this_m{l},'Color',cls(ind,:));
            beh_height = beh_height + 0.5;
        end
       
    end
    text(tm/fr+20, beh_height+1, 'Sbj behavior');
    % patch([1 1 tm tm],[0 50 50 0],[0.1 0.4 0.1],'FaceAlpha',0.06)
    % hold on
    line(a, a.XLim, [beh_height+2, beh_height+2],'Color','r');
    beh_height = beh_height+4;
    % patch opp behavior bouts
    if isfield(estruct, 'OppBehavior') % check if this is the dual animal case
        fn=estruct.OppBehavior.EventNames;
        
        if strcmp(behav_patch{2}, 'all')
            op_behav_in_this_m = intersect(allTypes, fn);
        else
            op_behav_in_this_m = intersect(strsplit(behav_patch{2}, ','), fn);
        end


        for l = 1:length(op_behav_in_this_m)
            indc = find(strcmp(allTypes, op_behav_in_this_m{l}));
            indd = find(strcmp(estruct.OppBehavior.EventNames, op_behav_in_this_m{l}));
            onsets=estruct.OppBehavior.OnsetTimes{indd};
            offsets=estruct.OppBehavior.OffsetTimes{indd};

            for n = 1:length(onsets)
                P(l)= patch([onsets(n) onsets(n) offsets(n) offsets(n)]/fr,[beh_height,beh_height+2,beh_height+2,beh_height],cls(indc,:),'EdgeColor',cls(indc,:), 'FaceAlpha', 0.5); 
            end
            if ~isempty(onsets)
                text(tm/fr+20, beh_height, op_behav_in_this_m{l},'Color',cls(indc,:));
                beh_height = beh_height + 0.5;
            end
            
        end
    end

    % patch for behavior legend
    block = round(tm/fr/length(allTypes));
    for i = 1:length(allTypes)
       ll = (i-1) * block; 
       patch([ll, ll, ll+block, ll+block], [-2, -1, -1, -2], cls(i,:),'EdgeColor',cls(i,:), 'FaceAlpha', 0.5);
       text(ll, -3, allTypes{i},'FontSize', 8);

    end

    text(tm/fr+20, beh_height+1, 'Opp behavior');
    a.YLim(1) = -4;



end

