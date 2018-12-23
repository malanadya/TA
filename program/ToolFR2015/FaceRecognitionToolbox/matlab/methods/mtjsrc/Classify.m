% function [predClass, drop, a_total] = ClassifyNoKernel(Y, X, group_index, weight, W, opt)
% 
% K = size(Y,1);
% 
% a_total = [];
% uids = unique(group_index{1});
% for blarg = 1:length(uids)
% 	i = uids(blarg);
% 
%     c = [];
%     d = [];
% 	s = 0;
%     for (k=1:K)
%         cur_idx = find(group_index{k}'==i);
%         W_temp = W{k}(cur_idx);
% 		s = s + weight{k}*norm(Y{k} - X{k}(:,cur_idx)*W_temp).^2;
%     end    
%     a_total = [a_total,s];
% end
% 
% [drop, predClass] = min(a_total);
% predClass = uids(predClass);





function    [predClass, drop, a_total] = Classify(Y, X, group_index, weight, W, opt)

% K = size(Y,1);
K = length(Y);
a_total = [];
uniqGroup = unique(group_index{1});

for (i=1:length(uniqGroup))

    c = [];
    d = [];
    for (k=1:K)
        cur_idx = find(group_index{k}'==uniqGroup(i));
        W_temp = W{k}(cur_idx);
        if opt.kernel_view == 1
            c = [c; weight{k}*(-2*(Y{k}(cur_idx))'*W_temp+W_temp'*X{k}(cur_idx,cur_idx)*W_temp)];
        else
            c = [c; weight{k} * norm(Y{k} - X{k}(:,cur_idx) * W{k}(cur_idx))^2];
        end
        d = [d; weight{k}*sum(W_temp)];
    end    
    a = -sum(c);
    a_total = [a_total,a];
end

[drop, predClass] = max(a_total);
% [drop, predClass] = min(a_total);
predClass = uniqGroup(predClass);