vid = VideoReader('right.avi');
vidmat = read(vid);
vidmat = squeeze(vidmat(:,:,1,:));
numF = vid.NumFrames;
tdsample = 1;
xwidth = vid.Width;
ywidth = vid.Height;
numV = floor(numF/tdsample/1000);
if tdsample>1
    frame_to_down_sample = numF - mod(numF, tdsample);
    vmat_down = squeeze(uint8(mean(reshape(vidmat(:,:,1:frame_to_down_sample), ywidth, xwidth, tdsample, []),3)));
    vidmat = vmat_down;
end
for i = 0:numV
    viw = VideoWriter([num2str(i),'.avi'],'Grayscale AVI');
    viw.FrameRate = 15;
    open(viw);
    if i == numV
        writeVideo(viw, vidmat(:,:,i*1000+1:end));
    else
        writeVideo(viw, vidmat(:,:,i*1000+1:i*1000+1000));
    end
    close(viw);
   
    
end

clear all;