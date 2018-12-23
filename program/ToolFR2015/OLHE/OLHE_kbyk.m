% Illumination Compensation Using Oriented
% > Local Histogram Equalization and
% > Its Application to Face Recognition
% 
% USAGE:
% 
% imageOut = OLHE_kbyk(uint8(imageOut),3);
% 
% note that the parameter '3' means the 3-by-3 local window is applied.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imageOutFinal = OLHE_kbyk( imageIn , maskBandW )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%maskBandW = 3;



imrange = 256;
imrangeMinusOne = 255;
imrangeNew = 255;
nPosi = maskBandW^2;
halfBW = (maskBandW-1)/2;

thre_maxIntensityBinCount = round(nPosi * 1.0);



dim1 = size(imageIn,1);
dim2 = size(imageIn,2);

%imageIn = gray2ind(imageIn, 32);

%imageOutFinal = zeros(dim1,dim2);

imgOut = cell(nPosi,1);
for i=1:nPosi
    imageOut{i} = zeros(dim1,dim2);
end








anchorArrayDim2 = maskBandW*maskBandW;
anchorOnPatchX_ary = zeros(1,anchorArrayDim2);
anchorOnPatchY_ary = zeros(1,anchorArrayDim2);
anchor_x_shift_ary = zeros(1,anchorArrayDim2);
anchor_y_shift_ary = zeros(1,anchorArrayDim2);

anchorArrayIdx = 1;
for thedim1=1:maskBandW
    for thedim2=1:maskBandW
        anchorOnPatchX_ary(1,anchorArrayIdx) = thedim1;
        anchorOnPatchY_ary(1,anchorArrayIdx) = thedim2;
        
        anchor_x_shift_ary(1,anchorArrayIdx) = (thedim1-1) - halfBW;
        anchor_y_shift_ary(1,anchorArrayIdx) = (thedim2-1) - halfBW;
                
        anchorArrayIdx = anchorArrayIdx + 1;
    end
end






% switch maskBandW
%     case 3
%         anchorOnPatchX_ary = [1 1 1 2 2 2 3 3 3];
%         anchorOnPatchY_ary = [1 2 3 1 2 3  1 2 3  ];
% 
%         anchor_x_shift_ary = [ -1 -1 -1 0 0 0  1 1 1];
%         anchor_y_shift_ary = [-1 0 1  -1 0 1  -1 0 1 ];
% 
%     case 5
% 
%         anchorOnPatchX_ary = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
%         anchorOnPatchY_ary = [1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 ];
% 
%         anchor_x_shift_ary = [-2 -2 -2 -2 -2 -1 -1 -1 -1 -1 0 0 0 0 0 1 1 1 1 1 2 2 2 2 2];
%         anchor_y_shift_ary = [-2 -1 0 1 2 -2 -1 0 1 2 -2 -1 0 1 2 -2 -1 0 1 2 -2 -1 0 1 2];
% 
%     case 7
% 
%         anchorOnPatchX_ary = [1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 6 6 6 6 6 6 6 7 7 7 7 7 7 7];
%         anchorOnPatchY_ary = [1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7];
% 
%         anchor_x_shift_ary = [-3 -3 -3 -3 -3 -3 -3 -2 -2 -2 -2 -2 -2 -2 -1 -1 -1 -1 -1 -1 -1 0 0 0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 3];
%         anchor_y_shift_ary = [-3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 -3 -2 -1 0 1 2 3 ];
% 
% 
%     case 9
%         anchorOnPatchX_ary = [1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 7  7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 8 9 9 9 9 9 9 9 9 9];
%         anchorOnPatchY_ary = [1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 ];
% 
%         anchor_x_shift_ary = [-4 -4 -4 -4 -4 -4 -4 -4 -4 -3 -3 -3 -3 -3 -3 -3 -3 -3 -2 -2 -2 -2 -2 -2 -2 -2 -2 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 2 2 2  2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 ];
%         anchor_y_shift_ary = [-4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 -4 -3 -2 -1 0 1 2 3 4 ];
% 
%     otherwise, error('not supportted\n')
% end
% 


% (anchorOnPatchX_ary)
% (anchorOnPatchY_ary)
% (anchor_x_shift_ary)
% (anchor_y_shift_ary)
% 
% length(anchorOnPatchX_ary)
% length(anchorOnPatchY_ary)
% length(anchor_x_shift_ary)
% length(anchor_y_shift_ary)

% size(anchorOnPatchX_ary)
% size(anchorOnPatchY_ary)
% size(anchor_x_shift_ary)
% size(anchor_y_shift_ary)
% 
% class(anchorOnPatchX_ary)
% class(anchorOnPatchY_ary)
% class(anchor_x_shift_ary)
% class(anchor_y_shift_ary)
% 
% 

