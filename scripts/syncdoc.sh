#!/bin/bash
#!-*- sh -*-
# 
# Abs: syncdoc.sh is a bash source script to upload the documentation of an 
#      EPICS V4 release to the SourceForge site
#
# Usage: 
#
#      For examples see Usage function below.
#  
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 25-Oct-2013, Dave Hickin
# ============================================================================

thisscript=$( basename "$0" )

function usage { 
echo "
   $0 uploads the documentation of an EPICS V4 release to SourceForge.
   The upload location is based on the version number supplied with the -v.
   flag. The user must supply his SourceForge user name with the -u flag.
   
   The modules whose documentation are to be uploaded are supplied as
   arguments. Alternatively with the -a flag all modules in the current
   directory can be uploaded.
   
   The modules should have a subdirectory called documentation to be uploaded.

   Usage:
       $thisscript -h
       $thisscript -v <versionNumber> -u <SFusername> [modules]
       $thisscript -v <versionNumber> -u <SFusername> -a
       
       -v <versionNumber>    The version number of the release e.g. 4.3.0

       -u <SFusername>       The argument SFusername is the SourceForge
                             username to be used cloning the repos.
							 
       -h                    Help


   Examples:

         \$ $thisscript  -v 4.3.0 -u dhickin
         \$ $thisscript  -v 4.3.0 -u dhickin pvDataCPP pvAccessCPP pvaSrv
         \$ $thisscript  -v 4.3.0 -u dhickin pvDataJava pvAccessJava exampleJava
"
}


thisdir=${PWD}

function Exit {
    cd ${thisdir}
    exit $1
}

declare -a mods

SFusername=
versionName=
all=0

while getopts hu:v:a opt; do
   case "$opt" in
       h) usage; Exit 0 ;;
       u) SFusername=${OPTARG} ;;
       v) versionName=${OPTARG} ;;
       a) all=1 ;; 
       *) echo "Unknown Argument, see $thisscript -h"; Exit 1;;
   esac
done
shift $((OPTIND-1));


if [ -z ${versionName} ]; then
    echo "The version is a required argument, (specify with -v)"
    echo "See $thisscript -h"
    Exit 1
fi

releaseName="EPICS-CPP-${versionName}"

if [ -z ${SFusername} ]; then
	echo "Username is a required argument (specify with -u)."
    echo "See $thisscript -h"
    Exit 1
fi


if [ ${all} -eq 1 ]; then
    if [ $# -ne 0 ]; then
        echo "Module arguments invalid with -a option"
        Exit 1
    fi
    echo "checking all directories for documents"
    mods=(*)
else
    mods=("${@}")
    
    if [ $# -eq 0 ]; then
        echo "No modules specified"
        Exit 0
    else
        echo "checking modules $@ for documents..."
    fi
fi

for mod in "${mods[@]}"
do
    if [ ! -e "${mod}" ]; then
        echo "${mod} doesn't exist"
        continue
    fi

    if [ ! -d "${mod}" ];then
        if [ "${all}" -eq 0 ]; then
            echo "${mod} is not a directory"
        fi
        continue
    fi
    
    moddoc="${mod}"/documentation
    
    if [ ! -d "${moddoc}" ]; then
        echo "No documentation dir in ${mod}"
        continue		
    fi

    echo "rsync ${mod} ${versionName}"
    
    rsync -az ${moddoc} ${SFusername},epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/${mod}/${versionName}
    
    err_code=$?
    
    echo ${err_code}
    
    if [ ${err_code} -ne 0 ]; then
        echo "rsync failed. Try adding the directory and doing it again."
         rsync --dirs ${mod} ${SFusername},epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/
         rsync -az ${moddoc} ${SFusername},epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/${mod}/${versionName}
    fi
    
    
done

Exit 0
