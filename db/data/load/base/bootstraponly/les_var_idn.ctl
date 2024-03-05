[ select count(*)  row_count 
      from les_var_idn 
     where var_nam = '@var_nam@' 
] 

| 
   if (@row_count > 0) 
   {
        change variable identifier
          where var_nam = "@var_nam@"          
            and fld_idn = "@fld_idn@"          
	    and sid_flg = "@sid_flg@"          
	    and wke_flg = "@wke_flg@"          
	    and rfe_flg = "@rfe_flg@"          
	    and grp_nam = "@grp_nam@"
        
   }
   else 
   { 
        create variable identifier
          where var_nam = "@var_nam@"          
            and fld_idn = "@fld_idn@"          
	    and sid_flg = "@sid_flg@"          
	    and wke_flg = "@wke_flg@"          
	    and rfe_flg = "@rfe_flg@"          
	    and grp_nam = "@grp_nam@"
        
   }

