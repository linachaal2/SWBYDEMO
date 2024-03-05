[ select count(*) row_count from dda_fltr_grp_layout where
    fltr_grp = '@fltr_grp@' and cust_lvl = @cust_lvl@ ] | 
    if (@row_count > 0)
    {
       [ update dda_fltr_grp_layout set
          fltr_grp = '@fltr_grp@'
,          cust_lvl = @cust_lvl@
,          srtseq = to_number('@srtseq@')
,          grp_typ = to_number('@grp_typ@')
,          num_cols = to_number('@num_cols@')
,          navigation = to_number('@navigation@')
,          border_style = to_number('@border_style@')
,          column_offset = to_number('@column_offset@')
,          row_offset = to_number('@row_offset@')
,          par_grp = '@par_grp@'
,          attach_grp = '@attach_grp@'
,          attach_loc = to_number('@attach_loc@')
,          attach_offset = to_number('@attach_offset@')
,          grp_nam = '@grp_nam@'
             where  fltr_grp = '@fltr_grp@' and cust_lvl = @cust_lvl@ ] }
     else 
     { 
       [ insert into dda_fltr_grp_layout
                  (fltr_grp, cust_lvl, srtseq, grp_typ, num_cols, navigation, border_style, column_offset, row_offset, par_grp, attach_grp, attach_loc, attach_offset, grp_nam)
           VALUES ('@fltr_grp@', @cust_lvl@, to_number('@srtseq@'), to_number('@grp_typ@'), to_number('@num_cols@'), to_number('@navigation@'), to_number('@border_style@'), to_number('@column_offset@'), to_number('@row_offset@'), '@par_grp@', '@attach_grp@', to_number('@attach_loc@'), to_number('@attach_offset@'), '@grp_nam@')] 
     }
