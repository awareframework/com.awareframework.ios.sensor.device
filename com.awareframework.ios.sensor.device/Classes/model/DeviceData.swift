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
    
    @objc dynamic public var board: String = ""
    @objc dynamic public var brand: String = ""
    @objc dynamic public var device: String   = ""
    @objc dynamic public var buildId: String  = ""
    @objc dynamic public var hardware: String = ""
    @objc dynamic public var manufacturer: String = ""
    @objc dynamic public var model: String   = ""
    @objc dynamic public var product: String = ""
    @objc dynamic public var serial: String  = "" // does not suppor on iOS
    @objc dynamic public var releaseNumber: String = ""
    @objc dynamic public var releaseType: String   = ""
    @objc dynamic public var sdk: Double = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["board"] = board
        dict["brand"] = brand
        dict["device"] = device
        dict["buildId"] = buildId
        dict["hardware"] = hardware
        dict["manufacturer"] = manufacturer
        dict["model"] = model
        dict["product"] = product
        dict["serial"] = serial
        dict["release"] = releaseNumber
        dict["sdk"] = sdk
        return dict
    }
    
}
