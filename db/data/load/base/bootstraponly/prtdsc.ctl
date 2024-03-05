[select count(*) row_count
   from prtdsc
  where colnam = '@colnam@'
    and colval = '@colval@'
    and locale_id = '@locale_id@']
|
if (@row_count > 0) 
{
    [update prtdsc
        set colnam = '@colnam@',
            colval = '@colval@',
            locale_id = '@locale_id@',
            lngdsc = '@lngdsc@',
            short_dsc = '@short_dsc@'
     where  colnam = '@colnam@' and colval = '@colval@' and locale_id = '@locale_id@' ] 
}
else
{
    [insert into prtdsc
       (colnam, colval, locale_id, lngdsc, short_dsc)
     VALUES
       ('@colnam@', '@colval@', '@locale_id@', '@lngdsc@', '@short_dsc@') ] 
}
