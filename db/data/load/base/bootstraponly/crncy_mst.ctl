[ select count(*) row_count 
    from crncy_mst 
   where crncy_code = '@crncy_code@' 
] 
| 
if (@row_count > 0) 
{
    [ update crncy_mst 
         set crncy_code = '@crncy_code@',               
             decimal_point = '@decimal_point@',  
	     thousands_sep = '@thousands_sep@',         
             grouping_len = '@grouping_len@',     
	     crncy_sym = '@crncy_sym@',	     
             pos_fmt = '@pos_fmt@',  
	     neg_fmt = '@neg_fmt@',         
             frac_digits = @frac_digits@,
	     ena_flg = @ena_flg@,        
             grp_nam = '@grp_nam@'
       where crncy_code = '@crncy_code@' 
    ]
}
else 
{ 
    [ insert into crncy_mst
             (crncy_code, decimal_point, thousands_sep, 
              grouping_len, crncy_sym,pos_fmt, neg_fmt, frac_digits, ena_flg, grp_nam)
      VALUES ('@crncy_code@', '@decimal_point@', '@thousands_sep@', 
              '@grouping_len@','@crncy_sym@', '@pos_fmt@', '@neg_fmt@', @frac_digits@, @ena_flg@, '@grp_nam@') 
    ]
}
