function mag=soft_assign(ori,grad,nbOri,signed)
mag=zeros(size(grad,1),size(grad,2),nbOri);
if signed==0 %unsigned
    step_ori=pi/nbOri;
else
    step_ori=2*pi/nbOri;
end

    for x=1:size(ori,1)        
        for y=1:size(ori,2)
            one_grad=0;
            for i=1:nbOri
                if abs(ori(x,y)-(i-1/2)*step_ori)<0.05
                    mag(x,y,i)=grad(x,y);
                    one_grad=1;
                    break;
                end
            end
            
            if one_grad==0
                if ori(x,y)<step_ori/2
                    w1=0.5+ori(x,y)/step_ori;
                    mag(x,y,1)=grad(x,y)*w1;
                    mag(x,y,nbOri)=grad(x,y)*(1-w1);
                end
                
                for i=1:nbOri-1
                    if ori(x,y)>(i-1/2)*step_ori & ori(x,y) < (i+1/2)*step_ori
                        w1=i+0.5-ori(x,y)/step_ori;
                                                        'case 3';
                        mag(x,y,i)=grad(x,y)*w1;
                        mag(x,y,i+1)=grad(x,y)*(1-w1);
                        break;
                    end
                end
                
                if ori(x,y)>pi-step_ori/2
                    w1=0.5-(pi-ori(x,y))/step_ori;
                    mag(x,y,1)=grad(x,y)*w1;
                    mag(x,y,nbOri)=grad(x,y)*(1-w1);
                                                'case 4';
                end
            
            end

        end
    end
