
gabor = feat;
assert(length(gabor.theta) == length(gabor.scale));
gaborFilterBank = cell(length(gabor.theta),2);
for gi = 1:length(feat.theta)
    gaborFilterBank{gi,1} = createGaborFilter(gabor.theta(gi), 1, gabor.scale(gi));
    gaborFilterBank{gi,2} = createGaborFilter(gabor.theta(gi), 0, gabor.scale(gi));
end