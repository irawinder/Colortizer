Meteor.js Java DDP Client
=========================

Origins/Acknowledgements
------------------------
This is a fork and fairly big fleshing out of [Peter Kutrumbos' 
DDP Client](https://github.com/kutrumbo/java-ddp-client).

Differences include:

* switched to using Gradle for builds to remove duplicated Websocket 
  and Gson libraries from source code
* added JUnit testing for all the DDP messages/results and auth/collections
* returns DDP command results and removes handlers when done
* handles all the DDP message fields (switched to static strings instead of
  using extraneous class) from server
* handles all the DDP message types from the server
* websocket closed/error state changes converted to regular observer events instead
  of dumping errors to System.out
* added full Javadocs
* use slf4j for logging instead of java.util.Logging
* added a disconnect method to close the websocket connection

Usage
-----
The best thing to do is to look at the JUnit tests.  The tests are separated 
into authentication tests and collection tests.  

The DDPTestClientObserver in the JUnit tests is the core handler of DDP message 
results and is a simple example of holding enough state to implement a simple 
Meteor client.  Note that in a real application, you'll probably want to use an 
eventbus to implement the DDP message handling.

Note that you may want to use a local SQLite DB to store the data instead of using 
Maps if you are memory constrained and/or if you need to do any sorting.  Otherwise,
you'll have to have separate SortedMap collection for each of your sorts.

If you're planning to use this with Android, look at the 
[Android DDP Library](https://github.com/kenyee/android-ddp-client)
which builds on top of this library
to make it easier to work with an Android application.

If you see this error:
    Error generating final archive: Found duplicate file for APK: LICENSE.txt
    Origin 1: C:\Users\you\.gradle\caches\artifacts-23\filestore\junit\junit\4.11\jar\4e031bb61df09069aeb2bffb4019e7a5034a4ee0\junit-4.11.jar
    Origin 2: C:\Users\you\.gradle\caches\artifacts-23\filestore\org.hamcrest\hamcrest-core\1.3\jar\42a25dc3219429f0e5d060061f71acb49bf010a0\hamcrest-core-1.3.jar
delete the LICENSE.txt from one of those jar files using "zip -d".  This is a bug in
Eclipse's Gradle plugin.

Design
------
The Map&lt;String,Object> data type is used extensively; this is an interface 
so a ConcurrentHashMap or LinkedHashmap is used underneath.  It's a reasonable Java 
analogue to Javascripts's associative arrays.  Google's GSON library is used to convert 
JSON to maps and ArrayLists (used for arrays of strings or objects).  

One important thing to note is that integer values are always represented as 
Doubles in JSON so that's how they're translated by the GSON library.  If you're 
sending numbers to Meteor, note that they will be sent as Doubles and what 
you get back from Meteor as numbers show up as Doubles.  This isn't an issue in
Javascript because it will autoconvert objects to the needed datatype, but Java
is strongly typed, so you have to do the conversions yourself.

Javascript's callback handling is done using Java's Observer/Listener pattern,
which is what most users are familiar with if they've used any of the JDK UI
frameworks.  When issuing a DDP command, you can attach a listener by creating one
and then overriding any methods you want to handle:

	ddp.call("login", params, new DDPListener() {
		@Override
		void onResult(Map<String, Object> resultFields) {
			if (resultFields.containsKey(DdpMessageField.ERROR)) {
				Map<String, Object> error = (Map<String, Object>) resultFields.get(DdpMessageField.ERROR);
				errorReason = (String) error.get("reason");
				System.err.println("Login failure: " + errorReason);
			} else {
				loggedIn = true;
			}
		}
	});


DDP Protocol Version
--------------------
This library currently supports DDP Protocol 1 (previous version supported pre1).

Maven Artifact
--------------
This library is in the Maven Central Library hosted by Sonatype.
In Gradle, you can reference it with this in your dependencies:

    compile group: 'com.keysolutions', name: 'java-ddp-client', version: '1.0.0.+'

And in Maven, you can reference it with this:

    <dependency>
      <groupId>com.keysolutions</groupId>
      <artifactId>java-ddp-client</artifactId>
      <version>1.0.0.1</version>
      <type>pom</type>
    </dependency>

The version of the library will match the Meteor.js DDP protocol version with the 
library revision in the last digit (0.5.7.1, 0.5.7.2, etc.)

* 0.5.7.2 - switched to SLF4J logging library instead of using java.util.Logging
* 0.5.7.3 - added disconnect() method
* 0.5.7.4 - fix Maven dynamic version syntax
* 0.5.7.5 - retargeted to JDK 1.5 so Mac OSX users won't have problem linking
* 0.5.7.6 - add unit tests for add/delete field
* 1.0.0.0 - added ping/pong support and bumped version to match Meteor's DDP version
* 1.0.0.1 - fix SSL support so it uses Java's default trusted CA certs
* 1.0.0.2 - fix trustmanager SSL handling when reconnecting; added ability to pass in trustmanager; add reconnect unit test
* 1.0.0.3 - update to Apache Commons 4; add custom Gson constructor

To-Do
-----
* Add SRP (using Nimbus SRP library?) and OAuth login support.
* Add "create new user" test.
* Test all possible EJSON data types.
* Handle insertBefore and insertAfter collection update messages (may be 
difficult because LinkedHashMap can only append) when Meteor adds them.
