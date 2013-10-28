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
thisscript=$( basename "$0" )

function usage { 
echo "
   docReleaseJava.sh is a bash source script to manage the generation of the
   jdocumentation for a version tagged release of the Java implementation of
   EPICS v4. 

   Usage:

       docReleaseJava.sh -n <releaseName> [-r <SFusername>]

       -n <releaseName>   The string identifying the release. This is the key used to
                          search RELEASE_VERSIONS to find the modules in the release

       -r <SFusername>    Use remote files. The argument SFusername is the SourceForge
                          username to be used for upload.
 

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
http://hg.code.sf.net/p/epics-pvdata/pvDataWWW/raw-file/tip/scripts/RELEASE_VERSIONS

SFusername=
releaseName= 
force=0

if [ $# -lt 1 ]; then
   echo "Not enough arguments, at least the -n releaseName must be given. " \
        "See makereleaseJars.sh -h for help";
   exit 1;
fi
while getopts hr:fn: opt; do
   case "$opt" in
       h) usage; exit 0 ;;
       r) SFusername=${OPTARG} ;;
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

outdir=${releaseName}

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

# Create the directory containing the sources. 
#
mkdir -p ${outdir}
cd ${outdir}

for modulei in ${modulesa[@]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          'BEGIN {relname="^" relname "$"} $1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -eq 0 ]; then
        docjar=${modulei}-${tag}-javadoc.jar
        srcjar=${modulei}-${tag}-sources.jar

        echo Adding ${modulei} ${tag} to ${releaseName} tar directory 
        set -x
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${docjar}
        if [ $? -ne 0 ]; then
	        echo "wget failed."
        fi
        
        set +x
        
        sfv4=hg.code.sf.net/p/epics-pvdata
        if [ -z ${SFusername} ]; then
            urlbase=http://${sfv4}
        else
            urlbase=ssh://${SFusername}@${sfv4}           
        fi
        
        checkoutname=${modulei}       
        hg clone -u ${tag} ${urlbase}/${modulei} ${checkoutname}
        
        if [ $? -eq 0 ]; then
            # update separately. "hg clone -u <tag>" does not return an error status
            # for a non existent tag! 
            cd ${checkoutname}
            hg update -r ${tag}
            if [ $? -ne 0 ]; then
	            echo "hg update failed."
	            exit 5
            fi
            cd ..     
        fi

        if [ ! -d ${modulei}/documentation ]; then
            echo "No documentation dir"
            missing_hgdoc=( ${missing_hgdoc} ${modulei} )
            rm -rf ${checkoutname}                 
        fi
        
        if [ -e  ${docjar}  ]; then
            htmldir=${modulei}/documentation/html
            mkdir -p ${htmldir}
            mv ${docjar} ${htmldir}
            pushd ${htmldir}       
            jar xf ${docjar}
            popd
            mv ${htmldir}/${docjar} .
        else
            missing_hgdoc=( ${missing_hgdoc} ${modulei} )
        fi 
    else
	    echo "Could not get module version for ${modulei}, exiting"
	    exit 3
    fi
    echo "${modulei} complete"
done

    echo "modules complete"

cd ..

echo "Missing hg documentation: ${missing_hgdoc}"
echo "Missing javadoc: ${missing_html}"

exit 0
