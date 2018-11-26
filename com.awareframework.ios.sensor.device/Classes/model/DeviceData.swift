//
//  DeviceData.swift
//  com.aware.ios.sensor.device
//
//  Created by Yuuki Nishiyama on 2018/11/06.
//

import UIKit
import com_awareframework_ios_sensor_core

public class DeviceData: AwareObject {
    public static let TABLE_NAME = "deviceData"
    
    // The name of the operating system running on the device represented by the receiver.
    @objc dynamic public var systemName: String = ""
    
    // The current version of the operating system.
    @objc dynamic public var systemVersion: String = ""
    
    // The model of the device (e.g., iPhone )
    @objc dynamic public var model : String = ""
    
    // The model of the device as a localized string. (e.g., iPhone)
    @objc dynamic public var localizedModel : String = ""
    
    // (e.g., iPhone 7)
    @objc dynamic public var product: String = ""
    
    // The style of interface to use on the current device. (phone, pad, tv, or carPlay)
    @objc dynamic public var userInterfaceIdiom: Int = -1
    
    // An alphanumeric string that uniquely identifies a device to the app’s vendor.
    @objc dynamic public var identifierForVendor: String = ""
    
    // Model code
    @objc dynamic public var modelCode : String = ""
        
    // device version (e.g., Darwin Kernel Version 18.0.0: Wed Aug 22 20:13:40 PDT 2018; root:xnu-4903.201.2~1/RELEASE_X86_64)
    @objc dynamic public var version : String = ""
    
    @objc dynamic public var manufacturer : String = "Apple"
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["systemName"] = systemName
        dict["systemVersion"] = systemVersion
        dict["model"] = model
        dict["localizedModel"] = localizedModel
        dict["product"] = product
        dict["userInterfaceIdiom"] = userInterfaceIdiom
        dict["identifierForVendor"] = identifierForVendor
        dict["modelCode"] = modelCode
        dict["version"] = version
        dict["manufacturer"] = manufacturer        
        return dict
    }
    
}