workingHist = zeros(imrange,1);
workingCDF  = zeros(imrange,1);

%imageOutFinal = zeros(dim1,dim2);

patchTmpEQ = zeros( maskBandW , maskBandW );
%----------------------------------------------------------
% the main loop
%----------------------------------------------------------
for i=halfBW+1:dim1-halfBW
    for j=halfBW+1:dim2-halfBW


         patchTmp   = imageIn( i-halfBW:i+halfBW , j-halfBW:j+halfBW );         
%          patchTmp = reshape(patchTmp,1,[]);

        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        % update the histogram and cdf
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        if j==halfBW+1 % first element in each row

            workingHist = zeros(imrange,1);
            
            for k=1:maskBandW
                for l=1:maskBandW
                    
                    intensityVal = patchTmp(k,l);
                    workingHist( intensityVal+1 ) = workingHist( intensityVal+1 ) + 1;
                                       
                end
            end

%               workingHist( patchTmp(1:nPosi) ) = workingHist(  patchTmp(1:nPosi)  ) + 1;

        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        else

            patchForRemove = imageIn( i-halfBW:i+halfBW , j-halfBW-1:j-halfBW-1 );
%             patchForRemove = reshape(patchForRemove,1,[]);
            
            patchForAdd    = imageIn( i-halfBW:i+halfBW , j+halfBW:j+halfBW );
%             patchForAdd    = reshape(patchForAdd,1,[]);
           
            
           for tmpdim1=1:maskBandW  
                
                % update removed pixels
                intensityVal = patchForRemove(tmpdim1,1);
                 workingHist( intensityVal+1 ) = workingHist( intensityVal+1 )   - 1;                
                % update added pixels
                intensityVal = patchForAdd(tmpdim1,1);
                workingHist( intensityVal+1 ) = workingHist( intensityVal+1 )   + 1;                     


           end            

%              % update removed pixels
%              workingHist( patchForRemove(1:maskBandW) ) = workingHist( patchForRemove(1:maskBandW) ) - 1;                
%             % update added pixels
%              workingHist( patchForAdd(1:maskBandW) ) = workingHist( patchForAdd(1:maskBandW) ) + 1;                     

            
        end
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
       
        workingCDF = cumsum(workingHist);                   
        CDFmin = min( workingCDF( find(workingCDF) ) );


        %patchTmpEQ(1:nPosi) = floor(  workingCDF(  patchTmp(1:nPosi)+1 )   *  imrangeMinusOne / nPosi  );
        %patchTmpEQ(1:nPosi) = round(  (  workingCDF(  patchTmp(1:nPosi)+1 ) - CDFmin)  *  imrangeMinusOne / (nPosi - CDFmin)  );

        
%        tmpval01 = (nPosi - CDFmin);
                

        if (CDFmin == nPosi) , patchTmpEQ(1:nPosi) = imrangeNew;
        else                 , patchTmpEQ(1:nPosi) = round(  (  workingCDF(  patchTmp(1:nPosi)+1 ) - CDFmin)  *  imrangeNew / (nPosi - CDFmin)  );
        end
        
% 
%         if ( isempty( find((workingHist-thre_maxIntensityBinCount)>0) ) ) 
%             for k=1:nPosi
%                 imageOutFinal( i+anchor_x_shift_ary(k) , j+anchor_y_shift_ary(k) )  = ...
%                     imageOutFinal( i+anchor_x_shift_ary(k) , j+anchor_y_shift_ary(k) ) + 1;   
%             end
%         else
%         end


% 
%         
% patchTmp
% patchTmpEQ
% patchTmpEQX =  histeq(patchTmp);
% patchTmpEQX
% pause

        for k=1:nPosi
            imageOut{k}( i+anchor_x_shift_ary(k) , j+anchor_y_shift_ary(k) )  = patchTmpEQ( anchorOnPatchX_ary(k) , anchorOnPatchY_ary(k) );   
        end
   
        
    end
end
%----------------------------------------------------------
% nonZeros = find(imageOutFinal>0);
%                 imageOutFinal(nonZeros) = (imageOutFinal(nonZeros) / max(imageOutFinal(nonZeros))) *imrange;   

% imageOut{1} = uint8(( imageOut{1} + imageOut{9} )/2) ;
% imageOut{2} = uint8(( imageOut{2} + imageOut{8} )/2) ;
% imageOut{3} = uint8(( imageOut{3} + imageOut{7} )/2) ;
% imageOut{4} = uint8(( imageOut{4} + imageOut{6} )/2) ;
% 


