#! Process the EPICS v4 meeting minutes from Skype chat transcript to
#! EPICS v4 meeting minutes format
#!
#! Usage:
#!      awk -v scribe='James Rowland' -f makeminutes.awk copypastefilefromSkype > minutes_yyyymmdd.txt
#!
#! ----------------------------------------------------------------------
#! Auth: Greg White, 23-Nov-2011
#! Mod:  Greg White, 30-Nov-2011, Upgraded patterns for AIs etc, to fit Ralphs style. 
#! ======================================================================
BEGIN { IGNORECASE=1; }
#! /AI:/||/AI on/ {print $0}

#! Remove the scribe from each line except the Scribe line. 
#! That is delete text matching input -v scribe=<scribename>
$0~/Scribe:/ { print; next }
{   #! Remove scribe 
    sub(scribe,""); 
    #! Remove time
    sub(/^\[.*\]/,""); 
}

#! Highlight new topic
/NEW TOPIC/{ print "**********************"; print; print "**********************"; next }

#! Process RESOLUTIONS, AIs and ISSUES
/RES(OLUTION)?[ ]*[:-]/||/[Rr]es(olution)?[ ]*[:-]/ { print "***********"; print; print "***********"; next }
/AI[ :].+[:-]/||/ACTION[ :].+[:-]/||/[Aa]ction[ :].+[:-]/ {print "************"; print; print "************"; next }
/ISSUE[ ]*[:-]/||/[Ii]ssue[ ]*[:-]/ {print "*************"; print; print "************"; next }

#! Print results of formatting.
{ print }