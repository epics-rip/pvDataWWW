#!/bin/bash
USER=jrowlandls
TAG=tip
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvDataJava
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvAccessJava
hg clone -r $TAG ssh://$USER@epics-pvdata.hg.sourceforge.net/hgroot/epics-pvdata/pvIOCJava
(cd pvDataJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
(cd pvAccessJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
(cd pvIOCJava && javadoc -d documentation/html -sourcepath src -subpackages org.epics)
rsync -avz pvDataJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvDataJava/$TAG
rsync -avz pvAccessJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvAccessJava/$TAG
rsync -avz pvIOCJava/documentation $USER,epics-pvdata@web.sourceforge.net:/home/project-web/epics-pvdata/htdocs/docbuild/pvIOCJava/$TAG
