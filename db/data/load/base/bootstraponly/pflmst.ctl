[ select count(*) row_count 
    from pflmst 
   where oprcod = '@oprcod@' 
     and prfnam = '@prfnam@' 
     and prftyp = '@prftyp@' 
     and srtseq = @srtseq@ ] | 
 
    if (@row_count > 0) 
    { 
        [ update pflmst
             set oprcod = '@oprcod@',
                 prfnam = '@prfnam@',
                 prftyp = '@prftyp@',
                 srtseq = @srtseq@,
                 prstr1 = '@prstr1@',
                 prstr2 = '@prstr2@',
                 grp_nam = '@grp_nam@'
           where oprcod = '@oprcod@' 
             and prfnam = '@prfnam@' 
             and prftyp = '@prftyp@' 
             and srtseq = @srtseq@ ] 
    }  
    else 
    { 
        [ insert into pflmst 
              (oprcod, prfnam, prftyp, srtseq, prstr1, prstr2, grp_nam) 
            values 
              ('@oprcod@', '@prfnam@', '@prftyp@', @srtseq@, '@prstr1@', 
               '@prstr2@', '@grp_nam@') ] 
    } 
