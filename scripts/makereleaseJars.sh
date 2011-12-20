#!/bin/bash
#!-*- sh -*-
# 
# Abs: makereleaseJars is a bash source script to manage the release of jar files for a
#      version tagged release.
#
# Usage: 
#          Following a tagged release of ALL 3 of the pv*Java modules (pvDataJava, pvIOCJava, pvAccessJava),
#          as described in release.html, checkout makereleaseJars.sh, edit it to change the 
#          USER to your sourceforge username, and TAG to the release tag, eg "1.0-BETA", then
#          run it by hand from your own computer (as opposed to inside Jenkins) in some area
#          that is not under hg (otherwise you'll have a clone inside the pvDataWWWW/scripts clone).
#
#          cd ~
#          mkdir tmp; cd tmp
#          ./<pathto-pcDataWWW/scripts>/makereleaseJars.sh
#  
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 20-Dec-2011, Greg White (greg@slac.stanford.edu) 
# Mod:  
# ============================================================================
USER=gregorywhite
TAG=1.0-BETA
OUT="EPICSv4-Java-$TAG"
mkdir -p $OUT
cd $OUT
wget http://epics.sourceforge.net/maven2/epics/pvData/$TAG/pvData-$TAG.jar .
wget http://epics.sourceforge.net/maven2/epics/pvAccess/$TAG/pvAccess-$TAG.jar .
wget http://epics.sourceforge.net/maven2/epics/pvIOC/$TAG/pvIOC-$TAG.jar .
wget http://epics.sourceforge.net/maven2/epics/exampleJava/$TAG/exampleJava-$TAG.jar .
echo $TAG > tag.txt
rsync -a * $USER,epics-pvdata@frs.sourceforge.net:/home/frs/project/e/ep/epics-pvdata/$TAG
