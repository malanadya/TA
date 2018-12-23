the different folders contains the functions used in the paper

MainFR2015.m shows how to:
a) pre-processing a given image
b) extract the features for describing the image
c) to project onto the PCA subspace

Notice that in LFW we have used also SVM (see \source) as classifier, 
for the parameters of standard kernel see https://www.csie.ntu.edu.tw/~cjlin/libsvm/
for details of input and output see standard LibSVM  https://www.csie.ntu.edu.tw/~cjlin/libsvm/

for comparing two images in the FERET we have used the angle distance, 
It is implemented in the \Sltoolbox, for comparing two images described by the feature vectors feat1 and feat2:
single(slmetric_pw(feat1,feat2,'angle'));


The Code for SML (Cao, Qiong, Yiming Ying, and Peng Li. 2013. “Similarity Metric Learning for Face Recognition.” Computer Vision (ICCV), 2013 IEEE International Conference on 2408–15)
is available at \sub-sml_iccv  or  http://empslocal.ex.ac.uk/people/staff/yy267/software.html

The toolbox used for deep features is available here http://www.vlfeat.org/matconvnet/
For extracting the deep features you should download VGG-Face from http://www.vlfeat.org/matconvnet/models/vgg-face.mat