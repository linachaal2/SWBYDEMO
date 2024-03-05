[ select count(*) row_count 
    from worktype_actcod 
   where worktype_id = '@worktype_id@'
     and actcod = '@actcod@'] 
| 
if (@row_count > 0)
{
    [ update worktype_actcod 
         set oprcod = '@oprcod@', 
             indflg = '@indflg@'
       where worktype_id= '@worktype_id@' 
         and actcod = '@actcod@']
}
else
{
    [ insert
        into worktype_actcod  (worktype_id,actcod,oprcod,indflg)
      VALUES ('@worktype_id@','@actcod@','@oprcod@','@indflg@') ]
}
