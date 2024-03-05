[ select count(*) row_count 
    from wf_appl 
   where appl_id = '@appl_id@' 
     and cust_lvl = @cust_lvl@ ] | 

    if (@row_count > 0) 
    {
        [ update wf_appl 
             set help_id = '@help_id@',
                 help_fil_id = '@help_fil_id@'
           where appl_id = '@appl_id@' 
             and cust_lvl = @cust_lvl@ ] 
    }
