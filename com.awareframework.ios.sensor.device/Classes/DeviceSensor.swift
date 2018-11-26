//
//  DeviceSensor.swift
//  com.aware.ios.sensor.device
//
//  Created by Yuuki Nishiyama on 2018/11/06.
//

import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_core

public protocol DeviceOserver{
    func onDeviceChanged(data: DeviceData)
}

extension Notification.Name{
    public static let actionAwareDevice       = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE)
    public static let actionAwareDeviceStart  = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_START)
    public static let actionAwareDeviceStop   = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_STOP)
    public static let actionAwareDeviceSync   = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_SYNC)
    public static let actionAwareDeviceSetLabel = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_SET_LABEL)
}

extension DeviceSensor{
    public static let TAG = "AWARE::Device"
    public static let ACTION_AWARE_DEVICE = "ACTION_AWARE_DEVICE"
    public static let ACTION_AWARE_DEVICE_START = "com.awareframework.android.sensor.device.SENSOR_START"
    public static let ACTION_AWARE_DEVICE_STOP  = "com.awareframework.android.sensor.device.SENSOR_STOP"
    public static let ACTION_AWARE_DEVICE_SET_LABEL = "com.awareframework.android.sensor.device.SET_LABEL"
    public static let EXTRA_LABEL = "label"
    public static let ACTION_AWARE_DEVICE_SYNC = "com.awareframework.android.sensor.device.SENSOR_SYNC"

}

public class DeviceSensor: AwareSensor {
    
    public var CONFIG = Config()
    
    public class Config:SensorConfig{
        public var sensorObserver:DeviceOserver?
        
        public override init(){
            super.init()
            dbPath = "aware_device"
        }
        
        public convenience init(_ json:JSON){
            self.init()
        }
        
        public func apply(closure:(_ config: DeviceSensor.Config) -> Void) -> Self {
            closure(self)
            return self
        }
    }
    
    public override convenience init(){
        self.init(DeviceSensor.Config())
    }
    
    public init(_ config:DeviceSensor.Config){
        super.init()
        CONFIG = config
        initializeDbEngine(config: config)
    }
    
    public override func start() {
        let device = UIDevice.current
        let data = DeviceData()
        

        // e.g., My iPhone
        data.label = device.name
        // e.g., iOS
        data.systemName = device.systemName
        // e.g., 12.1
        data.systemVersion = device.systemVersion
        // e.g, iPhone 7
        data.product = device.type.rawValue
        // e.g., iPhone
        data.model = device.model
        // e.g., iPhone
        data.localizedModel = device.localizedModel
        // e.g., phone, pad, tv, or carPlay
        data.userInterfaceIdiom = device.userInterfaceIdiom.rawValue
        // e.g., uuid
        if let idForVendor = device.identifierForVendor {
            data.identifierForVendor = idForVendor.uuidString
        }
        // e.g., iPhone9,1
        if let code = device.modelCode {
            data.modelCode = code
        }
        // e.g, Darwin Kernel Version 18.2.0: Tue Oct 16 21:02:38 PDT 2018; root:xnu-4903.222.5~1/RELEASE_ARM64_T8010
        if let v = device.version {
            data.version = v
        }
        
        if let engine = self.dbEngine {
            engine.save(data, DeviceData.TABLE_NAME)
        }
        
        if let observer = self.CONFIG.sensorObserver {
            observer.onDeviceChanged(data: data)
        }
        
        self.notificationCenter.post(name: .actionAwareDeviceStart, object:nil )
        self.notificationCenter.post(name: .actionAwareDevice, object: nil)
    }
    
    public override func stop() {
        self.notificationCenter.post(name: .actionAwareDeviceStop, object:nil )
    }
    
    public override func sync(force: Bool = false) {
        if let dbEngine = self.dbEngine{
            dbEngine.startSync(DeviceData.TABLE_NAME, DbSyncConfig().apply{config in
                config.debug = self.CONFIG.debug
            })
            self.notificationCenter.post(name: .actionAwareDeviceSync, object: nil)
        }
    }
}


/**
 * https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
 */

public enum Model : String {
    case simulator     = "simulator/sandbox",
    //iPod
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    //iPad
    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPad5              = "iPad 5", //aka iPad 2017
    iPad6              = "iPad 6", //aka iPad 2018
    //iPad mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    //iPad pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    //iPhone
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
//MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    public var modelCode:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode
    }
    
    public var release:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let release = withUnsafePointer(to: &systemInfo.release) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return release
    }
    
    public var version:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let version = withUnsafePointer(to: &systemInfo.version) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return version
    }
    
    public var nodename:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let nodename = withUnsafePointer(to: &systemInfo.nodename) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return nodename
    }
    
    public var sysname:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let sysname = withUnsafePointer(to: &systemInfo.sysname) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return sysname
    }
    
    public var type: Model {
        let modelCode = self.modelCode
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            //iPad
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad6,11"  : .iPad5, //aka iPad 2017
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6, //aka iPad 2018
            "iPad7,6"   : .iPad6,
            //iPad mini
            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            //iPad pro
            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,4" : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,5" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            //AppleTV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
