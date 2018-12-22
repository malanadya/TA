function Feat=EstraiWAVE(image);

%FEAT=ML_WAVEFEATURES(IMAGE); constructs a matrix composed of the
%wavelet features for the given image based on detail coefficients from
% 'db4' decomposed 10 levels deep.
%
%It's input is a normalized image

Feat=zeros(0,1);

NomeWave='db4';


[C,S] = wavedec2(image,10,NomeWave);
for i = 0 : 9
    chd = detcoef2('h',C,S,(10-i));
    cvd = detcoef2('v',C,S,(10-i));
    cdd = detcoef2('d',C,S,(10-i));

    hfeat = sqrt(sum(sum(chd.^2)));
    vfeat = sqrt(sum(sum(cvd.^2)));
    dfeat = sqrt(sum(sum(cdd.^2)));

    Feat = [Feat hfeat vfeat dfeat];
end;
