function [perform,perform_shifted] = OnevOneDecoder(X,Y,kfold,cvspace,model,eval_metric)
        
        
        [trainingsets, valisets] = CVPartition_Spacing(Y, cvspace, kfold);
        perform = [];
        perform_shifted = [];
        for k = 1:kfold
            training_idx = trainingsets{k};
            Y_temp_training = Y(training_idx);
            X_train = X(training_idx,:);
            switch model
                case 'lda'
                    Mdl = fitcdiscr(X_train,Y_temp_training);
                case 'svm'
                    Mdl = fitcsvm(X_train, Y_temp_training);
                case 'logistic'
                    Mdl = fitclinear(X_train, Y_temp_training,'Learner','logistic','Solver','sparsa');    
            end
            % test
            val_idx = valisets{k};
            Y_temp_val = Y(val_idx);
            X_val = X(val_idx,:);
            Y_pred = predict(Mdl, X_val);
            order_ = sort(unique(Y));
            [accuracys,precisions,recalls,F1_scores] = EvalPrediction(Y_temp_val, Y_pred, order_);
            switch eval_metric
                case 'accuracy'
                    perform = [perform; accuracys];
                case 'precision'
                    perform = [perform; precisions];
                case 'recall'
                    perform = [perform; recalls];
                case 'F1'
                    perform = [perform; F1_scores];
            end

            for cs = 1:10
                X_train_shifted = X_train(randperm(size(X_train,1)),:);
                switch model
                    case 'lda'
                        Mdl_shifted = fitcdiscr(X_train_shifted,Y_temp_training);
                    case 'svm'
                        Mdl_shifted = fitcsvm(X_train_shifted, Y_temp_training);
                    case 'logistic'
                        Mdl_shifted = fitclinear(X_train_shifted, Y_temp_training,'Learner','logistic','Solver','sparsa');
                end
                % evaluate performance
                Y_pred_s = predict(Mdl_shifted, X_val);
                [accuracys_s,precisions_s,recalls_s,F1_scores_s] = EvalPrediction(Y_temp_val, Y_pred_s, order_);
                switch eval_metric
                    case 'accuracy'
                        perform_shifted = [perform_shifted; accuracys_s];
                    case 'precision'
                        perform_shifted = [perform_shifted; precisions_s];
                    case 'recall'
                        perform_shifted = [perform_shifted; recalls_s];
                    case 'F1'
                        perform_shifted = [perform_shifted; F1_scores_s];
                end
            end
        end
end