function badF = RemvBadFrame(vidpath)
%% remove bad frames

% reshape to n x t
vidR = VideoReader(vidpath);
vid = squeeze(read(vidR)); % vid, Y x X x T

vidt = reshape(vid, [], size(vid, 3));
mvidt = mean(vidt, 1);
difmvidt = diff(mvidt);
sdmvidt = std(difmvidt);

thr = 10; % anything below thr 

dim_frames = find(mvidt <= thr);


badF.badFs = dim_frames;

badF.corrected_v = vid(:,:,setdiff(1:size(vid,3), dim_frames));



end

