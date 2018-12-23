function [ index, weight] = bilinear_interpolation(r,c,nr,nc,nbinr,nbinc)

    %%row col
    wrapslowr=false;
    wrapshighr=false;
    wrapslowc=false;
    wrapshighc=false;

    qr = (r-1)/nr*nbinr-0.5;
    if (qr<0)
        wrapslowr=true;
    elseif (qr>nbinr-1)
        wrapshighr=true;
    end
    quant = qr + nbinr;
    b= floor(quant);
    wr = quant - b;
    binlowr= mod(b,nbinr);
    binhighr = mod(b+1,nbinr);  

    qc = (c-1)/nc*nbinc-0.5;
    if (qc<0)
        wrapslowc=true;
    elseif (qc>nbinc-1)
        wrapshighc=true;
    end
    quant = qc + nbinc;
    b= floor(quant);
    wc = quant - b;
    binlowc= mod(b,nbinc);
    binhighc = mod(b+1,nbinc);  

    index = zeros(nbinr*nbinc,1);
    weight = zeros(nbinr*nbinc,1);

    % low-low
    if ~wrapslowr && ~wrapslowc
        index(1) = binlowr+1+binlowc*nbinr;
        weight(1) = (1-wr)*(1-wc);
    end
    % high-low
    if ~wrapshighr && ~wrapslowc
        index(2) = binhighr+1+binlowc*nbinr;
        weight(2) = wr*(1-wc);
    end
    % low-high
    if ~wrapslowr && ~wrapshighc
        index(3) = binlowr+1+binhighc*nbinr;
        weight(3) = (1-wr)*wc;
    end
    % high-high
    if ~wrapshighr && ~wrapshighc
        index(4) = binhighr+1+binhighc*nbinr;
        weight(4) = wr*wc;
    end

end

