% Local binary patterns 
function out=lbp_image(in,type)

   [rows,cols]=size(in);

   % case 'P8R2' % 8 pixels in a circle of radius 2

   % embed input matrix in a larger one, extending with zeros (trim a
   % 2 pixel border off of the output matrices if you don't like this)
   r=rows+4; 
   c=cols+4;
   A = zeros(r,c);
   r0=3:r-2;
   c0=3:c-2;
   A(r0,c0) = in;

   % radius 2 interpolation coefficients for +-45 degree lines
   alpha = 2-sqrt(2);
   alpha = 0.5;
   beta = 1-alpha;

   % 8 directional derivative images
   d0 = A(r0,c0-2) - in;
   d2 = A(r0+2,c0) - in;
   d4 = A(r0,c0+2) - in;
   d6 = A(r0-2,c0) - in;
   d1 = alpha*A(r0+1,c0-1) + beta*A(r0+2,c0-2) - in;
   d3 = alpha*A(r0+1,c0+1) + beta*A(r0+2,c0+2) - in;
   d5 = alpha*A(r0-1,c0+1) + beta*A(r0-2,c0+2) - in;
   d7 = alpha*A(r0-1,c0-1) + beta*A(r0-2,c0-2) - in;

   % pack derivative images into a single matrix, one per column,
   % threshold and code to get output matrix
   d = [d0(:),d1(:),d2(:),d3(:),d4(:),d5(:),d6(:),d7(:)];
   code = 2.^(7:-1:0)';
   out = reshape((d>=0)*code,rows,cols);

%end;
