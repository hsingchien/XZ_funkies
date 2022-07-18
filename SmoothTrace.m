function bTrace = SmoothTrace(logi,window,step,method)
   bTrace = [];
   for i = 1:step:length(logi)
       bTrace = [bTrace; sum(logi(i:min(i+window-1,length(logi))))/(min(i+window-1,length(logi))-i+1)];
    
   end
end