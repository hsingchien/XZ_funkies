function [accuracys,precisions,recalls,F1_scores] = EvalPrediction(Ytruth, Ypredict)
% evalutate binary prediction 0,1
accuracys = [];
precisions = [];
recalls = [];
F1_scores = [];
for i = 1:size(Ypredict,2)
    cmat = confusionmat(Ytruth, Ypredict(:,i));
    tp = cmat(2,2); tn = cmat(1,1); fp=cmat(1,2); fn = cmat(2,1);
    accuracy = (tp+tn)/(tp+tn+fp+fn);
    precision = tp/(tp+fp);
    recall = tp/(tp+fn);
    F1_score = 2*(recall*precision)/(recall+precision);
    accuracys = [accuracys, accuracy];
    precisions = [precisions, precision];
    recalls = [recalls, recall];
    F1_scores = [F1_scores, F1_score];
end


end