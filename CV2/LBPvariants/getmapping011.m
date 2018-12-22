%GETMAPPING returns a structure containing a mapping table for LBP codes.
%  MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE) returns a 
%  structure containing a mapping table for
%  LBP codes in a neighbourhood of SAMPLES sampling
%  points. Possible values for MAPPINGTYPE are
%       'u2'   for uniform LBP
%       'ri'   for rotation-invariant LBP
%       'riu2' for uniform rotation-invariant LBP.
%
%  Example:
%       I=imread('rice.tif');
%       MAPPING=getmapping(16,'riu2');
%       LBPHIST=lbp(I,2,16,MAPPING,'hist');
%  Now LBPHIST contains a rotation-invariant uniform LBP
%  histogram in a (16,2) neighbourhood.
%

function mapping = getmapping(samples,mappingtype)
% Version 0.1.1
% Authors: Marko Heikkilä and Timo Ahonen

% Changelog
% 0.1.1 Changed output to be a structure
% Fixed a bug causing out of memory errors when generating rotation 
% invariant mappings with high number of sampling points.
% Lauge Sorensen is acknowledged for spotting this problem.



table = 0:2^samples-1;
newMax  = 0; %number of patterns in the resulting LBP code
index   = 0;

if strcmp(mappingtype,'u2') %Uniform 2
  newMax = samples*(samples-1) + 3; 
  for i = 0:2^samples-1
    j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); %rotate left
    numt = sum(bitget(bitxor(i,j),1:samples)); %number of 1->0 and
                                               %0->1 transitions
                                               %in binary string 
                                               %x is equal to the
                                               %number of 1-bits in
                                               %XOR(x,Rotate left(x)) 
    if numt <= 2
      table(i+1) = index;
      index = index + 1;
    else
      table(i+1) = newMax - 1;
    end
  end
end

if strcmp(mappingtype,'ri') %Rotation invariant
  tmpMap = zeros(2^samples,1) - 1;
  for i = 0:2^samples-1
    rm = i;
    r  = i;
    for j = 1:samples-1
      r = bitset(bitshift(r,1,samples),1,bitget(r,samples)); %rotate
                                                             %left
      if r < rm
        rm = r;
      end
    end
    if tmpMap(rm+1) < 0
      tmpMap(rm+1) = newMax;
      newMax = newMax + 1;
    end
    table(i+1) = tmpMap(rm+1);
  end
end

if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
  newMax = samples + 2;
  for i = 0:2^samples - 1
    j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); %rotate left
    numt = sum(bitget(bitxor(i,j),1:samples));
    if numt <= 2
      table(i+1) = sum(bitget(i,1:samples));
    else
      table(i+1) = samples+1;
    end
  end
end

% C = BITSET(A,BIT) sets bit position BIT in A to 1 (on). BIT must be a 
%     number between 1 and the length in bits of the unsigned integer class 
%     of A, C = BITSET(A,BIT,V) sets the bit at position BIT to the value V.
%     V must be either 0 or 1.

%   C = BITGET(A,BIT) returns the value of the bit at position BIT in A..

%   C = BITXOR(A,B) returns the bitwise XOR of arguments A and B,

%   C = BITSHIFT(A,K) returns the value of A shifted by K bits. A must be 
%   an unsigned integer or an array of unsigned integers. Shifting by K 
%   is the same as multiplication by 2^K. Negative values of K are allowed 
%   and this corresponds to shifting to the right, or dividing by 2^ABS(K) 
%   and truncating to an integer. 
%   C = BITSHIFT(A,K,N) will cause bits overflowing N bits to be dropped. 
%   N must be less than or equal to the length in 
%   bits of the unsigned integer class of A, e.g., N<=32 for UINT32.

mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;
