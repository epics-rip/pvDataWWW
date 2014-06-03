HTML header:
    <link rel="stylesheet" type="text/css" href="../../base.css" />
    <link rel="stylesheet" type="text/css"   href="../../epicsv4.css" />

<br />

# Agenda of EPICS Version 4 Meeting

*PRELIMINARY AGENDA V1-6-14. TIMES TO BE ADDED.*

**Dates**: July 15, 16, 17 2014

**Location**: [Brookhaven National Lab](http://www.bnl.gov/world/).

**Local contact**: Bob Dalesio

Comprehensive minutes will be recorded by Google shared document. Attendees should be prepared to minute part of the meeting.

DAY 1, Tuesday July 15, 2014: Version 4.4 preparedness status reports
-
Precise location and times to be announced.

Status reports and demonstrations of work for (planned version 4.4 features)[http://epics-pvdata.sourceforge.net/internal/proposedChanges/featureListR4.4.html].

* **dbGroup** [Ralph]

    Description, API and demo. Note dbGroup is not intended for 4.4, but this is a convenient time for Ralph to bring us up to date. 

* [**pvDatabase, and use of pvDatabase for composite PVs**]

    A description and demo of the "multi" capabilities of pvDatabase for
	expressing a pva PV whose value is composed of CA pv names and values.
	Other features of PVDatabase will be discussed Wednesday morning.
	
* **Multicast** [Matej]

    Description, API and demo of use cases.

* **Use of unions** [Dave]

    Just the two kinds of union and a demo - perhaps from areaDetector work,
but lets look more closely at areaDetector, NTNDArray and discussion in day 2.
 
* **Codec based transport** [Matej]

    Description, API and demo of both pvAccess codec and the ZeroMQ codec.

* **pvArray and copy on write** [Marty]

    I'd really like to see a demo which illustrates not only the 
programmers interface but also quantitatively characterizes the 
performance.

* **New channel Data API** [Matej]

    Description, API and demo. 

* **Access security plugin** [Matej]

    Description, API and demo.

* **pvaPy** [Andrew for Sinisa]

    Description, API, and demo of Python support of pvAccess (and CA is being added through the pvAccess API too, right?)
	
DAY 2, Wednesday July 16, 2014: Collaboration exchange
-
Precise location and times to be announced.

*Morning 1; IOC plans*

* **pvDatabase description and status** [Marty]

    Further description of the database and processing, and demo of examples (con't from Tuesday's talk on the multi capability of pvDatabase).

* **Discussion of V4 IOC integration plans and schedule** [Andrew leads]

*Morning 2; High level applications and HP processing support*

* **New Normative types with errors** [Greg]

    Description and demo of types including measurement or fitting errors

* **NTNDArray and areaDetector work at Diamond** [Dave]

* **areaDetector, NTNDArray, and plans for large data support**

    Bob, can you prepare the objectives for this session, and questions to be answered?


*Afternoon; User experiences*

* **SLAC's architecture for EPICS V4, services and applications [Greg]**

    Description and demo of the services developed at slac, and their use in Matlab apps.

* **BNL use of Channel Finder Service** [Speaker to be announced. Bob can you arrange one?]

* **BNL operations use of OLOG and MASAR** [Speaker to be announced. Bob can you arrange one?]

* **BNL environment for experimental control, data acquisition, and data management** [Bob or deputy]

* **User's guide to CSS** [Gabriele]

* **BNL users' experience with CSS** [Speaker to be announced]



DAY 3, Thursday July 17, 2014: Gateway requirements
-
Precise location and times to be announced.

*Morning; Gateway requirements, plans, assignments*

* **Review of the [gateway requirements][1]** [Lead by Ralph]

    The gateway is now becoming the most critical element of V4 outstanding. Please be prepared having read the published requirements and ready with your own.

    One objective will be prioritization. Will streaming be attempted in the first pass? How to deal with differing pvRequests of the same PV?

* **Monitor processing** [Marty]

    

*Afternoon; overflow*

As we've found we need, we need some overflow time to return to critical issues.

[1] http://epics-pvdata.sourceforge.net/doc/pvGateway/requirements.html

