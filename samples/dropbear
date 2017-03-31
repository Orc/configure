#! /bin/sh

# local options:  ac_help is the help message that describes them
# and LOCAL_AC_OPTIONS is the script that interprets them.  LOCAL_AC_OPTIONS
# is a script that's processed with eval, so you need to be very careful to
# make certain that what you quote is what you want to quote.

ac_help='--with-pam		Use pam for server authentication
--with-passwd		use passwd authentication (does not coexist with pam)
--without-zlib		Don'\''t use zlib compression'

LOCAL_AC_OPTIONS='
set=`locals $*`;
if [ "$set" ]; then
    eval $set
    shift 1
else
    ac_error=T;
fi'

locals() {
    K=`echo $1 | $AC_UPPERCASE`
    case "$K" in
    --WITHOUT-ZLIB|--WITHOUT_ZLIB)
	    echo DISABLE_ZLIB=T
	;;
    esac
}

# load in the configuration file
#
TARGET=dropbear
. ./configure.inc

AC_INIT $TARGET

AC_PROG_CC

CRYPTLIB=''
if [ "$WITH_PAM" ]; then
    if AC_LIBRARY pam_authenticate -lpam; then
	AC_DEFINE 'DROPBEAR_SVR_PAM_AUTH' '1'
    else
	AC_FAIL "--with-pam requires a pam library"
    fi
fi
if [ "$WITH_PASSWD" ]; then
    if [ "$WITH_PAM" ]; then
	AC_FAIL "cannot sensibly do both passwd & pam authentication"
    elif AC_LIBRARY crypt -lcrypt; then
	AC_DEFINE 'DROPBEAR_SVR_PASSWD_AUTH' '1'
	CRYPTLIB='-lcrypt'
    else
	AC_FAIL "--with-passwd requires a crypt() function"
    fi
fi

AC_SUB CRYPTLIB "$CRYPTLIB"

AC_SUB 'BUNDLED_LIBTOM' '1'
AC_DEFINE 'BUNDLED_LIBTOM' 1
AC_SUB 'EXEEXT' ''

if [ "$DISABLE_ZLIB" ]; then
    AC_DEFINE 'DISABLE_ZLIB' '1'
    AC_SUB 'DISABLE_ZLIB' '1'
elif ! AC_LIBRARY inflate -lz; then
    AC_FAIL "$TARGET needs zlib unless configured --without-zlib"
fi

AC_CHECK_HEADERS sys/uio.h
AC_CHECK_HEADERS netinet/tcp.h
AC_CHECK_HEADERS netinet/in_systm.h
if AC_CHECK_HEADERS netinet/in.h; then
    __hfile="sys/types.h sys/uio.h netinet/in.h"
    if AC_CHECK_HEADERS sys/socket.h $__arpah; then
	__hfile="$__hfile sys/socket.h"
    fi
    AC_CHECK_STRUCT sockaddr_storage $__hfile 
    AC_CHECK_STRUCT in6_addr $__hfile
    AC_CHECK_STRUCT sockaddr_in6 $__hfile
fi
AC_CHECK_HEADERS netdb.h && AC_CHECK_STRUCT addrinfo netdb.h
AC_CHECK_FUNCS basename
AC_CHECK_FUNCS clearenv
AC_CHECK_FUNCS freeaddrinfo
AC_CHECK_FUNCS getaddrinfo
AC_CHECK_FUNCS getnameinfo
AC_CHECK_FUNCS getpass
AC_CHECK_FUNCS getusershell
AC_CHECK_HEADERS inttypes.h
AC_CHECK_HEADERS stdint.h
AC_CHECK_HEADERS lastlog.h
AC_CHECK_HEADERS libgen.h
AC_CHECK_HEADERS libutil.h
AC_CHECK_HEADERS login.h
AC_CHECK_HEADERS paths.h
AC_CHECK_HEADERS pty.h
AC_CHECK_HEADERS shadow.h
AC_CHECK_FUNCS strlcat
AC_CHECK_FUNCS strlcpy
if AC_CHECK_HEADERS sys/types.h; then
    AC_CHECK_TYPE uint16_t sys/types.h
    AC_CHECK_TYPE uint32_t sys/types.h
    AC_CHECK_TYPE uint8_t sys/types.h
    AC_CHECK_TYPE u_int16_t sys/types.h
    AC_CHECK_TYPE u_int32_t sys/types.h
    AC_CHECK_TYPE u_int8_t sys/types.h
