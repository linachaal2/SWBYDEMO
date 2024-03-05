[ select count(*) row_count 
    from locale_parm 
   where locale_id = '@locale_id@' 
     and usr_id = '@usr_id@' 
] 
| 
if (@row_count > 0) 
{
    [ update locale_parm 
         set locale_id = '@locale_id@',          
             usr_id = '@usr_id@',          
             bool_t_char = '@bool_t_char@',          
             bool_f_char = '@bool_f_char@',          
             bool_toggle = '@bool_toggle@',          
             crncy_code = '@crncy_code@',          
             positive_sign = '@positive_sign@',          
             negative_sign = '@negative_sign@', 
             p_sign_posn = to_number('@p_sign_posn@'),    
             n_sign_posn = to_number('@n_sign_posn@'),        
             decimal_point = '@decimal_point@',          
             thousands_sep = '@thousands_sep@',          
             grouping = '@grouping@',          
             dat_fmt_cd = '@dat_fmt_cd@',          
             mon_dsp_typ = '@mon_dsp_typ@',          
             dat_sep_char = '@dat_sep_char@',          
             tim_fmt_cd = '@tim_fmt_cd@',          
             tim_sep_char = '@tim_sep_char@',          
             am_str = '@am_str@',          
             pm_str = '@pm_str@',          
             grp_nam = '@grp_nam@'
       where locale_id = '@locale_id@' 
         and usr_id = '@usr_id@' 
     ] 
}
else 
{ 
    [ insert into locale_parm
            (locale_id, usr_id, bool_t_char, 
             bool_f_char, bool_toggle, crncy_code, 
             positive_sign, negative_sign, 
 	     p_sign_posn,n_sign_posn, decimal_point, thousands_sep, 
             grouping, dat_fmt_cd, mon_dsp_typ, 
             dat_sep_char, tim_fmt_cd, 
             tim_sep_char, am_str, pm_str, 
             grp_nam)
       VALUES
            ('@locale_id@', '@usr_id@', '@bool_t_char@', 
             '@bool_f_char@', '@bool_toggle@', '@crncy_code@', 
             '@positive_sign@', '@negative_sign@', 
	     to_number('@p_sign_posn@'),to_number('@n_sign_posn@'), 	     '@decimal_point@', '@thousands_sep@', '@grouping@', 	     '@dat_fmt_cd@', '@mon_dsp_typ@', '@dat_sep_char@', 	     '@tim_fmt_cd@','@tim_sep_char@', '@am_str@', '@pm_str@', 
             '@grp_nam@') 
     ] 
}
