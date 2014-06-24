HTML header:
    <link rel="stylesheet" type="text/css" href="../../base.css" />
    <link rel="stylesheet" type="text/css"   href="../../epicsv4.css" />

<!-- python -m markdown BNL_agenda.md BNL_agenda.html -->

<br />

# Agenda of EPICS Version 4 Meeting

*AGENDA V24-6-14*

**Dates**: July 15, 16, 17 2014

**Location**: [Brookhaven National Lab](http://www.bnl.gov/world/).

**Local contact**: Bob Dalesio

Comprehensive minutes will be recorded by Google shared document. Attendees should be prepared to minute part of the meeting.

DAY 1, Tuesday July 15, 2014: Version 4.4 preparedness status reports
-
9:00 AM Convene. Start at 9:20. Precise location to be announced. TIMES ARE AT CHAIR'S DISCRETION.

Status reports and demonstrations of work for [planned version 4.4 features][1].

* **dbGroup** _Ralph Lange_

    Description, API and demo. Note dbGroup is not intended for 4.4, but this is a convenient time for Ralph to bring us up to date.

* **Version 4.4 Feature List review** _Greg White_

    Short review of [features that we intended to be in 4.4][1]

* **pvDatabase, and use of pvDatabase for composite PVs** _Marty Kraimer_

    A description and demo of the "multi" capabilities of pvDatabase for
	expressing a pva PV whose value is composed of CA pv names and values.
	Other features of PVDatabase will be discussed Wednesday morning.
	
* **Multicast** _Matej Sekornaja_

    Description, API and demo of use cases.

* **Use of unions** _Dave Hickin_

    Just the two kinds of union and a demo - perhaps from areaDetector work,
but lets look more closely at areaDetector, NTNDArray and discussion in day 2.
 
* **Codec based transport** _Matej Sekornaja_

    Description, API and demo of both pvAccess codec and the ZeroMQ codec.

* **pvArray and copy on write** _Marty Kraimer_

    I'd really like to see a demo which illustrates not only the 
programmers interface but also quantitatively characterizes the 
performance.

* **New channel Data API** _Matej Sekornaja_

    Description, API and demo. 

* **Access security plugin** _Matej Sekornaja_

    Description, API and demo.

* **pvaPy** _Andrew for Sinisa Veseli_

    Description, API, and demo of Python support of pvAccess (and CA is being added through the pvAccess API too, right?)
	
DAY 2, Wednesday July 16, 2014: Collaboration exchange
-
9:00 AM. Precise location to be announced. TIMES ARE AT CHAIR'S DISCRETION.


*Morning 1; IOC plans*

* **pvDatabase description and status** _Marty Kraimer_

    Further description of the database and processing, and demo of examples (con't from Tuesday's talk on the multi capability of pvDatabase).

* **Discussion of V4 IOC integration plans and schedule** _Andrew Johnson leads_

*Morning 2; High level applications and HP processing support*

* **New Normative types with errors** _Greg White_

    Description and demo of types including measurement or fitting errors

* **areaDetector and V4 Integration work at Diamond** _Dave Hickin_

* **areaDetector, NTNDArray, and plans for large data support**

    Bob, can you prepare the objectives for this session, and questions to be answered?


*Afternoon; User experiences*

* **SLAC's architecture for EPICS V4, services and applications** _Greg White_

    Description and demo of the services developed at slac, and their use in Matlab apps.

* **The MongoDB and V4 based Archive Service at BNL** _Nikolay Malitsky_

* **BNL use of Channel Finder Service** _Speaker to be announced. Bob can you arrange one?_

* **BNL operations use of OLOG and MASAR** _Speaker to be announced. Bob can you arrange one?_

* **BNL environment for experimental control, data acquisition, and data management** _Bob or deputy_

* **User's guide to CSS** _Gabriele Carcassi_

* **BNL users' experience with CSS** _Speaker to be announced_



DAY 3, Thursday July 17, 2014: Gateway requirements
-
9:00 AM. Precise location to be announced. TIMES ARE AT CHAIR'S DISCRETION.
 
*Morning; Gateway requirements, 2014-15 Charter review, plans, assignments*

* **Review of the [gateway requirements][2]** _Lead by Ralph Lange_

    The gateway is now becoming the most critical element of V4 outstanding. Please be prepared having read the published requirements and ready with your own.

    One objective will be prioritization. Will streaming be attempted in the first pass? How to deal with differing pvRequests of the same PV?

* **Monitor processing** _Marty Kraimer_

* **2014-15 Charter Review and Roadmap** _Greg White_    

*Afternoon; overflow*

As we've found we need, we need some overflow time to return to critical issues.


[1]: http://epics-pvdata.sourceforge.net/internal/proposedChanges/featureListR4.4.html "Version 4.4 Feature List"
[2]: http://epics-pvdata.sourceforge.net/doc/pvGateway/requirements.html "Gateway Requirements"
