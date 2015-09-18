#BlueST SDK

This is an Android library that permit to easily access to the data exported by a Bluetooth  low energy device that follow the BlueST protocol.

[TOC]

##BlueST Protocol

###Advertise
The library will show only the device that has a vendor specific field formatted in this way:

|Length|  1       |1           | 1                |1          | 4              | 6        |
|------|----------|------------|------------------|-----------|----------------|----------|
|Name  | length   | field type | protocol version | device Id | feature mask   | Device MAC (optional)|
|Value | 0x07/0xD | 0xFF       | 0x01             | 0xXX      | 0xXXXXXXXX | 0xXXXXXXXXXXXX|


- The field length must be of 7 or 13 byte.

- The device Id is a number that identify the type of device, it is used for select different type of feature mask and be able to manage more than 32 feature.
Actually the value that are used are:
- 0x00 for a generic device.
- 0x01 is reserved for the STEVAL-WESU1 board
- 0x80 for a generic Nucleo board.

You should use a value between 0x02 and 0x7F if you are running the protocol in a specific board, or a value between 0x80 and 0xFF if the protocol is running in a Nucleo board.

- The feature mask is a bit field that permit to understand what characteristics/feature are exported by the board.
Actually the bit are mapped in this way:

|Bit|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|RFU|RFU|RFU|RFU|RFU|RFU|Proximity|Lux|Acc|Gyro|Mag|Pressure|Humidity|Temperature|Battery|RFU|

|Bit|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1|0|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|RFU|RFU|RFU|RFU|RFU|RFU|RFU|Sensor Fusion Compact|Sensor Fusion|RFU|RFU|Activity|Curry Position|RFU|RFU|RFU|
You can use one of the RFU bit or define a new device and decide how map the feature. 
For see how the data are exported by the already defined features, look the method  *int extractData(long,byte[],int)* inside the feature class definition.


- The device mac address is optional since Andorid has the API to read it, it has a meaning when you need to know the mac address in an iOS environmental


### Characteristics/Features
The characteristics manage by the SDK must have an UUID like: <code>*XXXXXXXX*-0001-11e1-ac36-0002a5d5c51b</code>.
The SDK will scan all the services looking for characteristics that match that pattern, so the service where they are stored doesnâ€™t matter.

The first part of the UUID will have the bit set to 1 for each feature exported by the characteristics.

In case of multiple feature mapped in a single characteristic the data must be in the same order of bit definition.

The characteristic data format must be like:

| Length |     2     |         >1         |          >1         |
|:------:|:---------:|:------------------:|:-------------------:|
|  Name  | Timestamp | first feature data | second feature data |

The first 2 byte are used to communicate  a time stamp that can be used to understand if we lost some package.

Since the Bluetooth low energy max length for a package is 20bytes, the max size for a feature data field is 18byte.


###Special Services
####[Debug](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Debug.html)
If available the debug service must have the UUID <code>0000000-0000E-11e1-9ab4-0002a5d5c51b</code> and will contains 2 characteristics:

- <code>00000001-000E-11e1-ac36-0002a5d5c51b</code> (Notify/Write) used for send string command to the board and notify the result.
- <code>00000002-000E-11e1-ac36-0002a5d5c51b</code> (Notify) it is used by the board for notify error message

####Configuration
If available the configuration service must have the UUID <code>00000000-000F-11e1-ac36-0002a5d5c51b</code> and will contain 2 characteristics:

- <code>00000002-000F-11e1-ac36-0002a5d5c51b</code> (Notify/Write): it can be used for send command/data to a specific feature.

The request message must have the format:

| Length |             4            |    1    | 0-15         |
|:------:|:------------------------:|:-------:|--------------|
|  Name  | Destination feature mask | Command Id | Command data |

Where the first 4 bytes will select the feature that have to receive the command/data package.

The optional  command answer must have the format:

| Length |     2     |          4          |      1     |     0-13    |
|:------:|:---------:|:-------------------:|:----------:|:-----------:|
|  Name  | Timestamp | Sender feature mask | Command Id | Answer data |

