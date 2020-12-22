%% prepare cell footprint mat for cellreg
dir_list = {
    'D:\Xingjian\SH_subpop\GABA\GA10_dTTexp1\',
    'D:\Xingjian\SH_subpop\GABA\GA10_dTTexp2\',
    'D:\Xingjian\SH_subpop\GABA\GA10_dTTexp3\'
}
sep = '\';
exp_list = {'exp1','exp2','exp3'};

file_to_read = 'ms_PCA.mat';

mouse = 'GA10';
save_to = ['D:\Xingjian\SH_subpop\GABA\cell_tracking\',mouse];


%%
if ~exist([save_to,sep])
    mkdir([save_to,sep]);
end
for i = 1:length(dir_list)
   load([dir_list{i},file_to_read]);
   SFPs = ms.SFPs;
   SFPs = permute(SFPs, [3,1,2]);
   save([save_to,sep, mouse, exp_list{i},'.mat'],'SFPs');
    
end


%% align cells by their distance

