//
//  DeviceSensor.swift
//  com.aware.ios.sensor.device
//
//  Created by Yuuki Nishiyama on 2018/11/06.
//

import UIKit
import com_awareframework_ios_core

public protocol DeviceObserver{
    func onDeviceChanged(data: DeviceData)
}

extension Notification.Name{
    public static let actionAwareDevice       = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE)
    public static let actionAwareDeviceStart  = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_START)
    public static let actionAwareDeviceStop   = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_STOP)
    public static let actionAwareDeviceSync   = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_SYNC)
    public static let actionAwareDeviceSetLabel = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_SET_LABEL)
    public static let actionAwareDeviceSyncCompletion  = Notification.Name(DeviceSensor.ACTION_AWARE_DEVICE_SYNC_COMPLETION)
}

extension DeviceSensor{
    public static let TAG = "AWARE::Device"
    public static let ACTION_AWARE_DEVICE = "com.awareframework.ios.sensor.device"
    public static let ACTION_AWARE_DEVICE_START = "com.awareframework.ios.sensor.device.SENSOR_START"
    public static let ACTION_AWARE_DEVICE_STOP  = "com.awareframework.ios.sensor.device.SENSOR_STOP"
    public static let ACTION_AWARE_DEVICE_SET_LABEL = "com.awareframework.ios.sensor.device.SET_LABEL"
    public static let EXTRA_LABEL = "label"
    public static let ACTION_AWARE_DEVICE_SYNC = "com.awareframework.ios.sensor.device.SENSOR_SYNC"
    
    public static let ACTION_AWARE_DEVICE_SYNC_COMPLETION = "com.awareframework.ios.sensor.device.SENSOR_SYNC_COMPLETION"
    public static let EXTRA_STATUS = "status"
    public static let EXTRA_ERROR = "error"
}

public class DeviceSensor: AwareSensor {
    
    public var CONFIG = Config()
    
    public class Config:SensorConfig{
        public var sensorObserver:DeviceObserver?
        
        public override init(){
            super.init()
            dbPath = "aware_device"
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
        super.syncConfig = DbSyncConfig().apply { c in
            c.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.device.sync.queue")
        }
    }
    
    public override func start() {
        let device = UIDevice.current
        var data = DeviceData()
        data.timestamp = Int64(Date().timeIntervalSince1970 * 1000)

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
            data.osVersion = v
        }
        
        if let engine = self.dbEngine {
            engine.save([data])
        }
        
        if let observer = self.CONFIG.sensorObserver {
            observer.onDeviceChanged(data: data)
        }
        
        self.notificationCenter.post(name: .actionAwareDeviceStart, object:self )
        self.notificationCenter.post(name: .actionAwareDevice, object: self)
    }
    
    public override func stop() {
        self.notificationCenter.post(name: .actionAwareDeviceStop, object:self )
    }
    
    public override func sync(force: Bool = false) {
        guard let engine = self.dbEngine, let syncConfig = self.syncConfig else { return }
        syncConfig.debug = self.CONFIG.debug
        syncConfig.completionHandler = { (status, error) in
            var userInfo: Dictionary<String,Any> = ["status": status]
            if let e = error { userInfo["error"] = e }
            self.notificationCenter.post(name: .actionAwareDeviceSyncCompletion, object: self, userInfo: userInfo)
        }
        engine.startSync(syncConfig)
        self.notificationCenter.post(name: .actionAwareDeviceSync, object: self)
    }
    
