#!/bin/bash
USER=jrowlandls
PVDATATAG=tip
PVACCESSTAG=tip
PVIOCTAG=tip
hg clone -r $PVDATATAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataCPP
hg clone -r $PVACCESSTAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessCPP
hg clone -r $PVIOCTAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCCPP
cp RELEASE.local CONFIG_SITE.local pvDataCPP/configure
cp RELEASE.local CONFIG_SITE.local pvAccessCPP/configure
cp RELEASE.local CONFIG_SITE.local pvIOCCPP/configure
# don't build the example that depends on Normative Types
patch -p0 < pvIOCCPP_noNT.patch
(cd pvDataCPP && make && doxygen)
(cd pvAccessCPP && make && doxygen)
(cd pvIOCCPP && make && doxygen)
rsync -avz pvDataCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvDataCPP/$PVDATATAG
rsync -avz pvAccessCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvAccessCPP/$PVACCESSTAG
rsync -avz pvIOCCPP/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvIOCCPP/$PVIOCTAG
