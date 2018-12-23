%DATAIMHEIGHT Compute vertical image size for images stored as objects

function imheight = dataimheight(a);
if isa(a,'dataset') & isobjim(a)
	imheight = dataimsize(a,1);
else
	imheight = 0;
end

