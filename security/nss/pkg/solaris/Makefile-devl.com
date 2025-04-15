#
# Copyright 2004 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
#ident	"$Id: Makefile-devl.com,v 1.1.8.1 2004/10/15 21:13:58 wchang0222%aol.com Exp $"
#

MACH = $(shell mach)

PUBLISH_ROOT = $(DIST)
ifeq ($(CORE_DEPTH),../../..)
ROOT = ROOT
else
ROOT = $(subst ../../../,,$(CORE_DEPTH))/ROOT
endif

PKGARCHIVE = $(PUBLISH_ROOT)/pkgarchive
DATAFILES = copyright
FILES = $(DATAFILES) pkginfo


PACKAGE = $(shell basename `pwd`)

PRODUCT_VERSION = $(shell grep NSS_VERSION $(CORE_DEPTH)/nss/lib/nss/nss.h    | sed -e 's/"$$//' -e 's/.*"//' -e 's/ .*//')

LN = /usr/bin/ln

CLOBBERFILES = $(FILES)

include $(CORE_DEPTH)/coreconf/config.mk
include $(CORE_DEPTH)/coreconf/rules.mk

# vim: ft=make
