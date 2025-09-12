function [ hpcycle hptrend ] = hpfilter(x,HP_LAMBDA);

LENGTH = max(size(x));

% The following piece is due to Gerard A. Pfann

   HP_mat = [1+HP_LAMBDA, -2*HP_LAMBDA, HP_LAMBDA,              zeros(1,LENGTH-3);
             -2*HP_LAMBDA,1+5*HP_LAMBDA,-4*HP_LAMBDA,HP_LAMBDA, zeros(1,LENGTH-4);
                           zeros(LENGTH-4,LENGTH);
              zeros(1,LENGTH-4),HP_LAMBDA,-4*HP_LAMBDA,1+5*HP_LAMBDA,-2*HP_LAMBDA;     
              zeros(1,LENGTH-3),          HP_LAMBDA,   -2*HP_LAMBDA, 1+HP_LAMBDA  ];
   for iiiii=3:LENGTH-2;
     HP_mat(iiiii,iiiii-2)=HP_LAMBDA;
     HP_mat(iiiii,iiiii-1)=-4*HP_LAMBDA;
     HP_mat(iiiii,iiiii)=1+6*HP_LAMBDA;
     HP_mat(iiiii,iiiii+1)=-4*HP_LAMBDA;
     HP_mat(iiiii,iiiii+2)=HP_LAMBDA;
   end;
hptrend = HP_mat\x;
hpcycle = x-hptrend; 

      
      