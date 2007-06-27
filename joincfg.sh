#! /bin/sh
#
# %A%: concatenate configure.sh and configure.inc into configure.sh
#

for req in configure.sh configure.inc; do
    if [ ! -r $req ]; then
	echo "$0: where is ${req}?" 1>&2
	exit 1
    fi
done

trap "rm -f $$;exit 0" 1 2 3 9 15

while IFS= read line;do
    case "$line" in
    ". "[^ ]*"/configure.inc"*) echo "# #### configure.inc ####"
				grep -v '^#' configure.inc
				echo "# #### configure.sh ####"
				;;
    *)                          echo "$line"
				;;
    esac
done < configure.sh > $$

if test -s $$; then
    # blow away all the old configure files plus joincfg
    rm -f configure.inc configure.sh joincfg.sh
    mv -f $$ configure.sh
    chmod a=rx configure.sh
else
    echo "$0: can't write new configure.sh" 1>&2
    exit 1
fi
exit 0
