import XCTest
import RealmSwift
import com_awareframework_ios_sensor_device

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSync(){
        //        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
        //            config.debug = true
        //            config.dbType = .REALM
        //        })
        //        sensor.start();
        //        sensor.enable();
        //        sensor.sync(force: true)
        
        //        let syncManager = DbSyncManager.Builder()
        //            .setBatteryOnly(false)
        //            .setWifiOnly(false)
        //            .setSyncInterval(1)
        //            .build()
        //
        //        syncManager.start()
    }
    
    func testStorage(){
        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.dbType = .REALM
        })
        sensor.start()
        if let engine = sensor.dbEngine {
            if let data = engine.fetch(DeviceData.TABLE_NAME, DeviceData.self, nil) as? Results<Object> {
                if data.count != 1{
                    XCTFail()
                }
            }
        }
        sensor.stop()
    }
    
    func testObserver(){
        
        class Observer:DeviceObserver{
            weak var deviceExpectation: XCTestExpectation?
            func onDeviceChanged(data: DeviceData) {
                self.deviceExpectation?.fulfill()
            }
        }
        
        let deviceObserverExpect = expectation(description: "device observer")
        let observer = Observer()
        observer.deviceExpectation = deviceObserverExpect
        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.sensorObserver = observer
        })
        sensor.start()
        wait(for: [deviceObserverExpect], timeout: 3)
        sensor.stop()
    }
    
    func testControllers(){
        
        let sensor = DeviceSensor()
        
        /// test set label action ///
        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(forName: .actionAwareDeviceSetLabel, object: nil, queue: .main) { (notification) in
            let dict = notification.userInfo;
            if let d = dict as? Dictionary<String,String>{
                XCTAssertEqual(d[DeviceSensor.EXTRA_LABEL], newLabel)
            }else{
                XCTFail()
            }
            expectSetLabel.fulfill()
        }
        sensor.set(label:newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)
        
        /// test sync action ////
        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareDeviceSync , object: nil, queue: .main) { (notification) in
            expectSync.fulfill()
            print("sync")
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)
        
        
        //// test start action ////
        let expectStart = expectation(description: "start")
        let observer = NotificationCenter.default.addObserver(forName: .actionAwareDeviceStart,
                                                              object: nil,
                                                              queue: .main) { (notification) in
                                                                expectStart.fulfill()
                                                                print("start")
        }
        sensor.start()
        wait(for: [expectStart], timeout: 5)
        NotificationCenter.default.removeObserver(observer)
        
        
        /// test stop action ////
        let expectStop = expectation(description: "stop")
        let stopObserver = NotificationCenter.default.addObserver(forName: .actionAwareDeviceStop, object: nil, queue: .main) { (notification) in
            expectStop.fulfill()
            print("stop")
        }
        sensor.stop()
        wait(for: [expectStop], timeout: 5)
        NotificationCenter.default.removeObserver(stopObserver)
    }

    func testDeviceData(){
        let data = DeviceData()
        let dict = data.toDictionary()
        
        XCTAssertEqual(dict["systemName"] as? String, "")
        XCTAssertEqual(dict["systemVersion"] as? String, "")
        XCTAssertEqual(dict["model"] as? String, "")
        XCTAssertEqual(dict["localizedModel"] as? String, "")
        XCTAssertEqual(dict["product"] as? String, "")
        XCTAssertEqual(dict["userInterfaceIdiom"] as? Int, -1)
        XCTAssertEqual(dict["identifierForVendor"] as? String, "")
        XCTAssertEqual(dict["modelCode"] as? String, "")
        XCTAssertEqual(dict["osVersion"] as? String, "")
        XCTAssertEqual(dict["manufacturer"] as? String, "Apple")
    }
    
}