From the sdk point of view the messages are send using the method [Feature.sendCommand](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html#sendCommand-byte-byte:A-) and the answer will be notify with a call back in the method [Feature.parseCommandResponse](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html#parseCommandResponse-int-byte-byte:A-).

- <code>00000002-000F-11e1-ac36-0002a5d5c51b</code> (Read/Write/Notify): if available it is used for access to the board configuration register that can be modify using the [ConfigControl](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Config/ConfigControl.html) class.


##How to install the library
###Has external library
1. Clone the repository
2. Add the BlueSTSDK directory as submodule of your project: File->Import Module

###Has git submodule
1. Add the repository as submodule:

```Shell
$ git submodule add https://github.com/STclab/stm32nucleo-spirit1-lib.git BlueSTSDK
```
2. Add the sdk as project submodule in the *settings.gradle* adding the line:
<pre>include ':BlueSTSDK:BlueSTSDK'</pre>

##Main library actors

###[Manager](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Manager.html)
This is a singleton class that start/stop the discovery process and store the found nodes.
Before starting the scanning process is also possible define new deviceId and register/add new features for the already defined devices

The Manager will notify a node discovery through the [<code>Manager.ManagerListener</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Manager.ManagerListener.html) class.
Note that each call back are done asynchronous in a different thread for be asynchronous.

###[Node](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Node.html)
This class represent a remote device.

From this class you can recover what features are exported by the node and read write data from/to the device.
The node will export all the feature that are set to 1 in the advertise message, after the connection the feature that are found scanning the available characteristics will became enabled and will be possible request data.

It will notify change of the rssi through the [<code>Node.BleConnectionParamUpdateListener</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Node.BleConnectionParamUpdateListener.html) class.
It will notify change of its state through the [<code>Node.NodeStateListener</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Node.NodeStateListener.html) class.

The possible state are:
- **Idle**: the node is waiting for a connection and it is sending advertise message
- **Connecting**: we open a connection with the node, waiting to discovering the device services/characteristics
- **Connected**: we are connected with the node. Note: this status can be fired 2 times if we do a secure connection using bt pairing
- **Disconnecting**: we are closing the node connection, at the end the node will be in a idle status
- **Lost**: the device send an advertise, but now we didn't see any update
- **Unreachable**: we were connected with the node but now it is disappears  without disconnecting

Note that each call back are done asynchronous in a different thread for be asynchronous.


###[Feature](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html)
This class represent a data exported by the node.

Each Feature has an array of  [<code>Field</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Features/Field.html) that describe the data exported by the feature.

The data are received from a BLE characteristics and the class will create  [<code>Feature.Sample</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.Sample.html) that will be notify to the user using a listener pattern.

The data exported by the Sample can be extracted using the static utility methods that each class make available.

Note that each call back are done asynchronous in a different thread for be asynchronous.

The already available feature are inside the [Features package](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Features/package-frame.html).

####How to add a new Feature

1. Extend the class Feature: 
1.	Create an array of [<code>Feature.Field</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Features/Field.html) that will describe the data exported by the new  feature
2.	Create a constructor that accept only the node as parameter. From this constructor call the [super constructor](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html#Feature-java.lang.String-com.st.BlueSTSDK.Node-com.st.BlueSTSDK.Features.Field:A-), passing the feature name and the feature field
3.  Implement the method [<code>int Feature.extractData(long,byte[],int)</code>](https://stclab.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html#extractData-long-byte:A-int-) where you have to create the sample object and assign it to the instance variable <code>mLastSample</code>
3.  Create a utility static method that extract the data from the Feature.Sample class 
2. Before start the scanning register the new feature

```Java
// add the feature to the Nucleo device
byte deviceId = (byte) 0x80;
SparseArray temp = new SparceArray();
// the feature will be mapped in the characteristic 
// 0x10000000-0001-11e1-ac36-0002a5d5c51b
temp.append(0x10000000,MyNewFeature.class);
try {
Manager.addFeatureToNode(deviceId,temp);
} catch (InvalidFeatureBitMaskException e) {
e.printStackTrace();
}
```

##Docs
You can found the javadoc on this link: [JavaDoc](https://stclab.github.io/BlueSTSDK_Android/javadoc)

##License
COPYRIGHT(c) 2015 STMicroelectronics

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
3. Neither the name of STMicroelectronics nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.