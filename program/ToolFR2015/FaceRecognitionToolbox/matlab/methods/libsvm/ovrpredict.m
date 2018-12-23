function [pred, ac, decv] = ovrpredict(y, x, model, cmd)

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);

if ~exist('cmd', 'var')
    cmd = '';
end

for i=1:labelSetSize
  tstids = double(y == labelSet(i));
  %[l,a,d] = svmpredict(double(y == labelSet(i)), x, models{i});
  try
      [l, a, d] = svmpredict31_noprint(tstids, x, models{i}, cmd);
  catch
      [l, a, d] = svmpredict(tstids, x, models{i}, cmd);
  end
  if strcmp(cmd, '-b 1')
      decv(:, i) = d(find(models{i}.Label == 1));
  else
    decv(:, i) = d * (2 * models{i}.Label(1) - 1);
  end
end
[tmp,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / size(x, 1);
