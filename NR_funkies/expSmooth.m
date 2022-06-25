function [trace_smooth] = expSmooth(trace_df,fps,T)
%expSmooth This function applies a exponential smoothing filter to trace
% trace : frames x cells input
% deltaT: sampling rate
% T     : time constant
trace_smooth=[];
deltaT = 1/fps;
a=1-exp(-deltaT/T);

for i=1:size(trace_df,2) % loop through cells
    trace_smooth(1,i)=trace_df(1,i);
    for t=2:size(trace_df,1) % loop through time
        trace_smooth(t,i)=a*trace_df(t,i)+(1-a)*trace_smooth(t-1,i);
    end 
end

