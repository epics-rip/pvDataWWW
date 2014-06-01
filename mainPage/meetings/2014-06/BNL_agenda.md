  <link rel="stylesheet" type="text/css" href="../../base.css" />
  <link rel="stylesheet" type="text/css"   href="../../epicsv4.css" />

<br />

# Agenda of EPICS Version 4 meeting

*PRELIMINARY AGENDA V1-6-14. TIMES TO BE ADDED.*

**Dates**: July 15, 16, 17 2014

**Location**: [Brookhaven National Lab](http://www.bnl.gov/world/).

**Local contact**: Bob Dalesio


DAY 1: Version 4.4 preparedness status reports
-
Precise location and times to be announced.

Status reports and demonstrations of work for planned version 4.4 features.

* Multicast [Matej]

    Description, API and demo of use cases.

* dbGroup [Ralph]

    Description, API and demo. 

* Use of unions [Dave]

    Just the two kinds of union and a demo - perhaps from areaDetector work,
but lets look more closely at areaDetector, NTNDArray and discussion in day 2.

* pvArray and copy on write [Marty]

    I'd really like to see a demo which illustrates not only the 
programmers interface but also quantitatively characterizes the 
performance.
 
* Codec based transport [Matej]

    Description, API and demo of both pvAccess codec and the ZeroMQ codec.

* New channel Data API [Matej]

    Description, API and demo. 

* Access security plugin [Matej]

    Description, API and demo.


DAY 2: Collaboration exchange
-
Precise location and times to be announced.

*Morning; user experiences*

* SLAC's architecture for EPICS V4, services and applications [Greg]

    Description and demo of the services developed at slac, and their use in Matlab apps.

* BNL use of Channel Finder Service [Speaker to be announced. Bob can you arrange one?]

* BNL operations use of OLOG and MASAR [Speaker to be announced. Bob can you arrange one?]

* BNL environment for experimental control, data acquisition, and data management [Bob or deputy]

* BNL users' experience with CSS [Speaker to be announced]

*Afternoon, High level applications and HP processing support*

* New Normative types with errors [Greg]

    Description and demo of types including measurement or fitting errors

* NTNDArray and areaDetector work at Diamond [Dave]

* pvDatabase description and status [Marty]

    Description of the database and processing, and demo of examples

* areaDetector, NTNDArray, and plans for large data support.

    Bob, can you prepare the objectives for this session, and questions to be answered?


Day 3: Gateway requirements
-
Precise location and times to be announced.

*Morning; Gateway requirements, plans, assignments*

* Review of the [gateway requirements][1] [Lead by Ralph]

    The gateway is now becoming the most critical element of V4 outstanding. Please be prepared having read the published requirements and ready with your own.

    One objective will be prioritization. Will streaming be attempted in the first pass? How to deal with differing pvRequests of the same PV?

* Monitor processing

*Afternoon; overflow*

As we've found we need, we need some overflow time to return to critical issues.

[1] http://epics-pvdata.sourceforge.net/doc/pvGateway/requirements.html

