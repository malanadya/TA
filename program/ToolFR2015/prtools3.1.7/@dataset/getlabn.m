%GETLABN Get numeric labels of dataset
%
%	[NLAB,LABLIST] = GETLABN(A)
%
% Returns the numeric labels NLAB of all objects in the dataset A.
% Numbers are assigned in alphabetical order.
% LABLIST is the corresponding label list, such that the original
% labels can be retrieved as LAB = LABLIST(NLAB,:);

function [nlab,lablist] = getlabn(a)
	
nlab = a.l;
lablist = a.ll{1};
return
