#!/bin/bash
#!-*- sh -*-
# 
#      docReleaseJava.sh is a bash source script to manage the generation of the
#      javadoc for a version tagged release of the Java implementation of
#      EPICS v4. 
#
# Usage:     
#      ./docReleaseJava.sh -n <releaseName> [-l <hgrepodirname>] [-r <SFusername>]
# 
#      Once all of the V4 core Java modules have been tagged
#      (pvDataJava, pvAccessJava etc), as described in release.html,
#      hg checkout pvDataWWW. Edit pvDataWWW/configure/RELEASE_VERSIONS 
#      to define the modules of the release and their Mercurial (hg) tags. 
#
#      For examples see Usage function below.
#
#
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
#
# Auth: Dave Hickin
#
#       
# ============================================================================
set -e -x

function usage { 
echo "
   docReleaseJava.sh is a bash source script to manage the generation of the
   jdocumentation for a version tagged release of the Java implementation of
   EPICS v4. 

   Usage:

       docReleaseJava.sh -n <releaseName> [-r <SFusername>]

       -n <releaseName>   The string identifying the release. This is the key used to
                          search RELEASE_VERSIONS to find the modules in the release
 
       -o <outdir>           Output directory

       NOTE: The versions in RELEASE_VERSIONS, MUST not be SNAPSHOT versions. That is
       contrary to release policy, and the script won't work in the expected way anyway
       because maven snapshots have timestamps in their name,not recognized by this script.

   Example:

         $ docReleaseJava.sh -n EPICS-Java-4.3.0 -r gregorywhite 
"
}

declare -a modulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release, and the README.
RELEASE_VERSIONS_URL=\
https://raw.githubusercontent.com/epics-base/pvDataWWW/default/scripts/RELEASE_VERSIONS

SFusername=
releaseName= 
force=0

while getopts hr:fn: opt; do
   case "$opt" in
       h) usage; exit 0 ;;
       o) outdir="${OPTARG}" ;;
       f) force=1 ;;
       n) releaseName=${OPTARG} ;; 
       *) echo "Unknown Argument, see makereleaseJars.sh -h"; exit 1;;
   esac
done
shift $((OPTIND-1));

if [ -z ${releaseName} ]; then
    echo "The release name is a required argument, see makereleaseJars.sh -h"
    exit 1
fi

[ "${outdir}" ] || outdir="${PWD}/${releaseName}"
tarfile="${releaseName}.doc.tar.gz"

workdir=`mktemp -d`

# automatic cleanup of temp working dir
trap "rm -rf ${workdir};echo cleanup ${workdir}" INT QUIT TERM EXIT

install -d "${workdir}/tar"
install -d "${workdir}/download" && cd "${workdir}/download"

# Locate the RELEASE_VERSIONS file, to tell use which modules must be in the release
# build, and from it find out which modules are in the release. Check we got at 
# least 1 module.
#
release_versions_pathname=${PWD}/RELEASE_VERSIONS
rm -rf ${release_versions_pathname}
wget ${RELEASE_VERSIONS_URL}

if [ ! -f ${release_versions_pathname} ]; then
    echo "Failed to locate or use the RELEASE_VERSIONS file."
    exit 2
fi
# Construct fully qualified pathname of RELEASE_VERSIONS
file=$release_versions_pathname
release_versions_pathname=$( readlink -f "$( dirname "$file" )" )/$( basename "$file" )


# Read the repos and versions that the release tar must be composed of, from the
# RELEASE_VERSIONS file.
modulesa=(`awk -v relname=${releaseName} 'BEGIN {relname="^" relname "$"} $1 ~ relname {print $2}' < $release_versions_pathname`)
if [ ${#modulesa[@]} -lt 1 ]; then
    echo "Failed to find modules for release ${releaseName}"
    exit 2
fi
echo ${releaseName} is composed of ${modulesa[*]}


# Check the directory for the documentation doesn't already exist
if [ -e ${outdir} ]; then
    if [ ${force} -eq 1 ]; then
        rm -rf ${outdir}
    else
	    echo "${outdir} already exists. Remove/move before trying again or use
the force option (-f)."
        exit 4
    fi
fi

missing_html=
missing_hgdoc=

for modulei in ${modulesa[@]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          'BEGIN {relname="^" relname "$"} $1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -eq 0 ]; then
        docjar=${modulei}-${tag}-javadoc.jar
        #srcjar=${modulei}-${tag}-sources.jar

        echo Adding ${modulei} ${tag} to ${releaseName} tar directory 
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${docjar} || echo "wget failed."

        install -d "${workdir}/tar/${modulei}"
        curl "https://codeload.github.com/epics-base/${modulei}/tar.gz/${tag}" \
        | tar -C "${workdir}/tar/${modulei}" --strip-components=1 -xz || echo "failed to fetch source"

        if [ ! -d ${workdir}/tar/${modulei}/documentation ]; then
            echo "No documentation dir"
            missing_hgdoc=( ${missing_hgdoc} ${modulei} )
        fi
        
        if [ -e  ${docjar}  ]; then
            htmldir=${workdir}/tar/${modulei}/documentation/html
            install -d ${htmldir}
            (cd "$htmldir" && jar xf "${workdir}/download/${docjar}")
        else
            missing_hgdoc=( ${missing_hgdoc} ${modulei} )
        fi 

    else
	    echo "Could not get module version for ${modulei}, exiting"
	    exit 3
    fi
    echo "${modulei} complete"
done


echo "Tarring  ${workdir}/tar to ${outdir}/${tarfile}"
install -d "${outdir}"
tar -C "${workdir}/tar" -czf "${outdir}/${tarfile}" '.'

echo "No documentation for modules: ${skipped[@]}"

echo "Missing hg documentation: ${missing_hgdoc}"
echo "Missing javadoc: ${missing_html}"

exit 0
