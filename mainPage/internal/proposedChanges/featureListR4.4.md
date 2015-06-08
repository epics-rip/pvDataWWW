
  <link rel="stylesheet" type="text/css" href="../../base.css" />
  <link rel="stylesheet" type="text/css"   href="../../epicsv4.css" />

<!-- python -m markdown featureListR4.4.md > featureListR4.4.html -->
<br />

#RELEASE 4.4 NEW FEATURES

**Version:** This is the 11-July-2014 version of the 4.4 features document. This version
removes dbGroup and replaces that functionality through pvDatabase, and adds the
CA security plugin.

EPICS Version 4 is an extensive system of extensions that interoperate with EPICS core version 3 modules, to provide IOC data in simple, elegant, efficient ways to users, scientists and high performance processors.

Version 4.4 brings simplicity, elegance and performance to many facets
of EPICS.

EPICS base version 3.14 is required to run Version 4. 

#New Features Summary

Major new features of version 4.4 include:

**Items marked \* are hoped for new features, but as of this writing it is not confirmed they will be in 4.4**

* Multicast support
* Dynamic channel data typing, by unions
* Higher performance and simplified array handling [pvArray, fixed-size arrays, COW]
* Codec based transport, plus bundled codecs for pvAccess and ZeroMQ
* More flexible and informative channel data API [channel method callbacks]
* Smart handling of data measurement and fitting errors [Normative type errors]
* Pluggable access security API, plus plugin for Channel Access Security
* Simplified and upgraded data access command line tools [unified pvget/eget\*]
* Upgraded Easy to use API [easyPVA\*]
* Intrinsic data type support for images from detectors and cameras [NTNDArray]
* Windows added to supported platforms.

Cleanups and infrastructure changes

* Reimplemented pvCopy

Alpha software bundled

* A smart database and processing framework, embeddable in an IOC [pvDatabase]
* Composite IOC PV data [multi capability of pvDatabase]
* Monitor processing options
* Use Python to talk to pvAccess PVs
* Use Matlab to talk to pvAccess PVs


#New Feature Details

