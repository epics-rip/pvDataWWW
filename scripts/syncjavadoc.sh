#!/bin/bash
#!-*- sh -*-
# 
# Abs: syncjavadoc is a bash source script to manage the release of new JavaDoc
# following a versioned release of the Java implementations of the EPICS V4 core modules.
#
# Usage: 
#          Following a tagged release of ALL 3 of the pv*Java modules (pvDataJava, pvIOCJava, pvAccessJava),
#          as described in release.html, checkout syncjavadoc, edit it to change the 
#          USER to your sourceforge username, and TAG to the release tag, eg "1.0-BETA", then
#          run syncjavadoc by hand from your own computer (as opposed to inside Jenkins).
#
#          ./syncjavadoc.sh
#  
# Ref: http://epics-pvdata.sourceforge.net/release.html
#
# ----------------------------------------------------------------------------
# Auth: 16-Dec-2011, James Rowland  
# Mod:  20-Dec-2011, Greg White (greg@slac.stanford.edu). Updated for 1.0-BETA.
#       Added header. 
# ============================================================================
USER=gregorywhite
TAG=1.0-BETA
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataJava
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessJava
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCJava
(cd pvDataJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
(cd pvAccessJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
(cd pvIOCJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
rsync -avz pvDataJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvDataJava/$TAG
rsync -avz pvAccessJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvAccessJava/$TAG
rsync -avz pvIOCJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvIOCJava/$TAG
