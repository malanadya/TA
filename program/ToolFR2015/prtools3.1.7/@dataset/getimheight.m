%getimheight Retrieve image height
%
%	s = getimheight(a)
%
% Retrieves the image height of the dataset A. Note that if s < 0 the
% images with vertical image size abs(s) are stored as features. If s > 0,
% the images with vertical image size s are stored as objects.
%
% See also dataset

function s = getimheight(a)
s = a.c;
