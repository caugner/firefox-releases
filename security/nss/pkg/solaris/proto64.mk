#
# Copyright 2004 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
#ident  "$Id: proto64.mk,v 1.1.4.1 2004/10/15 22:22:19 wchang0222%aol.com Exp $"
#

ifeq ($(USE_64), 1)
  # Remove 64 tag
  sed_proto64='s/\#64\#//g'
else
  # Strip 64 lines
  sed_proto64='/\#64\#/d'
endif
