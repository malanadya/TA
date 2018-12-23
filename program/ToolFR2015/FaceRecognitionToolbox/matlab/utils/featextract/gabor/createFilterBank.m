function [filterBank] = createFilterBank

scale = 1;

filterBank = {};

theta = ([0,45,90,135] + 45/2)*pi/180;
len = size(filterBank,1)+1;
for i=len:1:len+4-1
    filterBank{i,1} = createGaborFilter(theta(i-len+1), 1, 16/2*scale);
    filterBank{i,2} = createGaborFilter(theta(i-len+1), 0, 16/2*scale);
end

theta = [0,45,90,135]*pi/180;
%theta = [[0,45,90,135]*pi/180 ([0,45,90,135] + 45/2)*pi/180];
len = size(filterBank,1)+1;
for i=len:1:len+4-1
    filterBank{i,1} = createGaborFilter(theta(i-len+1), 1, 8/2*scale);
    filterBank{i,2} = createGaborFilter(theta(i-len+1), 0, 8/2*scale);
end

% theta = ([0,45,90,135] + 45/2)*pi/180;
% len = size(filterBank,1)+1;
% for i=len:1:len+4-1
%     filterBank{i,1} = createGaborFilter(theta(i-len+1), 1, 4/2);
%     filterBank{i,2} = createGaborFilter(theta(i-len+1), 0, 4/2);
% end


% theta = [0,45,90,135]*pi/180;
% for i=1:1:4,
%     filterBank{i+8,1} = createGaborFilter(theta(i), 1, 16/2);
%     filterBank{i+8,2} = createGaborFilter(theta(i), 0, 16/2);
% end

% theta = ([0,45,90,135] + 45/2)*pi/180;
% for i=1:1:4
%     filterBank{i+8,1} = createGaborFilter(theta(i), 1, 2);
%     filterBank{i+8,2} = createGaborFilter(theta(i), 0, 2);
% end

end