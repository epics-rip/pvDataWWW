#!/bin/bash
#!-*- sh -*-
# 
#      makereleaseJars is a bash source script to manage the release of jar files and 
#      associated deliverables for a version tagged release of the Java implementation 
#      of EPICS v4. 
#
# Usage:     
#      ./makereleaseJars.sh -n <releaseName> [-l <hgrepodirname>] [-r <SFusername>]  
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
# Mod:  25-Nov-2014, Greg White (greg@slac.stanford.edu)
#       Get caj and jca fom Maven central.
#       22-Oct-2013, Greg White (greg@slac.stanford.edu) 
#       Fixed awk command for matching "full releases", eg EPICS-java-4.3.0 rather than
#       those with suffix. The old one was a thirsty match, so matched also suffix 
#       release lines.
#       19-Aug-2013, Greg White (greg@slac.stanford.edu)
#       Re-write for supporting file driven release packaging.
#       11-Jan-2013, Greg White (greg@slac.stanford.edu)
#       Updated TAG so as to build first beta 2 release. Also, removed references to 
#       pvService.
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
                          ~/.m2/repository/org/epics/. If -l is not given, the
                          SourceForge hosted files will be used.

       -r <SFusername>   Use remote files. The argument SFusername is the SourceForge
                         username to be used for upload.

       NOTE: Use of -l and -r are mutually exclusive.  

       NOTE: The versions in RELEASE_VERSIONS, MUST not be SNAPSHOT versions. That is
       contrary to release policy, and the script won't work in the expected way anyway
       because maven snapshots have timestamps in their name,not recogized by this script.

   Example:

       Package from local files example:
 
         $ hg/pvDataWWW/scripts/makereleaseJars.sh -n EPICS-Java-4.3.0-pre1 -l hg
     
       In this example, makereleaseJara.sh packaged the jar files for a release named
       EPICS-Java-4.3.0-pre1, as specified in a RELEASE_VERSIONS file it must find in
       hg/pvDataWWW/scripts/RELEASE_VERSIONS. The command was executed from the parent
       of hg/ so that the tar file did not pollute any repos.

       Package from remote files example:

         $ makereleaseJars.sh -n EPICS-Java-4.3.0-pre1 -r gregorywhite 

       In this example, makereleaseJara.sh packaged the jar files for a release named
       EPICS-Java-4.3.0-pre1, as specified in the RELEASE_VERSIONS file it finds on the
       web (see URL in source of this script).
       It will first download the files it finds in the maven repo at 
       http://epics.sourceforge.net/maven2/org/epics/, and package them into a tar file.

"
}

declare -a modulesa

# Remote location of the file which defines the versions of each package going into
# tar file for the given release, and the README.
RELEASE_VERSIONS_URL=\
http://hg.code.sf.net/p/epics-pvdata/pvDataWWW/raw-file/tip/scripts/RELEASE_VERSIONS
README_URL=\
http://hg.code.sf.net/p/epics-pvdata/pvDataWWW/raw-file/tip/mainPage/README
SF_URL=\
http://epics.sourceforge.net
MAVEN_URL=\
http://repo1.maven.org

SFusername=
releaseName= 
localfiles=0
remotefiles=0
if [ $# -lt 1 ]; then
   echo "Not enough arguments, at least the -n releaseName must be given. " \
        "See makereleaseJars.sh -h for help";
   exit 1;
fi
while getopts hr:l:n: opt; do
   case "$opt" in
       h) usage; exit 0 ;;
       r) remotefiles=1 
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
    readme_pathname=${hgrepodirname}/pvDataWWW/mainPage/README
else
    wget ${RELEASE_VERSIONS_URL}
    release_versions_pathname=${PWD}/RELEASE_VERSIONS
    wget ${README_URL}
    readme_pathname=${PWD}/README
fi
if [ ! -f ${release_versions_pathname} ]; then
    echo "Failed to locate or use the RELEASE_VERSIONS file."
    exit 2
fi
# Construct fully qualified pathname of RELEASE_VERSIONS and REAMDE files
file=$release_versions_pathname
release_versions_pathname=$( readlink -f "$( dirname "$file" )" )/$( basename "$file" )
file=$readme_pathname
readme_pathname=$( readlink -f "$( dirname "$file" )" )/$( basename "$file" )

# Read the repos and versions that the release tar must be composed of, from the
# RELEASE_VERSIONS file.
modulesa=(`awk -v relname=${releaseName} 'BEGIN {relname="^" relname "$"} $1 ~ relname {print $2}' < $release_versions_pathname`)
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
          'BEGIN {relname="^" relname "$"} $1 ~ relname && $2 ~ modulename {print $3}' < $release_versions_pathname`

    if [ $? -eq 0 ]; then

        # If no SourceForge user name was given, assume we're packaging from files 
        # in a local maven repository, and further assume it's in ~./m2/repository/
        #
        echo Adding ${modulei} ${tag} to ${releaseName} tar directory 
        if [ ${localfiles} -eq 1 ]; then
	    cp ~/.m2/repository/org/epics/${modulei}/${tag}/${modulei}-${tag}.jar .
	    cp ~/.m2/repository/org/epics/${modulei}/${tag}/${modulei}-${tag}.pom .
	    cp ~/.m2/repository/org/epics/${modulei}/${tag}/${modulei}-${tag}-sources.jar .
	    cp ~/.m2/repository/org/epics/${modulei}/${tag}/${modulei}-${tag}-javadoc.jar .
        else
	    if [ ${modulei} = "caj" ] || [ ${modulei} = "jca" ]; then
		set -x
		wget ${MAVEN_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}.jar
		wget ${MAVEN_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}.pom
		wget ${MAVEN_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}-sources.jar
		wget ${MAVEN_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}-javadoc.jar
	    else
		set -x
		wget ${SF_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}.jar
		wget ${SF_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}.pom
		wget ${SF_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}-sources.jar
		wget ${SF_URL}/maven2/org/epics/${modulei}/${tag}/${modulei}-${tag}-javadoc.jar
	    fi
            set +x
        fi
     else
	echo "Could not get module version for ${modulei}, exiting"
	exit 3
     fi
done
# Add RELEASE_VERSIONS and README to the bundle
echo Adding RELEASE_VERSIONS and README
cp $release_versions_pathname .
cp $readme_pathname .

# Finally pop up to parent directory and tar the bundle
cd ..
echo Tarring  $outdir to $tarfile
tar czf $tarfile $outdir

exit 0