% for i=1:nPosi
%     imageOut{i}( find(imageOut{i} ==0) ) = 1; 
% end
% imageOut{1} = imageOut{1} .* imageOut{9} / imrange;
% imageOut{2} = imageOut{2} .* imageOut{8} / imrange;
% imageOut{3} = imageOut{3} .* imageOut{7} / imrange;
% imageOut{4} = imageOut{4} .* imageOut{6} / imrange;

% log

% imageOut{1} = exp(log(imageOut{1}) + log(imageOut{9}) / 2);
% imageOut{2} = exp(log(imageOut{2}) + log(imageOut{8}) / 2);
% imageOut{3} = exp(log(imageOut{3}) + log(imageOut{7}) / 2);
% imageOut{4} = exp(log(imageOut{4}) + log(imageOut{6}) / 2);


% % %--------------------------------------------------------------------------
% % OLHE
% % %--------------------------------------------------------------------------
% for i=1:nPosi
%     imageOutFinal = imageOutFinal + imageOut{i};
% end
% imageOutFinal = imageOutFinal / nPosi;
% % %--------------------------------------------------------------------------
% 
% % 
% %--------------------------------------------------------------------------
% % OLHE without LHE
% % %--------------------------------------------------------------------------
% for i=1:(nPosi-1)/2
%     imageOutFinal = imageOutFinal + single(imageOut{i});
% end
% for i=(nPosi+1)/2+1:nPosi
%     imageOutFinal = imageOutFinal + imageOut{i};
% end
% imageOutFinal = imageOutFinal / (nPosi-1);
% % %--------------------------------------------------------------------------


% 
% %--------------------------------------------------------------------------
% % MOSAIC
% %--------------------------------------------------------------------------
% imageOutFinal = zeros(dim1*maskBandW,dim2*maskBandW);
% for i=1:maskBandW
%     for j=1:maskBandW
%                 
%         patchidx =  (i-1)*maskBandW + j;
% %  patchidx       
% %  (i-1)*maskBandW+1
% %  i*maskBandW
% %   imageOut{patchidx}(:,:)
%         imageOutFinal( (i-1)*dim1+1:i*dim1 , (j-1)*dim2+1:j*dim2   ) =  imageOut{patchidx};
%         
%     end
% end
% %--------------------------------------------------------------------------
% 

% 
% %--------------------------------------------------------------------------
% % MOSAIC
% %--------------------------------------------------------------------------
% mosaicMargin = halfBW;
% 
% dim1New = dim1-2*mosaicMargin;
% dim2New = dim2-2*mosaicMargin;
% 
% imageOutFinal = zeros(dim1New*maskBandW,dim2New*maskBandW);
% for i=1:maskBandW
%     for j=1:maskBandW
%         patchidx =  (i-1)*maskBandW + j;
%         imageOutFinal( (i-1)*dim1New+1:i*dim1New , (j-1)*dim2New+1:j*dim2New   ) =   ...
%         imageOut{patchidx}(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );
%         
%     end
% end
% % 
% %--------------------------------------------------------------------------
% %imageOutFinal( dim1New+1:2*dim1New , dim2New+1:2*dim2New   ) = imageIn(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );
% %--------------------------------------------------------------------------
% 




% --------------------------------------------------------------------------
% MOSAIC 9
% --------------------------------------------------------------------------


dim1New = dim1-2*halfBW;
dim2New = dim2-2*halfBW;

imageOutFinal = zeros(dim1New*3,dim2New*3);
tmpXidx = 0;
for i=1:halfBW:maskBandW
    tmpXidx = tmpXidx + 1;
    tmpYidx = 0;
    
    xStart = (tmpXidx-1)*halfBW+1;
    xEnd   = xStart+dim1New-1;
    
    
    for j=1:halfBW:maskBandW
        tmpYidx = tmpYidx + 1;
 
        yStart = (tmpYidx-1)*halfBW+1;
        yEnd   = yStart+dim2New-1;
      
        patchidx =  (i-1)*maskBandW + j;
       
        % remove image borders
        imageOutFinal( (tmpXidx-1)*dim1New+1:tmpXidx*dim1New , (tmpYidx-1)*dim2New+1:tmpYidx*dim2New   ) =   ...
        imageOut{patchidx}( xStart:xEnd , yStart:yEnd );
        

    end
end

% Put the input image on the mosaic center
%--------------------------------------------------------------------------
%imageOutFinal( dim1New+1:2*dim1New , dim2New+1:2*dim2New   ) = imageIn(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );
%--------------------------------------------------------------------------
%imageOutFinal = imageOut{1};



