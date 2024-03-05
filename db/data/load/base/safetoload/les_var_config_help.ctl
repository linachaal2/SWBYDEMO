[ select count(*) row_count 
    from les_var_config 
   where var_nam = '@var_nam@' 
     and appl_id = '@appl_id@' 
     and frm_id = '@frm_id@' 
     and addon_id = '@addon_id@' 
     and cust_lvl = @cust_lvl@ ] | 

    if (@row_count > 0) 
    {
       [ update les_var_config 
            set help_id = to_number('@help_id@'),
                help_fil_id = '@help_fil_id@'
          where var_nam = '@var_nam@' 
            and appl_id = '@appl_id@' 
            and frm_id = '@frm_id@' 
            and addon_id = '@addon_id@' 
            and cust_lvl = @cust_lvl@ ] 
    }
    else
    {
        [ insert 
	    into les_var_config
                 (var_nam, appl_id, frm_id, addon_id, 
                 cust_lvl, help_id, help_fil_id, 
		 vis_flg, ena_flg, ctxt_flg,
		 grp_nam)
          VALUES ('@var_nam@', '@appl_id@', '@frm_id@', '@addon_id@',
                  @cust_lvl@, 
                  to_number('@help_id@'), 
		  '@help_fil_id@',
		  1, 1, 1,
		  'dcs_data') ] 
    }
