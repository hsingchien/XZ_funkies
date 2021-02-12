function [to_copys,copy_tos] = CopyFolderStruct(from, to)
% copy folder structure. create same folder structure (empty in To
% directory)

if ispc
    separator = '\'; % For pc operating systems
else
    separator = '/'; % For unix (mac, linux) operating systems
end


if ~iscell(from)
    from = {from};
end
if ~iscell(to)
    to = {to};
end

for i = 1:length(from)
    from{i} = strrep(from{i}, '\', separator);
    from{i} = strrep(from{i}, '/', separator);
end

for i = 1:length(to)
    to{i} = strrep(to{i}, '\', separator);
    to{i} = strrep(to{i}, '/', separator);
end

to_copys = {};
copy_tos = {};

for j = 1:length(from)
    cwd = from{j};
    dirs = dir([cwd,'\**\']);
    dirs = dirs([dirs(:).isdir]);
    valid_fs = [];
    path_lengths = [];
    for i = 1:length(dirs)
       if ~or(strcmp(dirs(i).name, '.'), strcmp(dirs(i).name, '..'))
          valid_fs = [valid_fs, i];
          path_lengths = [path_lengths, length(dirs(i).folder)];
       end
    end
    dirs = dirs(valid_fs);
    [~, r] = sort(path_lengths);
    dirs = dirs(r);
    for i = 1:length(dirs)
       to_copy = [dirs(i).folder,'\',dirs(i).name];
       copy_to = strrep(to_copy, from{j}, to{j});
       
       to_copys = [to_copys, to_copy];
       copy_tos = [copy_tos, copy_to];
       if ~exist(copy_to)
          mkdir(copy_to); 
       else
           fprintf('%s exist already\n', copy_to);
       end
    end

end

end

