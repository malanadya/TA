function [model] = ovrtrain(y, x, cmd)

labelSet = unique(y);
labelSetSize = length(labelSet);
models = cell(labelSetSize,1);

for i=1:labelSetSize
    trnids = double(y == labelSet(i));
    try,
        models{i} = svmtrain31(trnids, x, cmd);
    catch
        models{i} = svmtrain(trnids, x, cmd);
    end
    %models{i} = svmtrain(, x, cmd);
end

model = struct('models', {models}, 'labelSet', labelSet);