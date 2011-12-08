#!/bin/bash
PROJ="$1"
TD=$(mktemp -d)
hg clone ssh://jrowlandls@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/$PROJ $TD
(cd $TD && javadoc -d javadoc -sourcepath src -subpackages org.epics)
rsync -avz $TD/javadoc jrowlandls,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/doxygen/$PROJ