A more detailed description of the changes specifically in the V4 core modules, pvAccess and
pvData, w.r.t. release 4.4, is given in
[proposedChanges_3_0.html](http://epics-pvdata.sourceforge.net/internal/proposedChanges/proposedChanges_3_0.html)

[Other questions regarding the release; will Gather be reimplemented standalone and bundled? What about swtShell? What about portDriverJava? What will be the status of pvRequest?] 

`DISCUSSION REQUIRED`

* Should this document still refer to proposedChanges?
* swtshell is ready to be part of 4.4. Should it?
* Gather: Only client or also server?
* Gather: How is this related to pvDatabaseCPP multiChannel?
* masarServer::gatherV3Data needs major changes because of COW semantics for arrays.
* portDriverJava should not be part of 4.4.
* What is meant by "What will be the status of pvRequest?"

Multicast Support
-

Implementation of multicast used for channel/service discovery and shared data transfer, is added to pvAccess.



Dynamic channel data typing
-

A new basic data type has been added for expressing unions. PV data may now dynamically change type.

A union is like a structure that has a single sub-field with
a type that can be changed dynamically. There are two subtypes of union:

* variant union, in which the type can be any type
* a "regular" union, in which the type must be one of the fixed set of types, determined by the introspection interface of a given union instance.

[pvDataCPP.html](<http://epics-pvdata.sourceforge.net/docbuild/pvDataCPP/tip/documentation/pvDataCPP.html>)
provides example code for generating union and unionArray fields. Read section "Examples".

Higher performance and simplified array handling [pvArray, COW]
-

For use cases in which the length of arrays won't change, a simple fixed-size array handling mechanism has been enabled to unlock the potential for very fast fixed array exchange.

The channelArray  methods have been changed so that:

* In addition to offset and length, stride is now supported.
* Offset, length, and stride are no longer restricted to be a 32 bit integer,
* A new method getLength allows a client to get the length and capacity of an array without transfering the array itself.


The C++ implementation of pvData has the following major changes:

* The array data types (scalarArray, unionArray, and structureArray)
now enforce Copy On Write (COW) semantics, which helps prevent thread conflicts.
* A new shared_vector facility allows read only array data to be shared so that
computationally expensive copy operations are minimized.
This facility is used to store the raw data for PVArray.
* Convert, a facility for converting between two different PVData objects, has been greatly simplified.
* PVSubArray is a new facility that copies a subarray from one PVArray to another. The two arrays must have the same element type.

Codec based pvAccess transport
-----------------------------------

Using a codec decouples protocol from transport. All the protocol [GW: do you
mean "protocol", or do you mean "transport" here? - I think you mean transport]
specific code is now encapsulated in one abstract class. Transport specific
code (as provided by for instance TCP, UDP, shared memory, or zeroMQ) must
then be provided in order to get a fully functional pvAccess communication.

Codecs for the former transport layer of pvAccess, and ZeroMQ transport, are provided,
so you can use pvAccess or ZeroMQ immediately.

More flexible and informative channel data API  [channel* callbacks]
--------------------

The pvAccess API for channelGet, channelPut, channelPutGet, and monitor have been upgraded as follows:

* The connect callback now provides the introspection interface instead of the data interface.
* Whoever provides the data provides the data in the method that delivers the data and a bitSet showing what has changed.

These changes greatly simplify threading issues.
See
[pvAccessJava.html](<http://epics-pvdata.sourceforge.net/docbuild/AccessJava/tip/documentation/AccessJava.html>)
for the new API for pvAccess.


Smart handling of data measurement and fitting errors [Normative type errors]
-

The system of high level data types, called Normative Types
(<http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html>)
have been revised and extended to properly incorporate errors on data values. Clients and intelligent OPIs can now find and display the measurement or fit error along with the data of a PV.

Pluggable access security API, plus plugin for Channel Access Security
-------------------------------

A security plugin API is added, that allows pluggable
implementations of specific security schemes for pvAccess or Channel Access, together with one such plugin for Channel Access security.  


Simplified and upgraded eget command line tool [unified pvget/eget]
-
eget and pvget have been unified into one comprehensive command, doing all the functions of get, monitor, and RPC, over PVA, or CA (if CA supports the operation), and supporting pvaRequest and URL syntax.

Upgraded Easy to use API [easyPVA]
-

The easy to use API, easyPVA <http://epics-pvdata.sourceforge.net/docbuild/easyPVAJava/tip/documentation/easyPVA.html> is upgraded to include monitors and parallel acquisitions (multichannel).

`DISCUSSION REQUIRED` multiChannel has been implemented but not monitor.

Intrinsic data type support for images from detectors and cameras [NTNDArray]
-
A new data type for carrying data from detectors and cameras, has been added to the set of standard EPICS V4 types. This new type, called [NTNDArray](http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html), carries all ~the data of one frame, and is modelled heavily on the [NDarray](http://cars9.uchicago.edu/software/epics/areaDetectorDoxygenHTML/class_n_d_array.html) of areaDetector.

Using PVs defined as an NTNDArray,~ for instance enables one to build a chain processors of areaDetector plugins encapsulated as pvDatabase records in a data flow model, for high performance image processing.

<br />

#Non-functional changes and cleanups

Reimplemented pvCopy
-

`pvCopy`, together with `pvRequest`, allows a client to access to an arbitrary subset
of the data in the structure associated with a pvAccess channel.
It was in pvIOCJava and pvDatabaseCPP but has been moved to pvDataJava and pvDataCPP.
The dependency on pvRecord has been removed.

Additionally, `CreateRequest`, which is used by clients to create a pvRequest,
has been moved from pvAccess to pvData.

Uses of `pvCopy` in `pvIOCJava` and `pvDatabaseCPP` have been
changed to use the `pvCopy` from pvData.

<br />

# Alpha software bundled

Some powerful but alpha level software is also bundled into V4.4 for early adopters.

A smart database and processing framework, embeddable in an IOC [pvDatabase]
-

Version 4.4 provides a framework for implementing a network accessible database of smart memory resident records, named pvDatabase. Such a database may be embedded into an IOC to work in concert with the IOC's database, or at higher levels of a control system to provide high performance dataflow processing of lower level measurement data. For instance, it can be used to host a set of areaDetector plugins, working as a pipeline processor for camera image data. See pvDatabaseCPP <http://epics-pvdata.sourceforge.net/docbuild/pvDatabaseCPP/tip/documentation/pvDatabaseCPP.html>.

Composite IOC PV data [multi capability of pvDatabase]
-
The IOC can now return the value of a number of records as a single PV's value. For instance, a single IOC hosted PV may give both the magnetic field strength and setpoint current of a magnet.

The composite PV is expressed as a pvDatabase record. The pvDatabase may be embedded in an IOC, or hosted at a higher level.

`DISCUSSION REQUIRED` composite PV has not been implemented.
Some design decisions are required:

* What data type are supported?
* When is record configured? At iocInit time? Dynamically by pvAccess client?
* What collects records from multiple IOCs?

Use Python to talk to pvAccess PVs 
-
[pvaPy](https://github.com/epics-base/pvaPy) is a simple and elegant Python API for pvAccess.

[Will Need a few words on how complete it is, and whether it incorporates CA access].

Use Matlab to talk to pvAccess PVs
-
em is a simple Matlab API for pvAccess.

[Will need a few words on how complete it is, and whether it incorporates CA access].

Monitor processing options
--------------------

This is only in pvdataCPP.
It is a way for a client to specify processing options for monitors.

`DISCUSSION REQUIRED` monitorPlugins need discussion.

Windows platform
----------------

EPICS V4 has been ported to Windows (**what Windows more specifically**)

