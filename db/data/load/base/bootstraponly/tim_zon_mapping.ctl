[ select count(*) row_count 
    from tim_zon_mapping
   where java_id = '@java_id@' ] 
   |
if (@row_count > 0) 
{
    [ update tim_zon_mapping
       set win32_id = '@win32_id@',
           ena_flg = @ena_flg@
       where java_id = '@java_id@'
    ] 
}
else 
{ 
    [ insert into tim_zon_mapping 
       (java_id, win32_id, ena_flg)
      VALUES ('@java_id@', '@win32_id@', @ena_flg@)
     ] 
}

