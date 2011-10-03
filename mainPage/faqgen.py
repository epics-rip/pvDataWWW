#!/usr/bin/env python

"""
<!-- 
> * Does it work? [they meant is it an intention to do work, or are there usable products]
> * What does it work with? [I think they meant RTEMS, VxWorks etc]
> * "The line from top to bottom for controls" [their words].This is tough for a FAQ - but it is a valid question.
> * What's going to be different [to EPICS v3]?
> * Why is it better?
> * Do I have to re-write drivers?
> * What's relevance to controls?
> 
> * How does it work with the EPICS display tool, DM, EDM etc?
> * What's the relationship of EPICS V4 to channel access?
> * Can I use EPICS V4 in a mixed environment with EPICS V3?
> * How does PVAS interface to an IOC?
> * What's the performance?
-->
"""

source = file("faq.txt").read()

table = [entry.split("\n") for entry in source.split("\n\n")]

faq = file("faq.html", "w")
template = file("faq0.html").read()
text = "faqqing brilliant"

keys = []
for row in table:
    k = row[0]
##     print k
##    print row[1:]
    keys.append(k)

text = []
def p(x): text.append(x)

p("<ol>")
for i, row in enumerate(table):
    p('<a href="#entry%d"><li class="faq">%s</li></a>' % (i, row[0]))
p("</ol>")

p("<ol>")
for i, row in enumerate(table):
    p('<li class="faq" id="entry%d">%s</li>' % (i, row[0]))
    p('<div class="faa">%s</div>' % "\n".join(row[1:]))
p("</ol>")

print >> faq, template % {"INSERTFAQ": "\n".join(text)}
faq.close()



