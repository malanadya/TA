function output = is_uniform_pattern(pattern)
%
count = 0;
num = size(pattern,2);
for i=1:num-1
    if pattern(i) ~= pattern(i+1)
        count = count + 1;
    end
end
if count <= 2
    output = 1;
else
    output = 0;
end