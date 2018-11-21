# Aware Device

[![CI Status](https://img.shields.io/awareframework/tetujin/com.aware.ios.sensor.device.svg?style=flat)](https://travis-ci.org/awareframework/com.aware.ios.sensor.device)
[![Version](https://img.shields.io/cocoapods/v/com.aware.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.aware.ios.sensor.device)
[![License](https://img.shields.io/cocoapods/l/com.aware.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.aware.ios.sensor.device)
[![Platform](https://img.shields.io/cocoapods/p/com.aware.ios.sensor.device.svg?style=flat)](https://cocoapods.org/pods/com.aware.ios.sensor.device)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 10 or later

## Installation

com.aware.ios.sensor.device is available through [CocoaPods](https://cocoapods.org).

1. To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.device'
```

2. Import com.aware.ios.sensor.battery library into your source code.
```swift
import com_awareframework_ios_sensor_device
```

## 
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

Yuuki Nishiyama, tetujin@ht.sfc.keio.ac.jp

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
