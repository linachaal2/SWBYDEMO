[ select count(*) row_count from velocity_type
	where velocity_type = '@velocity_type@'] 
| 
if (@row_count = 0) 
{
[ insert into velocity_type (velocity_type)
  VALUES ('@velocity_type@')]
}
