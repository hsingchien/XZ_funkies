function [f,pad] = drawCellROI(SFPs)
%drawCellROI This function produces figure of cells ROI from their spatial
%foot print (retrieved from Fstruct)
%Input:
% SFPs : width x height x num of cells SPF from Fstruct
%Output:
% f: cellROIs
% pad: padded frame with all cell ROIs added.

% create padded background (black)
pad=zeros(size(SFPs,1),size(SFPs,2),3);
colSet = [ [1 0.6 0.6];
          [1 0.8 0.8];
          [1 0.5 1];
          [1 0.7 1]; 
          [1 0.8 1]; 
          [1 0.6 0.6]; 
          [1 0.8 0.8]; 
          [0.3 0.8 0.3];  
          [0.5 0.8 0.5];  
          [0.7 0.8 0.7];  
          [1 0.8 0.4]; 
          [1 0.8 0.4]; 
          [0.8 0.6 0.3];  
          [0 0.8 0]; 
          [0.3 0.8 0.3]; 
          [0 1 1]; 
          [0.6 0.6 1]; 
          [0.6875 0.7656 0.8672]; 
          [0.75 0.75 1];  
          [0.75 0.75 1]; 
          [0.7875 0.8656 0.9672]; 
          [0.6 0.6 0.6]];  
% Set thr to limit cell sizes on figure
cellThr = 1;
% fill in cell ROIs with random colors from set
for cell=1:size(SFPs,3)
    n=randperm(22,1);
    img = SFPs(:,:,cell);
%     img = img>cellThr;
% scale to 0-1
    img = img./range(img(:));
    img = img.^4;
    centroid_img = [find(max(img,[],1)==max(img(:)),1),find(max(img,[],2)==max(img(:)),1)];
    
    colImg(:,:,1)= img.*colSet(n,1);
    colImg(:,:,2)= img.*colSet(n,2);
    colImg(:,:,3)= img.*colSet(n,3);
%     f = figure('Visible','off','Position',[10,10,800,800]);
%     a = axes(f);
%     contour(a,img,'black');
%     set(a, 'Units','pixels','Position',[10,10,size(img,2),size(img,1)]);
%     fr = getframe(a);
%     cmask = (fr.cdata == 0);
%     colImg = colImg.*cmask;

    colImg = insertText(colImg, centroid_img, num2str(cell),'TextColor','yellow','FontSize',8,'BoxOpacity',0);
    pad = pad + colImg;
    


end
f=figure;
imshow(pad)
end

