[ select count(*) row_count from les_dbversion ] | 
if (@row_count > 0)
{ 
    [ update les_dbversion set version = '@version@' ]
}
else
{
    [ insert into les_dbversion (version) values ('@version@') ]
}
