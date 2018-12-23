Verification in restricted setting on LFW dataset using Sub-SML:

The main code is LearnSubSML_restricted_lfw.m

Before running the main code, generate the data into 10 folds with each fold including Data, SS, DD, DataTT1 and DataTT2.

Data (10800xdim): nine of the ten subsets. The first and the third 2700 rows are similar samples, while the second and the forth 2700 rows are dissimilar samples 
2700 perchè non hanno seguito il protocollo!!!! dovrebbe essere il training set
sono 10800 perchè usano i 9 fold, dunque 600 coppie di immagini per 9 fold= 600*2*9 immagini

DataTT1 and DataTT2: the tenth subset for testing; the first 300 samples in DataTT1 and DataTT2 are similar pairs and the last 300 samples in DataTT1 and DataTT2 
consist of dissimilar pairs     
Entrambi sono 300 features per 600 patterns, sono due perchè ognuno salva le features di una delle due immagini da matchare

SS and DD (2700x2): the index of the similar/dissimilar pairs. 
SS = [1:2700;2700*2+1: 8100]'; DD = [2701: 2700*2;2700*3+1: 2700*4]'

The origial SIFT feature is downloaded from https://lear.inrialpes.fr/people/guillaumin/data.php

27/11/2013

