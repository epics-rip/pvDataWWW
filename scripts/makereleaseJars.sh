#!/bin/bash
#!-*- sh -*-
# 
# Abs: makereleaseJars is a bash source script to manage the release of jar files and 
#      associated deliverables for a version tagged release of the Java implementation 
#      of EPICS v4.
#
# Usage: 
#      Following a tagged release of ALL 3 of the pv*Java modules (pvDataJava, pvIOCJava, pvAccessJava),
#      as described in release.html, checkout makereleaseJars.sh, edit it to change the 
#      USER to your sourceforge username, and TAG to the release tag, eg "1.0-BETA", then
#      run it by hand from your own computer (as opposed to inside Jenkins) in some area
#      that is not under hg (otherwise you'll have a clone inside the pvDataWWWW/scripts clone).
#
#            cd ~
#            mkdir tmp; cd tmp
#            ./<pathto-pcDataWWW/scripts>/makereleaseJars.sh
#  
#      A user should unpack the resulting tar.gz with, for instance:
#            tar -zxvf EPICSv4-Java-1.0-BETA.tar.gz
#
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 20-Dec-2011, Greg White (greg@slac.stanford.edu) 
# Mod:  09-Jan-2011, Greg White (greg@slac.stanford.edu) 
#       Added creating a tar.gz, converted upload of exampleJava.jar to only 
#       including its source in the tar.gz (more useful than the jar for examples)
#       and also include the common dir in the tar.gz. 
# ============================================================================
USER=gregorywhite
TAG=1.0-BETA
OUTDIR="EPICSv4-Java-$TAG"
TARFILE="$OUTDIR.tar.gz"
mkdir -p $OUTDIR
cd $OUTDIR
wget http://epics.sourceforge.net/maven2/epics/pvData/$TAG/pvData-$TAG.jar
wget http://epics.sourceforge.net/maven2/epics/pvAccess/$TAG/pvAccess-$TAG.jar
wget http://epics.sourceforge.net/maven2/epics/pvIOC/$TAG/pvIOC-$TAG.jar
cd ..
# For use of Java from jars, one still needs some source. xmls, example source, and common
# setup scripts in particular.
# For XMLs:
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCJava
# For XMLs:
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvServiceJava
# For source of examples:
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/exampleJava
# For common_setup.bash script:
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/common
# For README:
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataWWW

(cd pvIOCJava && hg archive ../$OUTDIR/pvIOCJava/xml)
(cd pvServiceJava && hg archive ../$OUTDIR/pvServiceJava/xml)
(cd exampleJava && hg archive ../$OUTDIR/exampleJava)
(cd common && hg archive ../$OUTDIR/common)

(cd pvDataWWW && hg archive -I mainPage/README ../../$OUTDIR)
cp pvDataWWW/mainPage/README $OUTDIR
rm -fr $OUTDIR/pvDataWWW

echo $TAG > $OUTDIR/tag.txt
tar czf $TARFILE $OUTDIR
# rsync -a * $USER,epics-pvdata@frs.sourceforge.net:/home/frs/project/e/ep/epics-pvdata/$TAG
