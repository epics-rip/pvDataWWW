#!/bin/bash
USER=jrowlandls
TAG=1.0.1-BETA
OUT="EPICSv4-$TAG"
TARFILE="$OUT.tar.gz"
mkdir -p $OUT
echo creating $TARFILE
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataCPP
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessCPP
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCCPP
(cd pvDataCPP && hg archive ../$OUT/pvDataCPP)
(cd pvAccessCPP && hg archive ../$OUT/pvAccessCPP)
(cd pvIOCCPP && hg archive ../$OUT/pvIOCCPP)
cp RELEASE.local $OUT/RELEASE.local.example
echo $TAG > $OUT/tag.txt
tar czf $TARFILE $OUT
rsync -e ssh $TARFILE $USER,epics-pvdata@frs.sourceforge.net:/home/frs/project/e/ep/epics-pvdata/$TAG/
