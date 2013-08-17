#!/bin/bash
#!-*- sh -*-
# 
# Summary:     
#      ./makereleaseJars.sh -n <releaseName> [-l <hgrepodirname>] [-r <SFusername>]  
#
# Abstract: 
#      makereleaseJars is a bash source script to manage the release of jar files and 
#      associated deliverables for a version tagged release of the Java implementation 
#      of EPICS v4. 
#
# Usage: 
#      Following a tagged release of ALL of the V4 core pv*Java modules (pvDataJava, pvAccessJava etc),
#      as described in release.html, hg checkout pvDataWWW. Edit pvDataWWW/configure/RELEASE_VERSIONS 
#      to define the modules of the release and their Mercurial (hg) tags. Note that 
#      ** formally, the release is defined by specification of a set of module names and their 
#      hg tag values, although for Java, we assume that there will be maven products for those
#      tags at the time this script is run. This script actually packages the jar files in 
#      the maven repo, it does not package from the hg repo directly!
#
# Examples:
#
#      A user should unpack the resulting tar.gz with, for instance:
#            tar zxvf EPICSv4-Java-1.0-BETA.tar.gz
#
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 20-Dec-2011, Greg White (greg@slac.stanford.edu) 
# Mod:  11-Jan-2013, Greg White (greg@slac.stanford.edu)
#       Updated TAG so as to build first beta 2 release. Also, removed references to pvService.
#       07-Feb-2012, Greg White (greg@slac.stanford.edu)
#       Added bundling pvService, since that's no again required after stuff 
#       removed from pvData.
#       09-Jan-2011, Greg White (greg@slac.stanford.edu) 
#       Added creating a tar.gz, converted upload of exampleJava.jar to only 
#       including its source in the tar.gz (more useful than the jar for examples)
#       and also include the common dir in the tar.gz. 

# ============================================================================

function usage { 
echo "
   makereleaseJars.sh creates the tar file of the Java modules collection of 
   an EPICS V4 release. 

   Usage:

       makereleaseJars.sh -n <releaseName> [-l <hgrepodirname>] [-r <SFusername>]

       -n <releaseName>   The string identifying the release. This is the key used to
                          search RELEASE_VERSIONS to find the modules in the release

       -l <hgrepodirname> Use local files. A local RELEASE_VERSIONS file will be
                          sought in
                          ./<hgrepodirname>/pvDataWWW/scripts/RELEASE_VERSIONS, and
                          the local maven repository will be sought in
                          ~/.m2/repository/epics/. If -l is not given, the
                          SourceForge hosted files will be used.

       -r <SFusername>   Use remote files. The argument SFusername is the SourceForge
                         username to be used for upload.

       Note that use of -l and -r are mutually exclusive.  

   Example:
 
       $ hg/pvDataWWW/scripts/makereleaseJars.sh -n EPICS-Java-4.3.0-pre1 -l hg
     
       In this example, makereleaseJara.sh packaged the jar files for release named
       EPICS-Java-4.3.0-pre1, as specified in a RELEASE_VERSIONS file it must find in
       hg/pvDataWWW/scripts/RELEASE_VERSIONS. The command was executed from the parent
       of hg/ so that the tar file did not pollute any repos.
"
}

declare -a modulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release.
RELEASE_VERSIONS_URL=\
http://sourceforge.net/p/epics-pvdata/pvDataWWW/ci/default/tree/scripts/RELEASE_VERSIONS

SFusername=
releaseName=
localfiles=0
uploadtar=0
if [ $# -lt 1 ]; then
   echo "Not enough arguments, at least the -n releaseName must be given. " \
        "See makereleaseJars.sh -h for help";
   exit 1;
fi
while getopts hr:l:n: opt; do
   case "$opt" in
       h) usage; exit 0 ;;
       r) uploadtar=1 
          SFusername=${OPTARG} ;;
       l) localfiles=1
          hgrepodirname=${OPTARG} ;;
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
tarfile="${releaseName}.tar.gz"

# Locate the RELEASE_VERSIONS file, to tell use which modules must be in the release
# build, and from it find out which modules are in the release. Check we got at 
# least 1 module.
#
if [ ${localfiles} -eq 1 ]; then
    release_versions_pathname=${hgrepodirname}/pvDataWWW/scripts/RELEASE_VERSIONS
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

modulesa=(`awk -v relname=${releaseName} '$1 ~ relname {print $2}' < $release_versions_pathname`)
if [ ${#modulesa[@]} -lt 1 ]; then
    echo "Failed to find modules for release ${releaseName}"
    exit 2
fi
echo ${releaseName} is composed of ${modulesa[*]}

# Create the directory whose contents we'll tar, and populate it. 
#
mkdir -p ${outdir}
cd ${outdir}

for modulei in ${modulesa[*]}
do
    tag=`awk -v relname=${releaseName} -v modulename=${modulei} \
          '$1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -eq 0 ]; then

        # If no SourceForge user name was given, assume we're packaging from files 
        # in a local maven repository, and further assume it's in ~./m2/repository/
        #
        echo Adding ${modulei} ${tag} to ${releaseName} tar directory 
        if [ ${localfiles} -eq 1 ]; then
	    set -x
	    cp ~/.m2/repository/epics/${modulei}/${tag}/${modulei}-${tag}.jar .
	    cp ~/.m2/repository/epics/${modulei}/${tag}/${modulei}-${tag}.pom .
	    cp ~/.m2/repository/epics/${modulei}/${tag}/${modulei}-${tag}-sources.jar .
	    cp ~/.m2/repository/epics/${modulei}/${tag}/${modulei}-${tag}-javadoc.jar .
        else
            set -x
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${modulei}-${tag}.jar
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${modulei}-${tag}.pom
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${modulei}-${tag}-sources.jar
	    wget http://epics.sourceforge.net/maven2/epics/${modulei}/${tag}/${modulei}-${tag}-javadoc.jar
            wget http://epics-pvdata.sourceforge.net/README
        fi
        set +x
     else
	echo "Could not get module version for ${modulei}, exiting"
	exit 3
     fi
done

cd ..

echo Tarring  $outdir to $tarfile
tar czf $tarfile $outdir

# Needs work
# if [ ${uploadtar} -eq 1 ]; then
#    rsync -a * $SFusername,epics-pvdata@frs.sourceforge.net:/home/frs/project/e/ep/epics-pvdata/$tag
# fi

exit 0
