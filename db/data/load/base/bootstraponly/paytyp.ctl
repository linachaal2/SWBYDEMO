[ select count(*) row_count 
    from paytyp 
   where paycod = '@paycod@'
     and dstnam = '@dstnam@']
|
if (@row_count > 0)
{
    [ update paytyp
         set paycod = '@paycod@',
             dstnam = '@dstnam@',
             payval = '@payval@',
             codflg = '@codflg@'
       where paycod = '@paycod@' ]
}
else
{
    [ insert into paytyp
         (paycod, dstnam,
          payval, codflg)
      values
         ('@paycod@', '@dstnam@',
          '@payval@', '@codflg@') ]
}
