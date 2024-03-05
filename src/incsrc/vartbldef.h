/*#START***********************************************************************
 *
 *  $URL$
 *  $Revision$
 *  $Author$
 *
 *  Description: VAR-level tablespace definitions.
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

/*
 *  The VAR's tablespace definition file can be use to override
 *  the default tablespaces that a table will be created in.
 *
 *  The tablespace a table is created in is determined by using the
 *  tablespace macro as it's defined in the tablespace definition files
 *  using the following order of precedence:
 *
 *      1 - usrtbldef.h
 *      2 - vartbldef.h
 *      3 - <prod>tbldef.h
 *
 *  To use the database user's default tablespace for all tables:
 *
 *      #define USE_DEFAULT_TABLESPACE
 *
 *  To remap a tablespace macro to a different tablespace name:
 *
 *      #ifndef MCS_TBS_DEFS
 *      #define MCS_TBS_DEFS
 *      #define MCS_DATA_TBS_01   MCS_D_01
 *      #define MCS_INDEX_TBS_01  MCS_X_01
 *      #endif
 */

#ifndef VARTBLDEF_H
#define VARTBLDEF_H

#endif


