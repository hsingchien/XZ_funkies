function E_stru = TAlignStru2(E_stru, t1, t2, tBehav)
% Input a constructed struct of 2-animal experiment, timestamps
% output a time aligned struct

t1 = csvread(t1, 1);
t2 = csvread(t2, 1);
tBehav = csvread(tBehav, 1);
% use behavior tstamp as reference
[idxBehav, idxA1, tdiff1] = TStampAlign(tBehav(:,2), t1(:,2));
[idxBehav, idxA2, tdiff2] = TStampAlign(tBehav(:,2), t2(:,2));
figure, subplot(2,1,1), plot(tdiff1); title('time diff bewteen behavior and A1 after align'); ylabel('ms');
subplot(2,1,2), plot(tdiff2), title('time diff between behavior and A2 after align'); ylabel('ms');
E_stru{1}.RawTraces = E_stru{1}.RawTraces(idxA1,:);
E_stru{1}.FiltTraces = E_stru{1}.FiltTraces(idxA1,:);
E_stru{2}.RawTraces = E_stru{2}.RawTraces(idxA2,:);
E_stru{2}.FiltTraces = E_stru{2}.FiltTraces(idxA2,:);


end

