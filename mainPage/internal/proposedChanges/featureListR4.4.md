Summary of Release 4.4 Features
==================================

A more  detailed description of new features for release 4.4 is provided by
[proposedChanges_3_0.html](http://epics-pvdata.sourceforge.net/internal/proposedChanges/proposedChanges_3_0.html)

Note that this document refers to release 3_0 instead of release 4.3.
This is because pvData and pvAccess both used a tag of 3.0.x for the
version that became part of EPICS Version 4 release 4.3.

The main features and changes since release 4.3 are:

* array semantics now enforce Copy On Write.
* union is new type.
* pvAccess API changes.
* codec based pvAccess implementation.
* pvAccess multicast support.
* pluggable pvAccess security API.
* copy is new.
* monitorPlugin is new.

Array Semantics
---------------

PVArray and derived classes now enforce COW (Copy On Wrire) semantics.
In addition the raw data is managed via a new class shared_vector,
which is like std::vector except that std::shared_pointer is used
to hold the raw data array.

This is only for the C++ impementation.
For Java nothing is currently planned.

Union and UnionArray are new Types.
----------------------------------

A union is like a structure that has a single sub-field with
a type that can be changed dynamically.
For a varient union the type can be any type.
For a regular union the type can be a fixed set of types as determined
by the introspection interface.

pvAccess API changes
--------------------

This applies to channelGet, channelPut, channelPutGet, and monitor.
For release 3.3 the PVData and BitSet arguments are provided to the clent via
the connection callback.
This is changed so that the connction callback returns introspection interfaces.
The PVData and BitSets are now arguments provides by the
component that provides the data.

channelArray has the following changes:

* A new argument stride is present.
* length, offset, capacity, and stride are now of type size_t instead of int.
* a new method getLength is available.

These changes apply to both C++ and Java.
For Java, however, the length, offset, capacity, and stride  are still int.

Codec based pvAccess implementation
-----------------------------------

Codec implementation decouples protocol from transport. All the protocol
specific code is encapluslated in one abstract class. Transport specific
code (e.g. TCP, UDP, shared memory, zeroMQ) needs to be implemented in order
to get fully functional pvAccess communication.


pvAccess multicast support
-----------------------------------

Implementation of multicast used for channel/service discovery and shared data transfer.


Pluggable pvAccess security API
-------------------------------

pvAccess security plugin API was added that allows pluggable
implementation of specific security schemes.


Copy is new
-----------

Both pvIOCJava and pvDatabaseCPP had a facility pvCopy,
which together with pvRequest allows client access to an arbitrary subset
of the data in the structure associated with a pvAccess channel.

CreateRequest, which is used by clients to create a pvRequest,
has been moved from pvAccess to pvData.
In addition a new facility pvCopy is now provided by pvData.
It is the old pvCopy with all dependence on PVRecord removed.
Thus it only depends on pvData.

The old implementation of pvCopy in pvIOCJava and pvDatabaseCPP has been
changed to use the pvCopy from pvData.

Monitor Plugin is new
--------------------

This is only in pvdataCPP.
It is a way for a client to specify processing options for monitors.

The semantics and usefullness are still a topic being debated.
