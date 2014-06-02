
  <link rel="stylesheet" type="text/css" href="../../base.css" />
  <link rel="stylesheet" type="text/css"   href="../../epicsv4.css" />

#RELEASE 4.4 NEW FEATURES

EPICS Version 4 is an extensive system of extensions that interoperate with EPICS core version 3 modules, to provide IOC data in simple, elegant, efficient ways to users, scientists and high performance processors.

Version 4.4 brings simplicity, elegance and performance to many facets
of EPICS.

EPICS base version 3.14 is required to run Version 4. 

#New Features Summary

Major new features of version 4.4 include:

**Items marked \* are hoped for new features, but as of this writing it is not confirmed they will be in 4.4**

* Multicast support
* Composite IOC PV data [dbGroup\*]
* Dynamic channel data typing, by unions
* Higher performance and simplified array handling [pvArray, COW]
* Codec based transport, plus bundled codecs for pvAccess and ZeroMQ
* More flexible and informative channel data API [channel method callbacks]
* Smart handling of data measurement and fitting errors [Normative type errors]
* Pluggable pvAccess security API
* Simplified and upgraded data access command line tools [unified pvget/eget\*]
* Upgraded Easy to use API [easyPVA\*]
* Intrinsic data type support for images from detectors and cameras [NTNDArray]

Cleanups and infrastructure changes

* Reimplemented pvCopy

Alpha software bundled

* A smart database and processing framework, embeddable in an IOC [pvDatabase]
* Monitor processing options
* Use Python to talk to pvAccess PVs
* Use Matlab to talk to pvAccess PVs


#New Feature Details

A more detailed description of the changes specifically in the V4 core modules, pvAccess and
pvData, w.r.t. release 4.4, is given in
[proposedChanges_3_0.html](http://epics-pvdata.sourceforge.net/internal/proposedChanges/proposedChanges_3_0.html)

[Other questions regarding the release; will Gather be reimplemented standalone and bundled? What about swtShell? What about portDriverJava? What will be the status of pvRequest?] 

Multicast Support
-

Implementation of multicast used for channel/service discovery and shared data transfer, is added to pvAccess.

Composite IOC PV data [dbGroup]
-
The IOC can now return the value of a number of records as a single PV's value. For instance, a single IOC hosted PV may give both the magnetic field strength and setpoint current of a magnet.

Although the PVs comprising the returned PV's value, need not be from the same lockset, the data from them is not lockset atomic. When the IOC base software incorporates atomic lockset spaning operations, this function will be upgraded.


Dynamic channel data typing
-

A new basic data type has been added for expressing unions. PV data may now dynamically change type.

A union is like a structure that has a single sub-field with
a type that can be changed dynamically. There are two subtypes of union:

* variant union, in which the type can be any type
* a "regular" union, in which the type must be one of the fixed set of types, determined by the introspection interface of a given union instance.

Higher performance and simplified array handling [pvArray, COW]
-

The C++ implementation of the data management interface of EPICS V4, pvData,
now enforces Copy On Write (COW) semantics, to reduce
computationally expensive copy operations to the absolute minimum. 

The API for extracting array data and type conversion, `Convert` has been
greatly simplified. 

The method for put and get array data to a channel, `channelArray` has been upgraded.

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

pvAccess channelGet, channelPut, channelPutGet, and monitor have been upgraded to
provide connection callbacks with introspection interfaces to the data and its bitset metadata.

The PVData data and bitsets are now arguments given by the component that provided the data,
so a client can examine what data it has been returned by the provider.

Smart handling of data measurement and fitting errors [Normative type errors]
-

The system of high level data types, called Normative Types
(<http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html>)
have been revised and extended to properly incorporate errors on data values. Clients and intelligent OPIs can now find and display the measurement or fit error along with the data of a PV.

Pluggable pvAccess security API
-------------------------------

A security plugin API is added, that allows pluggable
implementation of specific security schemes.


Simplified and upgraded eget command line tool [unified pvget/eget]
-
eget and pvget have been unified into one comprehensive command, doing all the functions of get, monitor, and RPC, over PVA, or CA (if CA supports the operation), and supporting pvaRequest and URL syntax.

Upgraded Easy to use API [easyPVA]
-
The easy to use API, easyPVA <http://epics-pvdata.sourceforge.net/docbuild/easyPVAJava/tip/documentation/easyPVA.html> is upgraded to include monitors and parallel acquisitions (multichannel).

Intrinsic data type support for images from detectors and cameras [NTNDArray]
-
A new data type for carrying data from detectors and cameras, has been added to the set of standard EPICS V4 types. This new type, called [NTNDArray](http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html), carries all ~the data of one frame, and is modelled heavily on the [NDarray](http://cars9.uchicago.edu/software/epics/areaDetectorDoxygenHTML/class_n_d_array.html) of areaDetector.

Using PVs defined as an NTNDArray,~ for instance enables one to build a chain processors of areaDetector plugins encapsulated as pvDatabase records in a data flow model, for high performance image processing.

<br />

#Non-functional changes and cleanups

Reimplemented pvCopy
-

`pvCopy`, which used together with `pvRequest`, allows a client to access to an arbitrary subset
of the data in the structure associated with a pvAccess channel, has been moved from its two implementations in pvIOCJava and pvDatabaseCPP, to a single implementation in `pvData`, and its dependency on pvRecord has been removed.

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

Use Python to talk to pvAccess PVs 
-
[pvaPy](https://sourceforge.net/p/epics-pvdata/pvaPy/ci/default/tree/) is a simple and elegant Python API for pvAccess.

[Will Need a few words on how complete it is, and whether it incorporates CA access].

Use Matlab to talk to pvAccess PVs
-
em is a simple Matlab API for pvAccess.

[Will need a few words on how complete it is, and whether it incorporates CA access].

Monitor processing options
--------------------

This is only in pvdataCPP.
It is a way for a client to specify processing options for monitors.


