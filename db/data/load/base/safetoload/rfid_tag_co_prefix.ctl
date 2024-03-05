[ select count(*) row_count 
    from rfid_tag_co_prefix 
   where co_prefix_index = '@co_prefix_index@'
] 

| 
    if (@row_count > 0) 
    {
       [ update rfid_tag_co_prefix 
           set
	     co_prefix_index = '@co_prefix_index@',          
	     co_prefix = '@co_prefix@',        
	     grp_nam = '@grp_nam@'
           where co_prefix_index = '@co_prefix_index@'
       ] 
    }
    else 
    { 
       [ insert into rfid_tag_co_prefix
               (co_prefix_index, co_prefix, grp_nam)
            VALUES
               ('@co_prefix_index@', '@co_prefix@', '@grp_nam@') 
       ] 
    }
