#!/bin/bash
USER=jrowlandls
TAG=test1
hg clone ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataCPP
hg clone ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessCPP
hg clone ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCCPP
(cd pvDataCPP && hg tag $TAG -u $USER && hg commit -m 'tagged by script' -u $USER && hg push)
(cd pvAccessCPP && hg tag $TAG -u $USER && hg commit -m 'tagged by script' -u $USER && hg push)
(cd pvIOCCPP && hg tag $TAG -u $USER && hg commit -m 'tagged by script' -u $USER && hg push)
