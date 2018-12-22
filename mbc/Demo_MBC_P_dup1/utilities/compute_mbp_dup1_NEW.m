% function:  hist_intersection(a,b), a is test,b is train
%  ** Output Similarity [s11 s12 ...
%                        s21 s22 ...
% 					   .  .  .  . .
% 					   .  .  .  . .]
% 					   sxy means the similarity between test x and train y
function [output,reco_ratio_O] = compute_mbp_dup1_NEW(numQ,numT,Num_block,method,folder_tr,...
    folder_ta,folder_qu,target_label,query_label,nameDatabase)
Similarity=zeros(numQ,numT);
Similarity_O=zeros(numQ,numT);

for im = 1:Num_block
    fprintf(['im--' num2str(im) '\n']);
    
    filename=[folder_ta '\D_FERET_Target_' num2str(im)];
    load(filename);
    filename=[folder_qu '\D_FERET_Query_' num2str(im)];
    load(filename);
    
    filename=[folder_tr '\FERET_LearnBFLD' num2str(im)]; load(filename);
    
    [Sim] = compute_similarity (disc_set'*(single(Query_theta)-repmat(train_mean,[1 size(Query_theta,2)])),...
        disc_set'*(single(Target_theta)- repmat(train_mean,[1 size(Target_theta,2)])),method);
    Similarity=Similarity+Sim;
    [Sim] = compute_similarity ((Query_theta),(Target_theta),'hist_intersection');
    Similarity_O =  Similarity_O+Sim;
end
filename=['dup1_Similarity\' nameDatabase '_similarity'];
save(filename,'Similarity');

ID=[]; ID_O =[];
for i=1:size(Similarity,1)
    sim=Similarity(i,:);
    index=find(sim==max(sim));
    ID=[ID target_label(index(1))];
    
    sim=Similarity_O(i,:);
    index=find(sim==max(sim));
    ID_O=[ID_O target_label(index(1))];
end
reco_ratio=(sum(ID==query_label)/length(query_label));
reco_ratio_O=(sum(ID_O==query_label)/length(query_label));
output = reco_ratio;