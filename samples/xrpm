#! /bin/sh

. ./configure.inc

AC_INIT xrpm

if AC_CHECK_HEADERS basis/options.h; then
    if AC_CHECK_FUNCS x_getopt; then
	:
    else
	export AC_LIBS
	AC_LIBS="$AC_LIBS -lbasis"
	AC_CHECK_FUNCS x_getopt
    fi
fi
AC_CHECK_HEADERS errno.h
AC_CHECK_FUNCS	tell

AC_CHECK_FIELD utsname domainname sys/utsname.h

AC_OUTPUT Makefile
