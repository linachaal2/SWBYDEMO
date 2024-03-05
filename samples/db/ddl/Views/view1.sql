#include <../../../include/usrddl.h>
#include <../../../include/varddl.h>
#include <sqlDataTypes.h>

#ifndef ORACLE
DELETE_VIEW(view1)
RUN_SQL
#endif

CREATE_VIEW(view1)
select column1
from   table1
where  column1 > 1
RUN_SQL
