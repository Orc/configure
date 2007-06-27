#! /bin/sh
#
# %Z% %M% %E%: merge configure.sh and
# configure.inc into a single configure.sh
#

for req in configure.sh configure.inc; do
    if [ ! -r $req ]; then
	echo "$0: where is ${req}?" 1>&2
	exit 1
    fi
done

trap "rm -f $$;exit 0" 1 2 3 9 15

awk ' /^\. +([^ ]*\/)?configure.inc/ {  print "# #### configure.inc ####";
					system("cat configure.inc");
					print "# #### configure.sh #####";
					next; }
				      { print; }' < configure.sh > $$
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
