[ select count(*) row_count 
   from crncy_fmt 
  where crncy_fmt = '@crncy_fmt@' 
] 
| 
if (@row_count > 0) 
{
    [ update crncy_fmt 
         set crncy_fmt = '@crncy_fmt@',          
             pos_neg_cd = '@pos_neg_cd@',          
             cs_precedes = @cs_precedes@,          
             sep_by_space = @sep_by_space@,          
             sign_posn = @sign_posn@,          
             grp_nam = '@grp_nam@' 
      where  crncy_fmt = '@crncy_fmt@' 
     ]
}
else 
{ 
    [ insert into crncy_fmt
         (crncy_fmt, pos_neg_cd, cs_precedes, 
          sep_by_space, sign_posn, grp_nam)
        VALUES
         ('@crncy_fmt@', '@pos_neg_cd@', @cs_precedes@, 
          @sep_by_space@, @sign_posn@, '@grp_nam@') 
    ] 
}
