static char RCS_Id[] = "$Id$";
/*#START***********************************************************************
 *
 *  $URL$
 *  $Revision$
 *  $Author$
 *
 *  Description: Sample hello world component.
 *
 *  $McHugh_Copyright-Start$
 *
 *  Copyright (c) 1999
 *  McHugh Software International
 *  All Rights Reserved
 *
 *  This software is furnished under a corporate license for use on a
 *  single computer system and can be copied (with inclusion of the
 *  above copyright) only for use on such a system.
 *
 *  The information in this document is subject to change without notice
 *  and should not be construed as a commitment by McHugh Software
 *  International.
 *
 *  McHugh Software International assumes no responsibility for the use of
 *  the software described in this document on equipment which has not been
 *  supplied or approved by McHugh Software International.
 *
 *  $McHugh_Copyright-End$
 *
 *#END************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <moca.h>
#include <mocaerr.h>
#include <common.h>
#include <srvlib.h>

#define STRING	"Hello, world"


/*
 *  FUNCTION: projHelloWorld
 *
 *  PURPOSE:  Sample function to populate a return structure
 *            with a simple "Hello, world" string.
 */

RETURN_STRUCT *projHelloWorld(void)
{
    RETURN_STRUCT *result;

    /* Initialize the return structure. */
    result = NULL;

    /* Populate the return structure. */
    if ((result = srvResults(eOK,
			     "string", COMTYP_STRING, strlen(STRING), STRING,
			     NULL)) == NULL)
    {
	srvFreeMemory(SRVRET_STRUCT, result);
	result = srvResults(eERROR, NULL);
    }

    return(result);
}