fi

# welcome to the horrible horrible land of utmp;
# check for login(), and if that doesn't exist
# check for utmpx, then a bunch of utmpx fields,
# and if that fails or if login() exists then
# check for utmp and a bunch of utmp fields, and
# if that fails maybe fall off the edge of the
# earth?
if AC_LIBRARY login -lutil; then
    # login implies utmp
    AC_CHECK_FUNCS logout
    DISABLE_UTMPX=1
fi

if [ ! "$DISABLE_UTMPX" ] && AC_CHECK_HEADERS utmpx.h; then
    AC_DEFINE DISABLE_UTMP 1
    for field in ut_host ut_syslen ut_type ut_id ut_addr ut_addr_v6 ut_time ut_tv; do
	AC_CHECK_FIELD  utmpx $field utmpx.h
    done
    AC_CHECK_FUNCS logwtmpx
elif [ ! "$DISABLE_UTMP" ] && AC_CHECK_HEADERS utmp.h; then
    AC_DEFINE DISABLE_UTMPX 1
    for field in ut_host ut_pid ut_type ut_tv ut_id ut_addr ut_addr_v6 ut_exit ut_time; do
	AC_CHECK_FIELD utmp $field sys/types.h utmp.h
    done
    AC_CHECK_FUNCS logwtmp
else
    AC_DEFINE DISABLE_UTMPX 1
    AC_DEFINE DISABLE_UTMP 1
fi

if AC_CHECK_FUNCS writev ; then
    # if we have writev, we need UIO_MAXIOV; if UIO_MAXIOV isn't defined
    # (or is defined behind a _KERNEL|KERNEL|LINUX_KERNEL|mAgIc_KeRnEl ifdef)
    # set it to the posix minimum of 16
    AC_WHATIS int UIO_MAXIOV sys/uio.h || AC_DEFINE 'UIO_MAXIOV' '16'
fi

AC_CHECK_HEADERS util.h
AC_LIBRARY openpty -lutil
AC_LIBRARY _getpty -lutil

if AC_CHECK_FUNCS explicit_bzero || AC_CHECK_FUNCS memset_s; then
    : Yay
elif [ "$IS_GCC" ]; then
    LOG "Whoops: kludging around the lack of an explicit_bzero()"
    AC_CC="$AC_CC -fno-builtin-memset"
    AC_DEFINE 'explicit_bzero(x,s)' 'memset(x,0,s)'
else
    LOG "Whoops: no explicit_bzero -- faking with two memset()s"
    AC_DEFINE 'explicit_bzero(x,s)' '(memset(x,-1,s),memset(x,0,s))'
fi


if AC_CHECK_HEADERS security/pam_appl.h; then
    __pamh=security/pam_appl.h
elif AC_CHECK_HEADERS pam/pam_appl.h; then
    __pamh=pam/pam_appl.h
fi

# Does our pam define PAM_FAIL_DELAY?
if [ "$__pamh" ]; then
    if AC_WHATIS int PAM_FAIL_DELAY $__pamh ; then
	LOG "PAM_FAIL_DELAY defined in $__pamh"
	AC_DEFINE 'HAVE_PAM_FAIL_DELAY' '1'
    fi
fi

AC_OUTPUT Makefile libtomcrypt/Makefile libtommath/Makefile
# localoptions.h is #included before config.h, so just symlink it
# to bring config.h forward in the inclusion heap.
ln -sf config.h localoptions.h
