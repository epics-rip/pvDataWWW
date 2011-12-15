#!/bin/bash
USER=jrowlandls
TAG=test1
# better use functions or loops in BASH!
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataCPP
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessCPP
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCCPP
cp RELEASE.local CONFIG_SITE.local pvDataCPP/configure
cp RELEASE.local CONFIG_SITE.local pvAccessCPP/configure
cp RELEASE.local CONFIG_SITE.local pvIOCCPP/configure
# don't build the example that depends on Normative Types
patch -p0 < pvIOCCPP_noNT.patch
(cd pvDataCPP && make && doxygen)
(cd pvAccessCPP && make && doxygen)
(cd pvIOCCPP && make && doxygen)
rsync -avz pvDataCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvDataCPP/$TAG
rsync -avz pvAccessCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvAccessCPP/$TAG
rsync -avz pvIOCCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvIOCCPP/$TAG
