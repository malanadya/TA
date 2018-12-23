function gaborFilter = createGaborFilter(theta, isEven, lambda)
%
%  createGaborFilter(theta, psi)    Create a Gabor filter with the 
%                                   specified parameters
%
%  Arguments:
%     theta = The orientataion of the Gabor filter's cosine
%             function (specified in radians)
%     even  = Even or odd Gabor filter? (1=even, 0=odd)
%
gamma = 1;
%lambda = 8;  
sigma = .5622*lambda;  extent = fix(3*sigma);
psi = (isEven-1)*pi/2;
[x,y] = meshgrid(-extent:extent, -extent:extent);
thetaX = x*cos(theta) + y*sin(theta);
thetaY = -x*sin(theta) + y*cos(theta);
gaborFilter = exp(-.5*(thetaX.^2/sigma^2+gamma^2*thetaY.^2/sigma^2))...
                  .*cos(2*pi/lambda*thetaX+psi);
end
