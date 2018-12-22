%% load sample sequence
load sequence.mat seq;
%% feature extraction
MFS=[MagTmpl3D(seq),BinTmpl3D(seq)];