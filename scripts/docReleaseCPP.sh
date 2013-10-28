#!/bin/bash
#!-*- sh -*-
# 
#      docReleaseCPP is a bash source script to manage the generation of the
#      doxygen for a version tagged release of the CPP implementation of
#      EPICS v4. 
#
# Usage:     
#      ./docReleaseCPP.sh -v <releaseNumber> [-f] [-s] -u <SFusername>  
# 
#      Once all of the V4 core C++ modules have been tagged
#      (pvDataCPP, pvAccessCPP etc), as described in release.html,
#      hg checkout pvDataWWW. Edit pvDataWWW/configure/RELEASE_VERSIONS 
#      to define the modules of the release and their Mercurial (hg) tags. 
#
#      For examples see Usage function below.
#
#      A user should unpack the resulting tar.gz with, for instance:
#            tar zxvf EPICS-CPP-4.3.0.tar.gz
#
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
#
# Auth: Dave Hickin
# Mod: 22-Oct-2013, Greg White (greg@slac.stanford.edu) 
#       Fixed awk command for matching "full releases", eg EPICS-java-4.3.0 rather 
#       than those with suffix. The old one matched also suffix 
#       release lines, so modules could have been included twice.
#       
# ============================================================================

function usage { 
echo "
   docReleaseCPP.sh creates the tar file of the CPP modules, together with
   other relevant files, of an EPICS V4 release. 

   Usage:

       docReleaseCPP.sh -v <releaseName> -u <SFusername> [-f ] [-l] 

       -v <versionName>      The version number of the release. This is used
                             to create the key used to search RELEASE_VERSIONS
                             to find the modules in the release.

       -u <SFusername>       The argument SFusername is the SourceForge
                             username to be used cloning the repos.

       -l                    Uses the specified release versions file
                             RELEASE_VERSIONS in the pvDataWWW/scripts dir
                             in pvDataWWW/mainPage of the copy of pvDataWWW
                             which contains the version of this script which
                             has been run.

       -f                    Removes any files left from running the script
                             previously.

   Examples:

         $ docReleaseCPP.sh -l -v 4.3.0 -r dhickin

       In this example, docReleaseCPP.sh generates the documentation for
       version 4.3.0 as specified in the RELEASE_VERSIONS file in the 
       copy of pvDataWWW which contains the version of this script which has
       been executed.
       It will first clone the files it finds in the mercurial repo, build them
       and generate the doxygen.

         $ docReleaseCPP.sh  -v 4.3.0 -r dhickin

       This time docReleaseCPP.sh does the same thing but using the the
       RELEASE_VERSIONS file it finds on the web (see URL in source of this
       script).

"
}


thisdir=${PWD}

function Exit {
    cd ${thisdir}
    exit $1
}

thisscript=$0


echo "EPICS_BASE is $EPICS_BASE"
echo "EPICS_HOST_ARCH is $EPICS_HOST_ARCH"

if [ -z ${EPICS_BASE} ]; then
    echo "EPICS_BASE is needed"
    Exit 2
fi

declare -a modulesa
declare -a buildmodulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release.
RELEASE_VERSIONS_URL=\
http://hg.code.sf.net/p/epics-pvdata/pvDataWWW/raw-file/tip/scripts/RELEASE_VERSIONS


file=$0
scriptdir=$( readlink -f "$( dirname "${file}" )" )


SFusername=
versionName=
releaseName= 
localreleaseinfo=0
force=0

while getopts hfu:lv: opt; do
   case "$opt" in
       h) usage; Exit 0 ;;
       f) force=1 ;;
       u) SFusername=${OPTARG} ;;
       l) localreleaseinfo=1 ;;
       v) versionName=${OPTARG} ;; 
       *) echo "Unknown Argument, see $thisscript -h"; Exit 1;;
   esac
done
shift $((OPTIND-1));


if [ -z ${versionName} ]; then
    echo "The version is a required argument, (specify with -v)"
    echo "See $thisscript -h"
    Exit 2
fi

releaseName="EPICS-CPP-${versionName}"



if [ -z ${SFusername} ]; then
	echo "Username is a required argument (specify with -u)."
    echo "See $thisscript -h"
    Exit 3
fi


outdir=${releaseName}


# Check the directory whose contents we'll tar doesn't already exist
if [ -e ${outdir} ]; then
    if [ ${force} -eq 1 ]; then
        rm -rf ${outdir}
    else
	    echo "${outdir} already exists. Remove/move before trying again or use
the force option (-f)."
        Exit 4
    fi
fi




# Locate the RELEASE_VERSIONS file, to tell which modules are in the release
#
if [ ${localreleaseinfo} -eq 1 ]; then
    release_versions_pathname=${scriptdir}/RELEASE_VERSIONS
else
    # Get the remote version file.
    # Delete the existing file first if it's already there.
    if [ -e RELEASE_VERSIONS ]; then
        rm -rf RELEASE_VERSIONS
    fi
    wget ${RELEASE_VERSIONS_URL}
    release_versions_pathname=${PWD}/RELEASE_VERSIONS
fi

if [ ! -f ${release_versions_pathname} ]; then
    echo "Failed to locate the release versions file ${release_versions_pathname}"
    Exit 6
fi


# Construct fully qualified pathname of RELEASE_VERSIONS file
file=$release_versions_pathname
release_versions_pathname=$( readlink -f "$( dirname "$file" )" )/$( basename "$file" )


# Read the repos and versions that the release tar must be composed of from the
# RELEASE_VERSIONS file.
modulesa=(`awk -v relname=${releaseName} 'BEGIN {relname="^" relname "$"} $1 ~ relname {print $2}' < $release_versions_pathname`)


# Check we got at least 1 module.
if [ ${#modulesa[@]} -lt 1 ]; then
    echo "Failed to find modules for release ${releaseName}"
    Exit 8
fi

echo ${releaseName} is composed of ${modulesa[*]}


# Create the directory source and populate it. 
#
mkdir -p ${outdir}
cd ${outdir}

for modulei in ${modulesa[*]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          'BEGIN {relname="^" relname "$"} $1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -ne 0 ]; then
	    echo "Could not get module version for ${modulei}, exiting"
	    Exit 9
    fi

    echo Adding ${modulei} ${tag} to ${releaseName} tar directory

    # clone module from sourceforge
    checkoutname=${modulei}
    hg clone -u ${tag} ssh://${SFusername}@hg.code.sf.net/p/epics-pvdata/${modulei} ${checkoutname}
    if [ $? -ne 0 ]; then
	    echo "hg clone failed."
        Exit 10            
    fi

    # update separately. "hg clone -u <tag>" does not return an error status
    # for a non existent tag! 
    cd ${checkoutname}
    hg update -r ${tag}
    if [ $? -ne 0 ]; then
	    echo "hg update failed."
	    Exit 11
    fi

    echo "tags for ${modulei}:"
    hg id -t

    cd .. 

done

echo "CROSS_COMPILER_TARGET_ARCHS=" > CONFIG.local
echo "EPICS_BASE=$EPICS_BASE" > RELEASE.local_old


for modulei in ${modulesa[*]}
do
if [ -e ${modulei} ]; then
    cd ${modulei}
	top=${PWD}
	echo "${modulei}=$top" > ../RELEASE.local
	cd ..
	RELEASE.local_old >> RELEASE.local
	cp RELEASE.local RELEASE.local_old
fi    
done

for modulei in ${modulesa[*]}
do
if [ -e ${modulei} ]; then
    cd ${modulei}
    make clean uninstall
	make
	doxygen
	cd ..
fi
done

cd ..




Exit 0
