function output = uniform_pattern(pNum)
% set up indicator table of all uniform patterns of size pnum bits
output=[];
for i=0:2^pNum-1
   BinP=zeros(1,pNum);
   temp = i;
   for j=1:pNum
        if(floor(temp/(2^(pNum-j))) > 0)
            BinP(1,j) = 1;
        end
        temp =   mod(temp,2^(pNum-j));
    end
    if is_uniform_pattern(BinP) == 1
        output = [output,i];
    end
end