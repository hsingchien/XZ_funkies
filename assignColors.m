
function [colors,colorList] = assignColors(behavNames)

behavs = {'attack','chasing','escape','defend','flinch','tussling','threaten',...
    'general-sniffing','sniff_face','sniff_genital',...
    'approach','follow','socialgrooming','mount','interaction',...
    'dig','selfgrooming','climb','exploreobj','biteobj','stand',...
    'human_interfere','other','nesting','attention'};

% 
colors = [];
colorList =       {[1 0.6 0.6],... % attack
                  [1 0.8 0.8],... % chase
                  [1 0.5 1],... % escape
                  [1 0.7 1],... % defend
                  [1 0.8 1],... % flinch
                  [1 0.6 0.6],... % tussling
                  [1 0.8 0.8],... % threaten
                  [0.3 0.8 0.3],... % general sniffing
                  [0.5 0.8 0.5],... % sniff face
                  [0.7 0.8 0.7],... % anogenital sniffing
                  [1 0.8 0.4],... % approach
                  [1 0.8 0.4],... % follow
                  [0.8 0.6 0.3],... % social grooming
                  [0 0.8 0],... % mount
                  [0.3 0.8 0.3],... % interaction
                  [0.6 0.6 1],... % dig
                  [0 1 1],... % selfgrooming
                  [0.6875 0.7656 0.8672],... % climb
                  [0.75 0.75 1],... % explore object
                  [0.75 0.75 1],... % bite obj
                  [0.7875 0.8656 0.9672],... % stand
                  [0.6 0.6 0.6],... % human interfere
                  [1 1 1],...% other, white
                  [0.7875 0.8656 0.9672],... % nesting
                  [1,1,1]}; % running
              
for c = 1:numel(behavNames)
    colors = [colors; colorList{find(strcmp(behavs,behavNames{c}))}];
end

end










