[ select count(*) row_count 
    from mu_mst 
   where mu = '@mu@' 
] 
| 
if (@row_count > 0) 
{
    [ update mu_mst 
         set mu = '@mu@',          
             mu_cat = '@mu_cat@',          
             mu_sys = '@mu_sys@',          
             cf_numerator = @cf_numerator@,          
             cf_denominator = @cf_denominator@, 
	     ena_flg = @ena_flg@,
             dsp_precision = @dsp_precision@,
	     host_uom_cod = '@host_uom_cod@',    
             grp_nam = '@grp_nam@'
       where mu = '@mu@' 
    ] 
}
else 
{ 
    [ insert into mu_mst
            (mu, mu_cat, mu_sys, 
             cf_numerator, cf_denominator, ena_flg, dsp_precision, 		host_uom_cod,grp_nam)
        VALUES
            ('@mu@', '@mu_cat@', '@mu_sys@', 
             @cf_numerator@, @cf_denominator@, @ena_flg@, @dsp_precision@,
	    '@host_uom_cod@','@grp_nam@') 
    ] 
}
