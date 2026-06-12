import Foundation
import com_awareframework_ios_core
import GRDB

public struct DeviceData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_device"

    public var systemName: String = ""
    public var systemVersion: String = ""
    public var model: String = ""
    public var localizedModel: String = ""
    public var product: String = ""
    public var userInterfaceIdiom: Int = -1
    public var identifierForVendor: String = ""
    public var modelCode: String = ""
    public var osVersion: String = ""
    public var manufacturer: String = "Apple"

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp           = dict["timestamp"] as? Int64 ?? 0
        label               = dict["label"] as? String ?? ""
        deviceId            = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        systemName          = dict["systemName"] as? String ?? ""
        systemVersion       = dict["systemVersion"] as? String ?? ""
        model               = dict["model"] as? String ?? ""
        localizedModel      = dict["localizedModel"] as? String ?? ""
        product             = dict["product"] as? String ?? ""
        userInterfaceIdiom  = dict["userInterfaceIdiom"] as? Int ?? -1
        identifierForVendor = dict["identifierForVendor"] as? String ?? ""
        modelCode           = dict["modelCode"] as? String ?? ""
        osVersion           = dict["osVersion"] as? String ?? ""
        manufacturer        = dict["manufacturer"] as? String ?? "Apple"
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("systemName",.text).notNull()
            t.column("timezone",.integer).notNull(); t.column("os",.text).notNull()
            t.column("jsonVersion",.integer).notNull()
            t.column("systemVersion",.text).notNull(); t.column("model",.text).notNull()
            t.column("localizedModel",.text).notNull(); t.column("product",.text).notNull()
            t.column("userInterfaceIdiom",.integer).notNull()
            t.column("identifierForVendor",.text).notNull()
            t.column("modelCode",.text).notNull(); t.column("osVersion",.text).notNull()
            t.column("manufacturer",.text).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "systemName": systemName, "systemVersion": systemVersion, "model": model,
         "localizedModel": localizedModel, "product": product,
         "userInterfaceIdiom": userInterfaceIdiom, "identifierForVendor": identifierForVendor,
         "modelCode": modelCode, "osVersion": osVersion, "manufacturer": manufacturer]
    }
}
