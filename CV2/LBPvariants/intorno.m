%This function returns a neghbors*2 matrix with the coordinates of
%neighbors points of the selected curve

function result=intorno(luogo,neighbors,p1,p2)

result=zeros(neighbors,2);

switch luogo
    case 'par'  %create points of a parabola,using p1
        for i = 1:(neighbors/2)
            step=p1/(neighbors/2);
            result(i,2) = i*step;
            result(i,1) = (p1)*result(i,2)^2; 
            result(neighbors+1-i,2) = -i*step;
            result(neighbors+1-i,1) = (p1)*result(neighbors+1-i,2)^2;
        end
        
        maxy=max(result(:,1));
        
        for i=1:(neighbors/2)
            result(i,1)=result(i,1)*p1/maxy;
            result(neighbors+1-i,1)=result(neighbors+1-i,1)*p1/maxy;
        end
        
        
    case 'ip'   %create points of a hyperbole,using p1 and p2
        p1=p1/2;
        step=p1/(((neighbors-2)/2)/2);
        result(neighbors/2,2) = p1;
        result((neighbors/2)+1,2) = -p1;
        result(neighbors/2,1) = 0;
        result(neighbors/2+1,1) = 0;
        for i = 1:(neighbors-2)/4
            result(i,2) = p1+i*step;
            result(i+(neighbors-2)/4,2) = p1+i*step;
            result(neighbors+1-i,2) = -(p1+i*step);
            result(neighbors+1-i-(neighbors-2)/4,2) = -(p1+i*step);
            result(i,1) = +sqrt(result(i,2)^2-p1^2);
            result(i+(neighbors-2)/4,1) = -sqrt(result(i,2)^2-p1^2);
            result(neighbors+1-i,1) = +sqrt(result(neighbors+1-i,2)^2-p1^2);
            result(neighbors+1-i-(neighbors-2)/4,1) = -sqrt(result(neighbors+1-i,2)^2-p1^2);
        end
        
    case 'sp' %create points of a Archimedean spiral,using p1 and p2
          
        for i=1:neighbors
            result(i,1) = p1*p1*(i-1)*sin((i-1));
            result(i,2) = p1*p1*(i-1)*cos((i-1));
        end
        
        maxx=max(result(:,2));
        maxy=max(result(:,1));
        minx=min(result(:,2));
        miny=min(result(:,1));
        for i=1:neighbors
            if ( result(i,1)>=0 )
                result(i,1)=result(i,1)*p1/maxy;
                result(i,2)=result(i,2)*p1/maxx;
            else
                result(i,1)=result(i,1)*p1/-miny;
                result(i,2)=result(i,2)*p1/-minx;
            end
        end
        
    case 'el' %create points of an ellipse using p1 and p2
        % Angle step.
        a = 2*pi/neighbors;    
        
        radiusA=p1;
        radiusB=p2;
        for i = 1:neighbors
            theta=(i-1)*a;
            DEN=radiusA^2*(1/2 - 1/2*cos(2*theta))+radiusB^2*(1/2 + 1/2*cos(2*theta));
            radius=((radiusA^2*radiusB^2)/DEN)^0.5;
            %N.B.
            %sin^2(x) =  1/2 - 1/2*cos(2*theta)
            %cos^2(x) = 1/2 + 1/2 cos(2x)
            result(i,1) = -radius*sin((i-1)*a);
            result(i,2) = radius*cos((i-1)*a);
        end

    otherwise %create points of a circle of radius p1
        a=2*pi/neighbors;
        for i = 1:neighbors
            result(i,1) = -p1*sin((i-1)*a);
            result(i,2) = p1*cos((i-1)*a);
        end
end 

end
        
        