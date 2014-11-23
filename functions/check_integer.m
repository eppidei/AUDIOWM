function [rounded_val]=check_integer(WM,var_string,check_type,tolerance,severity_level)

%%%in params check%%%%%
if (ischar(var_string)==0)
    
    error('var string must be a string type');
end
if (ischar(check_type)==0)
    
    error('check_type must be a string type');
end
if (ischar(severity_level)==0)
    
    error('severity_level must be a string type');
end

str = ['mod(',var_string,',1);'];
str2 = ['round(',var_string,');'];
out_val = eval(str);

if strcmp(check_type,'exact')
    
    
    if (out_val~=0)
        if strcmp(severity_level,'error')
            error([var_string,' =%f is not an integer value'],eval(var_string));
        elseif strcmp(severity_level,'warning')
            warning([var_string,' =%f is not an integer value'],eval(var_string));
        else
            error('severity level must be warning or error, actual %s',severity_level);
        end
    end
    
elseif strcmp(check_type,'tolerance') 
    
    if (abs(out_val )>tolerance && abs(out_val )< (1-tolerance))
        if strcmp(severity_level,'error')
            error([var_string,' =%f is not an integer value frac part =%f tolerance =%f '],eval(var_string),out_val,tolerance);
         elseif strcmp(severity_level,'warning')
             warning([var_string,' =%f is not an integer value frac part =%f tolerance =%f '],eval(var_string),out_val,tolerance);
             rounded_val=eval(var_string);
             else
            error('severity level must be warning or error, actual %s',severity_level);
        end
    else
        rounded_val = eval(str2);
        warning(['rounding ',var_string,'from %10.30f to %f'],eval(var_string), rounded_val);
        
    end
    
else
    
    error('check type must be exact or tolerance string, actual is %s,  check_type');


end