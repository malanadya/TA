% function:  hist_intersection(a,b), a is test,b is train
%  ** Output Similarity [s11 s12 ...
%                        s21 s22 ...
% 					   .  .  .  . .
% 					   .  .  .  . .]
% 					   sxy means the similarity between test x and train y
function [fisher_d]=LearnFLD_NEW(Eigen_NUM,Axes_NUM,Num_block,trainlabels,folder_tr)

for im = 1:Num_block
    filename=[folder_tr '\D_FERET_Training_' num2str(im)];
    load(filename);
    
    fprintf(['im--' num2str(im) '\n']);
    [disc_set,disc_value,train_mean]=Fisherface_f_M_NEW(Train_theta, Eigen_NUM, Axes_NUM,trainlabels);
    filename=[folder_tr '\FERET_LearnBFLD' num2str(im)];save(filename,'disc_set','train_mean');
    fisher_d = size(disc_set,2);
end