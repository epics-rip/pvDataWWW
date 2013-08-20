#!/bin/bash
#!-*- sh -*-
# 
#      makereleaseJars is a bash source script to manage the release of jar files and 
#      associated deliverables for a version tagged release of the Java implementation 
#      of EPICS v4. 
#
# Usage:     
#      ./makereleaseCPP.sh -n <releaseName> [-l <hgrepodirname>] [-r <SFusername>]  
# 
#      Following a tagged release of ALL of the V4 core pv*Java modules (pvDataJava, pvAccessJava etc),
#      as described in release.html, hg checkout pvDataWWW. Edit pvDataWWW/configure/RELEASE_VERSIONS 
#      to define the modules of the release and their Mercurial (hg) tags. 
#
#      NOTE that 
#      ** formally, the release is defined by specification of a set of module names and 
#      specifically their Source Version Control System (VCS) (Mercurial in our present case) 
#      tag values. Therefore, for Java, the maven products and maven versions MUST be
#      identical. This script actually packages the jar files in 
#      the maven repo, it does not package from the hg repo directly!
#
#      For examples see Usage function below.
#
#      A user should unpack the resulting tar.gz with, for instance:
#            tar zxvf EPICSv4-Java-1.0-BETA.tar.gz
#
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 20-Dec-2011, Greg White (greg@slac.stanford.edu) 
# Mod:  19-Aug-2013, Greg White (greg@slac.stanford.edu)
#       Re-write for supporting file driven release packaging.
#       11-Jan-2013, Greg White (greg@slac.stanford.edu)
#       Updated TAG so as to build first beta 2 release. Also, removed references to pvService.
#       
# ============================================================================

function usage { 
echo "
   makereleaseCPP.sh creates the tar file of the CPP modules collection of 
   an EPICS V4 release. 

   Usage:

       makereleaseCPP.sh -n <releaseName> -r <SFusername> [-V <version_filename>] 

       -n <releaseName>   The string identifying the release. This is the key used to
                          search RELEASE_VERSIONS to find the modules in the release

       -r <SFusername>    Use remote files. The argument SFusername is the SourceForge
                          username to be used for upload.

       -t                 Checked modules are named with tag as well as module name.

       -T                 Checked modules are named with module name only (default).


       NOTE: Use of -t and -T are mutually exclusive.  

       NOTE: The versions in RELEASE_VERSIONS, MUST not be SNAPSHOT versions. That is
       contrary to release policy, and the script won't work in the expected way anyway
       because maven snapshots have timestamps in their name,not recogized by this script.

   Example:

       Package from remote files example:

         $ makereleaseCPP.sh -n EPICS-CPP-4.3.0-pre1 -r dhickin

       In this example, makereleaseCPP.sh packaged the jar files for a release named
       EPICS-CPP-4.3.0-pre1, as specified in the RELEASE_VERSIONS file it finds on the
       web (see URL in source of this script).
       It will first download the files it finds in the maven repo at 
       http://epics.sourceforge.net/maven2/epics/, and package them into a tar file.

"
}

declare -a modulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release.
RELEASE_VERSIONS_URL=\
http://sourceforge.net/p/epics-pvdata/pvDataWWW/ci/default/tree/scripts/RELEASE_VERSIONS

SFusername=
releaseName= 
localversionsfile=0
remotefiles=0
namemoduleswithtag=0

if [ $# -lt 1 ]; then
   echo "Not enough arguments, at least the -n releaseName must be given. " \
        "See makereleaseCPP.sh -h for help";
   exit 1;
fi

while getopts htTr:V:n: opt; do
   case "$opt" in
       h) usage; exit 0 ;;
       t) namemoduleswithtag=1 ;;
       T) namemoduleswithtag=0 ;;
       r) remotefiles=1 
          SFusername=${OPTARG} ;;
       V) localversionsfile=1
          localversionsfilename=${OPTARG} ;;
       n) releaseName=${OPTARG} ;; 
       *) echo "Unknown Argument, see makereleaseCPP.sh -h"; exit 1;;
   esac
done
shift $((OPTIND-1));

if [ -z ${releaseName} ]; then
    echo "The release name is a required argument, see makereleaseCPP.sh -h"
    exit 1
fi

outdir=${releaseName}
tarfile="${releaseName}.tar.gz"

# Check the directory whose contents we'll tar doesn't already exist
if [ -e ${outdir} ]; then
	echo "${outdir} already exists. Remove/move before trying again."
    exit 5
fi

# Locate the RELEASE_VERSIONS file, to tell use which modules must be in the release
# build, and from it find out which modules are in the release. Check we got at 
# least 1 module.
#
if [ ${localversionsfile} -eq 1 ]; then
    release_versions_pathname=${localversionsfilename}
else
    wget ${RELEASE_VERSIONS_URL}
    release_versions_pathname=${PWD}/RELEASE_VERSIONS 
fi


if [ ! -f ${release_versions_pathname} ]; then
    echo "Failed to locate or use the RELEASE_VERSIONS file."
    exit 2
fi

file=$release_versions_pathname
release_versions_pathname=$( readlink -f "$( dirname "$file" )" )/$( basename "$file" )

# Read the repos and versions that the release tar must be composed of, from the
# RELEASE_VERSIONS file.
modulesa=(`awk -v relname=${releaseName} '$1 ~ relname {print $2}' < $release_versions_pathname`)
if [ ${#modulesa[@]} -lt 1 ]; then
    echo "Failed to find modules for release ${releaseName}"
    exit 2
fi
echo ${releaseName} is composed of ${modulesa[*]}


# Create the directory, and populate it. 
#
mkdir -p ${outdir}
cd ${outdir}


for modulei in ${modulesa[*]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          '$1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -ne 0 ]; then
	    echo "Could not get module version for ${modulei}, exiting"
	    exit 3
    fi


    if [ $? -eq 0 ]; then
        echo Adding ${modulei} ${tag} to ${releaseName} tar directory
        if [ ${remotefiles} -ne 1 ]; then
	        echo "remote  implemented"
            exit 4
        fi

        if [ ${namemoduleswithtag} -eq 1 ]; then
            checkoutname=${modulei}-${tag}
        else
            checkoutname=${modulei}
        fi
        hg clone -u ${tag} ssh://${SFusername}@hg.code.sf.net/p/epics-pvdata/${modulei} ${checkoutname}
    else
	    echo "Could not get module version for ${modulei}, exiting"
	exit 3
    fi
done

cd ..

echo Tarring  $outdir to $tarfile
tar czf $tarfile $outdir

exit 0
