[ select count(*) row_count 
    from grd_mnu_itm 
   where grd_var_nam = '@grd_var_nam@'
     and lvl_id = '@lvl_id@' 
     and appl_id= nvl('@appl_id@' , 'LES')
     and frm_id = nvl('@frm_id@' , 'LES')
     and addon_id = nvl('@addon_id@' , 'LES')
     and mnu_itm = '@mnu_itm@'
     and cust_lvl = '@cust_lvl@' 
] 
| 
   if (@row_count > 0) 
   {
       [ update grd_mnu_itm 
            set parent_itm = '@parent_itm@',          
                mnu_seq = '@mnu_seq@',                  
                enable_formula = '@enable_formula@',          
                btn_key = '@btn_key@',
                sel_rule = nvl('@sel_rule@', 'A'),
                grp_nam = '@grp_nam@'
	      where grd_var_nam = '@grd_var_nam@'
                and lvl_id = '@lvl_id@' 
                and appl_id = nvl('@appl_id@' , 'LES')
                and frm_id = nvl('@frm_id@' , 'LES')
                and addon_id = nvl('@addon_id@' , 'LES')
                and mnu_itm = '@mnu_itm@'
                and cust_lvl = '@cust_lvl@' 
	    ] 
    }
    else 
    { 
        [insert into 
                grd_mnu_itm(
                        appl_id,
                        frm_id,
                        addon_id,
                        grd_var_nam,         
                        lvl_id,          
                        mnu_itm,          
                        parent_itm,          
                        cust_lvl,    
                        mnu_seq,
                        enable_formula,
                        sel_rule,
                        btn_key,
                        grp_nam)
                VALUES( nvl('@appl_id@', 'LES'),
                        nvl('@frm_id@', 'LES'),
                        nvl('@addon_id@', 'LES'),
'@grd_var_nam@',
'@lvl_id@',          
'@mnu_itm@',          
'@parent_itm@',          
'@cust_lvl@',    
'@mnu_seq@',
'@enable_formula@',
                        nvl('@sel_rule@', 'A'),
'@btn_key@',
'@grp_nam@') 
	] 
    }
|
    create cache time stamp
      where obj_nam = "MCSGrdMnuItm"
        and idx_val = "LES"
