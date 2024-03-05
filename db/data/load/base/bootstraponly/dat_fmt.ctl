[ select count(*) row_count 
    from dat_fmt 
   where dat_fmt = '@dat_fmt@' 
] 
| 
if (@row_count > 0) 
{
    [ update dat_fmt 
         set dat_fmt = '@dat_fmt@',          
             dat_fmt_cd = '@dat_fmt_cd@',          
             mon_dsp_typ = '@mon_dsp_typ@',          
             dat_sep_char = '@dat_sep_char@',          
             grp_nam = '@grp_nam@'
       where dat_fmt = '@dat_fmt@' 
    ] 
}
else 
{ 
    [ insert into dat_fmt
             (dat_fmt, dat_fmt_cd, mon_dsp_typ, 
              dat_sep_char, grp_nam)
      VALUES ('@dat_fmt@', '@dat_fmt_cd@', '@mon_dsp_typ@', 
              '@dat_sep_char@', '@grp_nam@') 
    ] 
}
