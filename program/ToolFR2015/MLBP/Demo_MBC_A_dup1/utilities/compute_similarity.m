function [Sim] = compute_similarity (test,train,method)
Test_Num  = size(test,2);
Train_Num = size(train,2);

switch lower(method)
          case {'hist_intersection'}
            disp('Method is hist_intersection');
%             [Sim]=hist_intersection(test,train);
            [Sim] = slmetric_pw(single(test),single(train),'intersect');
          case 'l2'
            disp('Method is l2');
            for i = 1:Test_Num
                for j=1:Train_Num
                   Sim(i,j) = single(0- norm(test(:,i)-train(:,j),2)^2);
                end
            end
          case 'cos'
            disp('Method is cos');
            for i = 1:Test_Num
                for j=1:Train_Num
                   Sim(i,j) = single(test(:,i)'*train(:,j)/(norm(test(:,i),2)*norm(train(:,j),2)));
                end
          end
          otherwise
            disp('Unknown method.')
end