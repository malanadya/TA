function Data_norm = Normalisation(Data)
% L2 normalisation
% Data: X = (x_1, x_2, ..., x_N)'
[N, d] = size(Data);
Norm = zeros(N, 1);
for i = 1: N
    Norm(i) = sqrt(Data(i, :)*Data(i, :)');
end

Data_norm = Data./repmat(Norm, 1, d);