#!/bin/bash

thisscript=$( basename "$0" )

function usage { 
echo "
   "${thisscript}" creates an interactive secure shell session for
   the SourceForge EPICS V4 project  

   Usage:

       "${thisscript}" -u <SFusername>

       -u <SFusername>       The argument SFusername is the SourceForge
                             username to be used cloning the repos.
"
}

while getopts hfsu:lv: opt; do
   case "$opt" in
       h) usage; Exit 0 ;;
       u) SFusername=${OPTARG} ;;
       *) echo "Unknown Argument, see $thisscript -h"; exit 1;;
   esac
done
shift $((OPTIND-1));

if [ -z ${SFusername} ]; then
	echo "Username is a required argument (specify with -u)."
    echo "See $thisscript -h"
    exit 1
fi

ssh -t "${SFusername}",epics-pvdata@shell.sourceforge.net create
