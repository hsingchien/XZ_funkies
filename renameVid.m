avis = dir('*.avi');
avis = {avis.name};
avi_id_list = [];
for i = 1:length(avis)
    temp = split(avis{i}, '.');
    fname = temp{1};
    digit_i = regexp(fname, '\d*');
    digi_n = str2num(fname(digit_i(end):end));
    movefile([num2str(digi_n),'.avi'], ['XZ152\', num2str(digi_n+28),'.avi']);
    avi_id_list = [avi_id_list, digi_n];
end 
  