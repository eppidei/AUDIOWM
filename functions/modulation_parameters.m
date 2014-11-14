function [order_M]=modulation_parameters(mod_type)


if strcmp(mod_type,'BPSK')

    order_M       = 2;

else
    
    error('Invalid Parameter');


end