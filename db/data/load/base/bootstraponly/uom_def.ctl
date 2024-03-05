[ select count(*) row_count 
    from uom_def
   where mu_sys = '@mu_sys@'
   and mu_cat = '@mu_cat@'  
] 
| 
if (@row_count > 0) 
{
    [ 
	update uom_def 
         set mu = '@mu@'                    
        where mu_sys = '@mu_sys@'
   	      and mu_cat = '@mu_cat@'  
     ]
}
else 
{ 
    [ insert into uom_def 
         (mu_sys, mu_cat, mu )
        VALUES
          ('@mu_sys@','@mu_cat@', '@mu@') 
    ] 
}