% 
% % 
% 
% %--------------------------------------------------------------------------
% % cascade 3
% %--------------------------------------------------------------------------
% mosaicMargin = halfBW;
% 
% dim1New = dim1-2*mosaicMargin;
% dim2New = dim2-2*mosaicMargin;
% 
% imageOutFinal = zeros(dim1New*3,dim2New*3);
% tmpXidx = 0;
% for i=1:halfBW:maskBandW
%     tmpXidx = tmpXidx + 1;
%     tmpYidx = 0;
%     for j=1:halfBW:maskBandW
%         tmpYidx = tmpYidx + 1;
%        
%         patchidx =  (i-1)*maskBandW + j;
%         imageOutFinal( (tmpXidx-1)*dim1New+1:tmpXidx*dim1New , (tmpYidx-1)*dim2New+1:tmpYidx*dim2New   ) =   ...
%         imageOut{patchidx}(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );
%         
%     end
% end
% % 
% %--------------------------------------------------------------------------
% imageOutFinal2 = zeros(dim1New*4,dim2New);
% imageOutFinal2(           1:dim1New   , 1:dim2New ) = (  imageOutFinal(           1:dim1New   , 1:dim2New ) + imageOutFinal( dim1New*2+1:dim1New*3 , dim2New*2+1:dim2New*3 )  ) / 2;
% imageOutFinal2( dim1New  +1:dim1New*2 , 1:dim2New ) = (  imageOutFinal( dim1New  +1:dim1New*2 , 1:dim2New ) + imageOutFinal( dim1New  +1:dim1New*2 , dim2New*2+1:dim2New*3 )  ) / 2;
% imageOutFinal2( dim1New*2+1:dim1New*3 , 1:dim2New ) = (  imageOutFinal( dim1New*2+1:dim1New*3 , 1:dim2New ) + imageOutFinal(           1:dim1New   , dim2New*2+1:dim2New*3 )  ) / 2;
% 
% imageOutFinal2( dim1New*3+1:dim1New*4 , 1:dim2New ) = (  imageOutFinal(           1:dim1New   , dim2New+1:dim2New*2 ) + imageOutFinal(     dim1New*2+1:dim1New*3   , dim2New+1:dim2New*2 )  ) / 2; 
% imageOutFinal = imageOutFinal2;
% %--------------------------------------------------------------------------
% 
% 




% --------------------------------------------------------------------------
% 8 averaged
% --------------------------------------------------------------------------
% mosaicMargin = halfBW;
% 
% dim1New = dim1-2*mosaicMargin;
% dim2New = dim2-2*mosaicMargin;
% 
% imageOutFinal = zeros(dim1New,dim2New);
% tmpXidx = 0;
% for i=1:halfBW:maskBandW
%     tmpXidx = tmpXidx + 1;
%     tmpYidx = 0;
%     for j=1:halfBW:maskBandW
%         tmpYidx = tmpYidx + 1;
%        
%         patchidx =  (i-1)*maskBandW + j;
%         
%         if patchidx ~= ((nPosi-1)/2+1 )
%             imageOutFinal =  imageOutFinal+  ...
%             imageOut{patchidx}(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );        
%         end
%     end
% end
% % 
% imageOutFinal = imageOutFinal / 8;
% imageOutFinal = imageOutFinal( 1+halfBW:end-halfBW , 1+halfBW:end-halfBW );
% --------------------------------------------------------------------------
% imageOutFinal( dim1New+1:2*dim1New , dim2New+1:2*dim2New   ) = imageIn(mosaicMargin+1:dim1-mosaicMargin , mosaicMargin+1:dim2-mosaicMargin  );
% --------------------------------------------------------------------------



% 
% 
% %--------------------------------------------------------------------------
% % CASCADE
% %--------------------------------------------------------------------------
% imageOutFinal = zeros(dim1,dim2*maskBandW*maskBandW);
% for j=1:maskBandW*maskBandW
%     imageOutFinal( 1:dim1 , (j-1)*dim2+1:j*dim2   ) =  imageOut{j};
% end
% %--------------------------------------------------------------------------



% 
% %--------------------------------------------------------------------------
% % average all
% %--------------------------------------------------------------------------
% imageOutFinal = double(zeros(dim1,dim2));
% for j=1:maskBandW*maskBandW
%     imageOutFinal = imageOutFinal + double(imageOut{j});
% end
% imageOutFinal = imageOutFinal / maskBandW*maskBandW;
% %--------------------------------------------------------------------------
% 





%imageOutFinal = imageOut{ (nPosi-1)/2+1 };






