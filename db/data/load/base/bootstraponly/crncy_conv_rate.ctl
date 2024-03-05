[ select count(*) row_count 
    from crncy_conv_rate 
   where crncy_code = '@crncy_code@' and effectiveDate = to_date('@effectiveDate@','YYYYMMDDHH24MISS')
] 
| 
if (@row_count > 0) 
{
    [ update crncy_conv_rate 
         set crncy_code = '@crncy_code@',          
             effectiveDate = to_date('@effectiveDate@','YYYYMMDDHH24MISS'),          
             conv_rate = '@conv_rate@'          
       where crncy_code = '@crncy_code@' and effectiveDate = to_date('@effectiveDate@','YYYYMMDDHH24MISS') 
    ] 
}
else 
{ 
    [ insert into crncy_conv_rate
            (crncy_code, effectiveDate, conv_rate)
        VALUES
            ('@crncy_code@', to_date('@effectiveDate@','YYYYMMDDHH24MISS'), '@conv_rate@') 
    ] 
}
