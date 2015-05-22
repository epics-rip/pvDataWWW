#!/bin/bash
#!-*- sh -*-
# 
#      docReleaseCPP is a bash source script to manage the generation of the
#      doxygen for a version tagged release of the CPP implementation of
#      EPICS v4. 
#
# Usage:     
#      ./docReleaseCPP.sh -v <releaseNumber> [-f] [-s]
# 
#      Once all of the V4 core C++ modules have been tagged
#      (pvDataCPP, pvAccessCPP etc), as described in release.html,
#      hg checkout pvDataWWW. Edit pvDataWWW/configure/RELEASE_VERSIONS 
#      to define the modules of the release and their revision IDs.
#
#      For examples see Usage function below.
#
#      A user should unpack the resulting tar.gz with, for instance:
#            tar zxvf EPICS-CPP-4.3.0.doc.tar.gz
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
set -e -x

function usage { 
echo "
   docReleaseCPP.sh creates the tar file of the CPP modules, together with
   other relevant files, of an EPICS V4 release. 

   Usage:

       docReleaseCPP.sh -n <releaseName> [-f ] [-l] 

       -n <releaseName>      The string identifying the release. This is the
                             key used to search RELEASE_VERSIONS to find the
                             modules in the release.

       -l                    Uses the specified release versions file
                             RELEASE_VERSIONS in the pvDataWWW/scripts dir
                             of the copy of pvDataWWW  which contains the
                             version of this script which has been run.

       -o <outdir>           Output directory

       -f                    Removes any files left from running the script
                             previously.

   Examples:

         $ docReleaseCPP.sh -l -n EPICS-CPP-4.3.0 -r dhickin

       In this example, docReleaseCPP.sh generates the documentation for
       version 4.3.0 as specified in the RELEASE_VERSIONS file in the 
       copy of pvDataWWW which contains the version of this script which has
       been executed.
       It will first clone the files it finds in the mercurial repo, build them
       and generate the doxygen.

         $ docReleaseCPP.sh  -n EPICS-CPP-4.3.0 -r dhickin

       This time docReleaseCPP.sh does the same thing but using the the
       RELEASE_VERSIONS file it finds on the web (see URL in source of this
       script).

         $ docReleaseCPP.sh  -n EPICS-CPP-4.3.0

       Same but uses anonymous http access.

       To build the script assumes that the modules are listed from least
       derived to most derived in the RELEASE_VERSIONS file
"
}

function Exit {
    exit $1
}

echo "EPICS_BASE is $EPICS_BASE"

if [ -z ${EPICS_BASE} ]; then
    echo "EPICS_BASE is needed"
    Exit 2
fi

declare -a modulesa
declare -a buildmodulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release.
RELEASE_VERSIONS_URL=\
https://raw.githubusercontent.com/epics-base/pvDataWWW/default/scripts/RELEASE_VERSIONS


file=$0
scriptdir=$( readlink -f "$( dirname "${file}" )" )


releaseName= 
localreleaseinfo=0
force=0

while getopts hfu:ln: opt; do
   case "$opt" in
       h) usage; Exit 0 ;;
       f) force=1 ;;
       l) localreleaseinfo=1 ;;
       o) outdir="${OPTARG}" ;;
       n) releaseName=${OPTARG} ;; 
       *) echo "Unknown Argument, see $0 -h"; Exit 1;;
   esac
done
shift $((OPTIND-1));

if [ -z ${releaseName} ]; then
    echo "The release name is a required argument, see makereleaseJars.sh -h"
    exit 1
fi

[ "${outdir}" ] || outdir="${PWD}/${releaseName}"
tarfile="${releaseName}.doc.tar.gz"

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


workdir=`mktemp -d`

# automatic cleanup of temp working dir
trap "rm -rf ${workdir};echo cleanup ${workdir}" INT QUIT TERM EXIT

install -d "${workdir}/tar"
install -d "${workdir}/build"
install -d "${workdir}/download" && cd "${workdir}/download"


# Locate the RELEASE_VERSIONS file, to tell which modules are in the release
#
if [ ${localreleaseinfo} -eq 1 ]; then
    release_versions_pathname=${scriptdir}/RELEASE_VERSIONS
else
    # Get the remote version file.
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


for modulei in ${modulesa[@]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          'BEGIN {relname="^" relname "$"} $1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -ne 0 ]; then
	    echo "Could not get module version for ${modulei}, exiting"
	    Exit 9
    fi

    echo "Fetch ${modulei} ${tag}"

    install -d "${workdir}/build/${modulei}"
    # clone module from sourceforge
    curl "https://codeload.github.com/epics-base/${modulei}/tar.gz/${tag}" \
    | tar -C "${workdir}/build/${modulei}" --strip-components=1 -xz
done

reversed_modules=( )

for modulei in ${modulesa[*]}
do
   reversed_modules=( "${reversed_modules[@]}" "${modulei}" )
done

for modulei in ${reversed_modules[@]}
do
    if [ -e ${modulei} ]; then
        echo "${modulei}=${workdir}/build/${modulei}" >> "${workdir}/build/RELEASE.local"
    fi    
done

echo "EPICS_BASE=$EPICS_BASE" >> "${workdir}/build/RELEASE.local"

echo "CROSS_COMPILER_TARGET_ARCHS=" > "${workdir}/build/CONFIG.local"

skipped=( )

for modulei in ${modulesa[@]}
do
if [ -e ${workdir}/build/${modulei}/Makefile -a -e ${workdir}/build/${modulei}/Doxyfile ]; then
    ( cd ${workdir}/build/${modulei} && \
	make inc && \
	doxygen)
	install -d "${workdir}/tar/${modulei}/documentation"
	tar -C "${workdir}/build/${modulei}" --exclude='O.*' -c '.' \
	| tar -C "${workdir}/tar/${modulei}" -x
else
    echo "=== Skip ${modulei}"
    ls -1 "${workdir}/build/${modulei}"
    skipped=("${skipped[@]}" "${modulei}" )
fi
done

echo "Tarring  ${workdir}/tar to ${outdir}/${tarfile}"
install -d "${outdir}"
tar -C "${workdir}/tar" -czf "${outdir}/${tarfile}" '.'


echo "No documentation for modules: ${skipped[@]}"


Exit 0

