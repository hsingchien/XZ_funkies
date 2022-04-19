function [perform,perform_shifted] = OnevOneDecoder(X,Y,kfold,cvspace,model)
        
        
        [trainingsets, valisets] = cvpartition_spacing(Y, cvspace, kfold);
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
            end
            % test
            val_idx = valisets{k};
            Y_temp_val = Y(val_idx);
            X_val = X(val_idx,:);
            Y_pred = predict(Mdl, X_val);
            order_ = sort(unique(Y));
            ac = EvalPrediction(Y_temp_val, Y_pred, order_);
            perform = [perform; ac];
            for cs = 1:10
                X_train_shifted = X_train(randperm(size(X_train,1)),:);
                switch model
                    case 'lda'
                        Mdl_shifted = fitcdiscr(X_train_shifted,Y_temp_training);
                    case 'svm'
                        Mdl_shifted = fitcsvm(X_train_shifted, Y_temp_training);
                end
                % evaluate performance
                Y_pred_s = predict(Mdl_shifted, X_val);
                ac_shifted = EvalPrediction(Y_temp_val, Y_pred_s, order_);
                perform_shifted = [perform_shifted; ac_shifted];
            end
        end
end