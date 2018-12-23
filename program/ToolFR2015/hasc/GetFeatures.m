function [ imgFeat ] = GetFeatures( data, opt )
    
    % Marco San Biagio      Version 1.00
    % Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
    % Please email me if you have questions.
    %
    % INPUTS
    % data             - (w x h) matrix representing the current image; w and h are the width and height of the image (expressed in number of pixels) 
    % 
    %
    % OUTPUT
    % imgFeat	       - (w x h x d) matrix containing the features extracted from the image; d is the number of low level features
    %
    % [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
    % Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
    % International Conference on Computer Vision, Proceedings of. 2013.
    
    si = size(data);
    if size(data,3)>1
    dataGRAY = rgb2gray(data);   
    end
    dataGRAY = data;
    idx     = 1;
    
    % Feature Parameters
    hx = [-1,0,1];
    hy = -hx';
    featborder = 2; % 2 pixels for the Gradient Computation
    HFwoFB = si(1)-2*featborder;
    WFwoFB = si(2)-2*featborder;
    
    imgFeat = zeros(HFwoFB,WFwoFB,opt.NoFeat);

    % 1- Intensity
    imgFeat(:,:,idx) = dataGRAY(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder,1);
    idx = idx + 1;
    % 2- First Order Gradient X and Y 
    SobelxGray = imfilter(double(dataGRAY),hx);
    imgFeat(:,:,idx) = SobelxGray(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder);
    idx = idx + 1;
    SobelyGray = imfilter(double(dataGRAY),hy);
    imgFeat(:,:,idx) = SobelyGray(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder);
    idx = idx + 1;
    % 3- Second Order Gradient X and Y 
    SobelxxGray = imfilter(SobelxGray,hx);
    imgFeat(:,:,idx) = SobelxxGray(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder);
    idx = idx + 1;
    SobelyyGray = imfilter(SobelyGray,hy);
    imgFeat(:,:,idx) = SobelyyGray(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder);
    idx = idx + 1;
    % 4- Magnitude
    Magn = sqrt(double(SobelxGray.^2 + SobelyGray.^2));
    imgFeat(:,:,idx) = Magn(featborder+1:si(1)-featborder, featborder+1:si(2)-featborder);

end

