##START#########################################################################
#
# $URL: https://athena.redprairie.com/svn/prod/env/trunk/config/Config.mk.linux $
# $Revision: 51112 $
# $Author: mlange $
#
# Description: Configure makefile for an LES environment.
#
# $Copyright-Start$
#
# Copyright (c) 1999-2007
# RedPrairie Corporation
# All Rights Reserved
#
# This software is furnished under a corporate license for use on a
# single computer system and can be copied (with inclusion of the
# above copyright) only for use on such a system.
#
# The information in this document is subject to change without notice
# and should not be construed as a commitment by RedPrairie Corporation.
#
# RedPrairie Corporation assumes no responsibility for the use of the
# software described in this document on equipment which has not been
# supplied or approved by RedPrairie Corporation.
#
# $Copyright-End$
#
##END###########################################################################

CC         = gcc
LD         = ld
WARN       =
DEFINES    =
OPTIONS    = -m64 -fPIC
LIBOPTS    = -ldl -lrt
LDOPTS     =
SHLDOPTS   = -shared -E -lrt
SHLIBEXT   = .so

RANLIB = ranlib

