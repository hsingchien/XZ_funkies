% parse vid to 1000 frames
vid1 = VideoReader('msvideo.avi');
vid2 = VideoReader('exp.avi');
nF1 = vid1.NumFrames;
nF2 = vid2.NumFrames;

numV1 = ceil(nF1/1000);
numV2 = ceil(nF2/1000);

for i = 1:numV1
   viw = VideoWriter([num2str(i-1),'.avi'],'Grayscale AVI');
   viw.FrameRate = 15;
   open(viw);
   for j = 1:1000
      if hasFrame(vid1)
        writeVideo(viw, readFrame(vid1)); 
      else
          break;
      end
   end
   close(viw);
   delete(viw);
    
    
end


for i = 1:numV2
   viw = VideoWriter([num2str(i+numV1-1),'.avi'],'Grayscale AVI');
   viw.FrameRate = 15;
   open(viw);
   for j = 1:1000
      if hasFrame(vid2)
        writeVideo(viw, readFrame(vid2)); 
      else
          break;
      end
   end
   close(viw);
   delete(viw);
    
    
end