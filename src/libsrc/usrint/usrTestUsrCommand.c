static char RCS_Id[] = "$Id$";
/*#START***********************************************************************
 *
 *  $URL$
 *  $Revision$
 *  $Author$
 *
 *  Description: Simple component to test a user-level command.
 *
 *  $Copyright-Start$
 *
 *  Copyright (c) 1999 - 2009
 *  RedPrairie Corporation
 *  All Rights Reserved
 *
 *  This software is furnished under a corporate license for use on a
 *  single computer system and can be copied (with inclusion of the
 *  above copyright) only for use on such a system.
 *
 *  The information in this document is subject to change without notice
 *  and should not be construed as a commitment by RedPrairie Corporation.
 *
 *  RedPrairie Corporation assumes no responsibility for the use of the
 *  software described in this document on equipment which has not been
 *  supplied or approved by RedPrairie Corporation.
 *
 *  $Copyright-End$
 *
 *#END************************************************************************/

#include <moca.h>

#include <stdio.h>
#include <string.h>

#include <mocaerr.h>
#include <srvlib.h>

LIBEXPORT 
RETURN_STRUCT *usrTestUsrCommand(void)
{
    return srvResults(eOK, 
		      "Test USRint", COMTYP_CHAR, 10, "It works!",
		      NULL);
}
