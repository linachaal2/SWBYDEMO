[ select count(*) row_count  
    from les_grid_config 
   where usr_id = '@usr_id@' 
     and locale_id = '@locale_id@' 
     and appl_id = '@appl_id@' 
     and frm_id = '@frm_id@' 
     and grid_nam = '@grid_nam@' 
     and grid_fld_nam = '@grid_fld_nam@' ] 
| 
if (@row_count > 0) 
{
    [ update les_grid_config 
         set usr_id = '@usr_id@',          
             locale_id = '@locale_id@',          
             appl_id = '@appl_id@',          
             frm_id = '@frm_id@',          
             grid_nam = '@grid_nam@',          
             grid_fld_nam = '@grid_fld_nam@',          
             grid_fld_width = to_number('@grid_fld_width@'),          
             grid_fld_seq = to_number('@grid_fld_seq@'),          
             grid_fld_vis = to_number('@grid_fld_vis@'),          
             srt_dir = to_number('@srt_dir@'),
             srt_idx = to_number('@srt_idx@'),
             grp_nam = '@grp_nam@'
       where usr_id = '@usr_id@' 
         and locale_id = '@locale_id@' 
         and appl_id = '@appl_id@' 
         and frm_id = '@frm_id@' 
         and grid_nam = '@grid_nam@' 
         and grid_fld_nam = '@grid_fld_nam@' 
    ] 
}
else 
{ 
    [ insert into les_grid_config
        (usr_id, locale_id, appl_id, 
         frm_id, grid_nam, grid_fld_nam, 
         grid_fld_width, grid_fld_seq, 
         grid_fld_vis, grp_nam,
         srt_dir, srt_idx)
      VALUES 
        ('@usr_id@', '@locale_id@', '@appl_id@', 
         '@frm_id@', '@grid_nam@', '@grid_fld_nam@', 
         to_number('@grid_fld_width@'), to_number('@grid_fld_seq@'), 
         to_number('@grid_fld_vis@'), '@grp_nam@',
         to_number('@srt_dir@'), to_number('@srt_idx@')) 
    ] 
}
