# BlueST SDK

BlueST is a multi-platform library (Android and iOS supported) that permits easy access to the data exported by a Bluetooth Low Energy (BLE) device that implements the BlueST protocol.

## BlueST Protocol

### Advertise
The library will show only the device that has a vendor-specific field formatted in the following way:

|Length|  1       |1           | 1                |1          | 4              | 6        |
|------|----------|------------|------------------|-----------|----------------|----------|
|Name  | Length   | Field Type | Protocol Version | Device Id | Feature Mask   | Device MAC (optional)|
|Value | 0x07/0xD | 0xFF       | 0x01             | 0xXX      | 0xXXXXXXXX | 0xXXXXXXXXXXXX|


 - The Field Length must be 7 or 13 bytes long.
 
 - The Device Id is a number that identifies the type of device. It is used to select different types of feature mask and can manage more than 32 features.
Currently used values are:
    - 0x00 for a generic device
    - 0x01 is reserved for the [STEVAL-WESU1](http://www.st.com/en/evaluation-tools/steval-wesu1.html) board
    - 0x02 is reserved for the [STEVAL-STLKT01V1 (SensorTile)](http://www.st.com/content/st_com/en/products/evaluation-tools/solution-evaluation-tools/sensor-solution-eval-boards/steval-stlkt01v1.html) board
    - 0x03 is reserved for the [STEVAL-BCNKT01V1 (BlueCoin)](http://www.st.com/content/st_com/en/products/evaluation-tools/solution-evaluation-tools/sensor-solution-eval-boards/steval-bcnkt01v1.html) board
    - 0x04 is reserved for the [STEVAL-IDB008V1/2 (BlueNRG-2)](http://www.st.com/content/st_com/en/products/evaluation-tools/solution-evaluation-tools/communication-and-connectivity-solution-eval-boards/steval-idb008v2.html) board
    - 0x05 is reserved for the [STEVAL-BCN002V1B (BlueNRG-Tile)](https://www.st.com/content/st_com/en/products/evaluation-tools/solution-evaluation-tools/sensor-solution-eval-boards/steval-bcn002v1b.html) board
    - 0x06 is reserved for the [STEVAL-MKSBOX1V1 (SensorTile.Box )](https://www.st.com/sensortilebox) board
    - 0x07 is reserved for the [B-L475E-IOT01A](https://www.st.com/en/evaluation-tools/b-l475e-iot01a.html) board
    - 0x80 to 0x8A for a differents ST Functional pack based on Nucleo boards

  You should use a value between 0x04 and 0x7F for your custom board, as values between 0x80 and 0xFF are reserved for ST Nucleo boards.
 
 - The feature mask is a bit field that provides information regarding what characteristics/features are exported by the board.
Currently, bits are mapped in the following way:

|Bit|31|30|29|28|27|26|25|24|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|RFU|ADPCM Sync|Switch|Direction of arrival|ADPC Audio|MicLevel|Proximity|Lux|

|Bit|23|22|21|20|19|18|17|16|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|Acc|Gyro|Mag|Pressure|Humidity|Temperature|Battery|Second Temperature|

|Bit|15|14|13|12|11|10|9|8|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|CO Sensor|STM32WB Reboot bit | STM32WB OTA Reboot bit|SD Logging|Beam forming|AccEvent|FreeFall|Sensor Fusion Compact|

|Bit|7|6|5|4|3|2|1|0|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|Sensor Fusion|Motion intensity|Compass|Activity|Carry Position|ProximityGesture|MemsGesture|Pedometer|

a custom bitmask is defined for the SensorTile.box board:

|Bit|31|30|29|28|27|26|25|24|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|FFT Amplitude|ADPCM Sync|Switch|MEMS Norm|ADPC Audio|MicLevel|Audio Classification|RFU|

|Bit|23|22|21|20|19|18|17|16|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|Acc|Gyro|Mag|Pressure|Humidity|Temperature|Battery|Second Temperature|

|Bit|15|14|13|12|11|10|9|8|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|RFU|Euler Angle|RFU|SD Logging|RFU|AccEvent|EventCounter|Sensor Fusion Compact|

|Bit|7|6|5|4|3|2|1|0|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Feature|Sensor Fusion|Motion intensity|Compass|Activity|Carry Position|RFU|MemsGesture|Pedometer|


You can use one of the RFU bits or define a new device and decide how to map the feature. 
To see how the data is exported by pre-defined features, consult the export method [<code> Feature.ExtractResult Feature.extractData(long,byte[],int)</code>](https://stmicroelectronics.github.io/BlueSTSDK_Android/javadoc/com/st/BlueSTSDK/Feature.html#extractData-long-byte:A-int-).  within the feature class definition.


- The device MAC address is optional and useful only for obtaining the device MAC address on an iOS device.


### Characteristics/Features
A bluetooth characteristics can export multiple features. The SDK is searching in all the services the know characteristics.
The features that are present in the advertise feature mask have an UUID such as: <code>*XXXXXXXX*-0001-11e1-ac36-0002a5d5c51b</code>, and are called "Basic Feature"
The first 32bits are interpreted as the feature mask, if they are set to 1 it meas that the characteristics is exporting the data of
that feature.

The other ST characteristics have the format: <code>*XXXXXXXX*-0002-11e1-ac36-0002a5d5c51b</code> and are called "extended Feature"
 
 In case of multiple features mapped in a single characteristic, the data must be in the same order as the bit mask.
 
 The characteristic data format must be:
 
| Length |     2     |         >1         |          >1         |       |
|:------:|:---------:|:------------------:|:-------------------:|:-----:|
|  Name  | Timestamp | First Feature Data | Second Feature Data | ..... |
  
 The first 2 bytes are used to communicate a time stamp. This is especially useful for recognizing any data loss.
 
 Since the BLE packet max length is 20 bytes, the max size for a feature data field is 18 bytes.
 
#### Remote Feature
This type of Feature are created for handle the case when the node collect information from 
other boards the user want to know also how produced the data.

For this type of feature a node ID is attach at the beginning of a standard feature update message.

For this type of feature the characteristic data format must be:
 
| Length |     2     |        2         |      >1       |       |
|:------:|:---------:|:----------------:|:-------------:|:-----:|
|  Name  |  NodeID   | Remote timestamp | Feature Data  | ..... |


### Special Services
#### [Debug](https://stmicroelectronics.github.io/BlueSTSDK_iOS/doc/html/interface_blue_s_t_s_d_k_debug.html)
If available, the debug service must have the UUID <code>00000000-000E-11e1-9ab4-0002a5d5c51b</code> and will contains 2 characteristics:

- <code>00000001-000E-11e1-ac36-0002a5d5c51b</code> (Notify/Write) is used to send string commands to the board and to notify the user of the result.
- <code>00000002-000E-11e1-ac36-0002a5d5c51b</code> (Notify) is used by the board to notify the user of an error message.

#### Configuration
If available, the configuration service must have the UUID <code>00000000-000F-11e1-9ab4-0002a5d5c51b</code> and will contain 2 characteristics:

- <code>00000002-000F-11e1-ac36-0002a5d5c51b</code> (Notify/Write): it can be used to send command/data to a specific feature.

    The request message must have the following format:
    
    | Length |             4            |    1    | 0-15         |
    |:------:|:------------------------:|:-------:|--------------|
    |  Name  | Destination Feature Mask | Command Id | Command Data |
  
    Where the first 4 bytes will select the recipient of the command/data package.
  
    The optional command answer must have the following format:
    
    | Length |     2     |          4          |      1     |     0-13    |
    |:------:|:---------:|:-------------------:|:----------:|:-----------:|
    |  Name  | Timestamp | Sender Feature Mask | Command Id | Answer Data |
    
  From the SDK point of view the messages are sent using the method [<code>BlueSTSDKFeature::sendCommand:data:</code>](https://stmicroelectronics.github.io/BlueSTSDK_iOS/doc/html/interface_blue_s_t_s_d_k_feature.html#a669cd03b94a0d0c9649ecef6af22645b) and the answer is notified with a callback passed through the method [<code>BlueSTSDKFeature::parseCommandResponseWithTimestamp:commandType::data:</code>](https://stmicroelectronics.github.io/BlueSTSDK_iOS/doc/com/html/interface_blue_s_t_s_d_k_feature.html#a16e1c4d33cc52bc5b19f55c126e).
 
  If this characteristic does not exist, but the characteristics that export the feature is in 
  write mode, the *command id* and the *command data* are sending directly to the feature 
  characteristics. In this case is not possible answer to the command.

- <code>00000001-000F-11e1-ac36-0002a5d5c51b</code> (Read/Write/Notify): if available it is used to access the board configuration register that can be modified using the [<code>BlueSTSDKConfigControl</code>](https://stmicroelectronics.github.io/BlueSTSDK_iOS/doc/html/interface_blue_s_t_s_d_k_config_control.html) class.

### Example
The SDK is used in different application as:
 - [ST BLE Sensor](https://github.com/STMicroelectronics/STBLESensor_iOS.git)

## Download the source code

To clone the repository:

```Shell
https://github.com/STMicroelectronics/BlueSTSDK_iOS.git
```

## License

Copyright (c) 2017  STMicroelectronics – All rights reserved
The STMicroelectronics corporate logo is a trademark of STMicroelectronics

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.

- Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
STMicroelectronics company nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

- All of the icons, pictures, logos and other images that are provided with the source code
in a directory whose title begins with st_images may only be used for internal purposes and
shall not be redistributed to any third party or modified in any way.

- Any redistributions in binary form shall not include the capability to display any of the
icons, pictures, logos and other images that are provided with the source code in a directory
whose title begins with st_images.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
