# Aware Device

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.device.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.device)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.device)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.device)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.device)

The device sensor monitors the device manufacturer, model, operating system version and other information. The information is provided by [UIDevice](https://developer.apple.com/documentation/uikit/uidevice).

## Requirements
iOS 10 or later

## Installation

com.aware.ios.sensor.device is available through [CocoaPods](https://cocoapods.org).

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.device'
```

2. Import com.awareframework.ios.sensor.device library into your source code.
```swift
import com_awareframework_ios_sensor_device
```

## Public functions

### DeviceSensor

+ `init(config:DeviceSensor.Config?)` : Initializes the device sensor with the optional configuration.
+ `start()`: Starts the locations sensor with the optional configuration.
+ `stop()`: Stops the service.

### DeviceSensor.Config

Class to hold the configuration of the sensor.

#### Fields

+ `sensorObserver: DeviceObserver?`: Callback for live data updates.
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to `Logcat`. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.REALM`)
+ `dbPath: String` Path of the database. (default = "aware_screen")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

+ `DeviceSensor.ACTION_AWARE_DEVICE` fired when device is profiled.

## Data Representations

### Device Data
| Field        | Type   | Description                                                            |
| ------------ | ------ | ---------------------------------------------------------------------- |
| systemName |  String |  The name of the operating system running on the device represented by the receiver. (e.g., iOS)|
| systemVersion | String | The current version of the operating system. (e.g., 12.1)|
| product | String | The product name of the device. (e.g., iPhone 7) |
| model | String | The model of the device. (e.g., iPhone) |
| localizedModel | String | The model of the device as a localized string. (e.g., iPhone)|
| userInterfaceIdiom| Int | The style of interface to use on the current device. (0=phone, 1=pad, 2=tv, or 3=carPlay) |
| identifierForVendor | String | An alphanumeric string that uniquely identifies a device to the app’s vendor .|
| modeCode | String | The model code of the device (e.g., iPhone9,1)|
| osVersion  | String | OS version information from utsname.h (e.g., Darwin Kernel Version 18.0.0: Wed Aug 22 20:13:40 PDT 2018; root:xnu-4903.201.2~1/RELEASE_X86_64)|
| manufacturer | String | Device's manufacturer name (e.g., Apple) |
| deviceId     | String | AWARE device UUID                        |
| label        | String | Customizable label. Useful for data calibration or traceability        |
| timestamp    | Int64  | unixtime milliseconds since 1970                                       |
| timezone     | Int    | Timezone of the device                                 |
| os           | String | Operating system of the device (ex. android)                           |

## Example Usage
```swift
let deviceSensor = DeviceSensor.init(DeviceSensor.Config().apply{config in
    config.debug = true
    config.dbType = .REALM
    config.sensorObserver = Observer()
})
deviceSensor.start()
```

```swift
class Observer:DeviceOserver{
    func onDeviceChanged(data: DeviceData) {
        // Your code here..
    }
}

```

## Author

Yuuki Nishiyama, yuuki.nishiyama@oulu.fi

## Related Links
[ Apple | UIDevice ](https://developer.apple.com/documentation/uikit/uidevice)

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