    public override func set(label:String){
        self.CONFIG.label = label
        self.notificationCenter.post(name: .actionAwareDeviceSetLabel,
                                     object: self,
                                     userInfo:[DeviceSensor.EXTRA_LABEL:label])
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
    iPadAir            = "iPad Air",
    iPadAir2           = "iPad Air 2",
    iPadAir3           = "iPad Air 3",
    iPadAir4           = "iPad Air 4",
    iPadAir5           = "iPad Air 5",
    iPadAirM2          = "iPad Air (M2)",
    iPad5              = "iPad 5",
    iPad6              = "iPad 6",
    iPad7              = "iPad 7",
    iPad8              = "iPad 8",
    iPad9              = "iPad 9",
    iPad10             = "iPad 10",
    //iPad mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    iPadMini5          = "iPad Mini 5",
    iPadMini6          = "iPad Mini 6",
    //iPad Pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro11          = "iPad Pro 11\"",
    iPadPro11_2nd      = "iPad Pro 11\" (2nd gen)",
    iPadPro11_3rd      = "iPad Pro 11\" (3rd gen)",
    iPadPro11_4th      = "iPad Pro 11\" (4th gen)",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 12.9\" (2nd gen)",
    iPadPro3_12_9      = "iPad Pro 12.9\" (3rd gen)",
    iPadPro4_12_9      = "iPad Pro 12.9\" (4th gen)",
    iPadPro5_12_9      = "iPad Pro 12.9\" (5th gen)",
    iPadPro6_12_9      = "iPad Pro 12.9\" (6th gen)",
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
    iPhoneSE2          = "iPhone SE (2nd gen)",
    iPhoneSE3          = "iPhone SE (3rd gen)",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    iPhone11           = "iPhone 11",
    iPhone11Pro        = "iPhone 11 Pro",
    iPhone11ProMax     = "iPhone 11 Pro Max",
    iPhone12Mini       = "iPhone 12 Mini",
    iPhone12           = "iPhone 12",
    iPhone12Pro        = "iPhone 12 Pro",
    iPhone12ProMax     = "iPhone 12 Pro Max",
    iPhone13Mini       = "iPhone 13 Mini",
    iPhone13           = "iPhone 13",
    iPhone13Pro        = "iPhone 13 Pro",
    iPhone13ProMax     = "iPhone 13 Pro Max",
    iPhone14           = "iPhone 14",
    iPhone14Plus       = "iPhone 14 Plus",
    iPhone14Pro        = "iPhone 14 Pro",
    iPhone14ProMax     = "iPhone 14 Pro Max",
    iPhone15           = "iPhone 15",
    iPhone15Plus       = "iPhone 15 Plus",
    iPhone15Pro        = "iPhone 15 Pro",
    iPhone15ProMax     = "iPhone 15 Pro Max",
    iPhone16           = "iPhone 16",
    iPhone16Plus       = "iPhone 16 Plus",
    iPhone16Pro        = "iPhone 16 Pro",
    iPhone16ProMax     = "iPhone 16 Pro Max",
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
//MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    var modelCode:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode
    }
    
