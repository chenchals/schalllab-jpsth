            growth = 1; decay = 20;
            halfBinWidth = round(decay*8);
            binSize = (halfBinWidth*2)+1;
            kernel = 0:halfBinWidth;
            postHalfKernel = (1-(exp(-(kernel./growth)))).*(exp(-(kernel./decay)));
            %normalize area of the kernel
            postHalfKernel = postHalfKernel./sum(postHalfKernel);
            %set preHalfKernel to zero
            kernel(1:halfBinWidth) = 0;
            kernel(halfBinWidth+1:binSize) = postHalfKernel;
            % make kernel a column vector to do a convn on matrix
            kernel = kernel';

            %
            growth_ms = 1;
            decay_ms = 20;
            factor = 8;
            bins = 0:round(decay_ms*factor);
            fx_exp = @(x) exp(-bins./x);
            pspKernel = [zeros(1,length(bins)-1) ...
                         (1-fx_exp(growth_ms)).*fx_exp(decay_ms)]';
            pspKernel = pspKernel./sum(pspKernel);
