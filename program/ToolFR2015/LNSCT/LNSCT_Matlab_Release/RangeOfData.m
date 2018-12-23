function RangeOfData
figure;
for person=1:38
    if person<10
        PersonString=sprintf('0%d',person);
    else
        PersonString=sprintf('%d',person);
    end
        DataPath=strcat('E:\database\YaleB100¡Á100_LNSCT\Direction[3 4 4]_lamda_0.01\VMatrix_',PersonString);
        load(DataPath);
        
    for ithImage=1:65
        
        temp=VMatrix(:,ithImage);
        plot(1:10000,temp,'.r');
        hold on;
        
    end
end