    var release:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let release = withUnsafePointer(to: &systemInfo.release) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return release
    }
    
    var version:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let version = withUnsafePointer(to: &systemInfo.version) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return version
    }
    
    var nodename:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let nodename = withUnsafePointer(to: &systemInfo.nodename) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return nodename
    }
    
    var sysname:String?{
        var systemInfo = utsname()
        uname(&systemInfo)
        let sysname = withUnsafePointer(to: &systemInfo.sysname) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return sysname
    }
    
    var type: Model {
        let modelCode = self.modelCode
        let modelMap : [ String : Model ] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            "arm64"      : .simulator,
            //iPod
            "iPod1,1"    : .iPod1,
            "iPod2,1"    : .iPod2,
            "iPod3,1"    : .iPod3,
            "iPod4,1"    : .iPod4,
            "iPod5,1"    : .iPod5,
            //iPad
            "iPad2,1"    : .iPad2,
            "iPad2,2"    : .iPad2,
            "iPad2,3"    : .iPad2,
            "iPad2,4"    : .iPad2,
            "iPad3,1"    : .iPad3,
            "iPad3,2"    : .iPad3,
            "iPad3,3"    : .iPad3,
            "iPad3,4"    : .iPad4,
            "iPad3,5"    : .iPad4,
            "iPad3,6"    : .iPad4,
            "iPad4,1"    : .iPadAir,
            "iPad4,2"    : .iPadAir,
            "iPad4,3"    : .iPadAir,
            "iPad5,3"    : .iPadAir2,
            "iPad5,4"    : .iPadAir2,
            "iPad11,3"   : .iPadAir3,
            "iPad11,4"   : .iPadAir3,
            "iPad13,1"   : .iPadAir4,
            "iPad13,2"   : .iPadAir4,
            "iPad13,16"  : .iPadAir5,
            "iPad13,17"  : .iPadAir5,
            "iPad14,8"   : .iPadAirM2,
            "iPad14,9"   : .iPadAirM2,
            "iPad6,11"   : .iPad5,
            "iPad6,12"   : .iPad5,
            "iPad7,5"    : .iPad6,
            "iPad7,6"    : .iPad6,
            "iPad7,11"   : .iPad7,
            "iPad7,12"   : .iPad7,
            "iPad11,6"   : .iPad8,
            "iPad11,7"   : .iPad8,
            "iPad12,1"   : .iPad9,
            "iPad12,2"   : .iPad9,
            "iPad13,18"  : .iPad10,
            "iPad13,19"  : .iPad10,
            //iPad mini
            "iPad2,5"    : .iPadMini,
            "iPad2,6"    : .iPadMini,
            "iPad2,7"    : .iPadMini,
            "iPad4,4"    : .iPadMini2,
            "iPad4,5"    : .iPadMini2,
            "iPad4,6"    : .iPadMini2,
            "iPad4,7"    : .iPadMini3,
            "iPad4,8"    : .iPadMini3,
            "iPad4,9"    : .iPadMini3,
            "iPad5,1"    : .iPadMini4,
            "iPad5,2"    : .iPadMini4,
            "iPad11,1"   : .iPadMini5,
            "iPad11,2"   : .iPadMini5,
            "iPad14,1"   : .iPadMini6,
            "iPad14,2"   : .iPadMini6,
            //iPad Pro
            "iPad6,3"    : .iPadPro9_7,
            "iPad6,4"    : .iPadPro9_7,
            "iPad7,3"    : .iPadPro10_5,
            "iPad7,4"    : .iPadPro10_5,
            "iPad8,1"    : .iPadPro11,
            "iPad8,2"    : .iPadPro11,
            "iPad8,3"    : .iPadPro11,
            "iPad8,4"    : .iPadPro11,
            "iPad8,9"    : .iPadPro11_2nd,
            "iPad8,10"   : .iPadPro11_2nd,
            "iPad13,4"   : .iPadPro11_3rd,
            "iPad13,5"   : .iPadPro11_3rd,
            "iPad13,6"   : .iPadPro11_3rd,
            "iPad13,7"   : .iPadPro11_3rd,
            "iPad14,3"   : .iPadPro11_4th,
            "iPad14,4"   : .iPadPro11_4th,
            "iPad6,7"    : .iPadPro12_9,
            "iPad6,8"    : .iPadPro12_9,
            "iPad7,1"    : .iPadPro2_12_9,
            "iPad7,2"    : .iPadPro2_12_9,
            "iPad8,5"    : .iPadPro3_12_9,
            "iPad8,6"    : .iPadPro3_12_9,
            "iPad8,7"    : .iPadPro3_12_9,
            "iPad8,8"    : .iPadPro3_12_9,
            "iPad8,11"   : .iPadPro4_12_9,
            "iPad8,12"   : .iPadPro4_12_9,
            "iPad13,8"   : .iPadPro5_12_9,
            "iPad13,9"   : .iPadPro5_12_9,
            "iPad13,10"  : .iPadPro5_12_9,
            "iPad13,11"  : .iPadPro5_12_9,
            "iPad14,5"   : .iPadPro6_12_9,
            "iPad14,6"   : .iPadPro6_12_9,
            //iPhone
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,4"  : .iPhone7plus,
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
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax,
            "iPhone14,2" : .iPhone13Pro,
            "iPhone14,3" : .iPhone13ProMax,
            "iPhone14,4" : .iPhone13Mini,
            "iPhone14,5" : .iPhone13,
            "iPhone14,6" : .iPhoneSE3,
            "iPhone14,7" : .iPhone14,
            "iPhone14,8" : .iPhone14Plus,
            "iPhone15,2" : .iPhone14Pro,
            "iPhone15,3" : .iPhone14ProMax,
            "iPhone15,4" : .iPhone15,
            "iPhone15,5" : .iPhone15Plus,
            "iPhone16,1" : .iPhone15Pro,
            "iPhone16,2" : .iPhone15ProMax,
            "iPhone17,1" : .iPhone16Pro,
            "iPhone17,2" : .iPhone16ProMax,
            "iPhone17,3" : .iPhone16,
            "iPhone17,4" : .iPhone16Plus,
            //AppleTV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String(modelCode ?? "")] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String(simModelCode)] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
