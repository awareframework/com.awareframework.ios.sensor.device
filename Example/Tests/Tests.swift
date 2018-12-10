import XCTest
import RealmSwift
import com_awareframework_ios_sensor_core
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
    
    func testStorage(){
        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.dbType = .REALM
        })
        sensor.start()
        if let engine = sensor.dbEngine {
            engine.fetch(DeviceData.self, nil){ (resultsObject, error) in
                if let results = resultsObject as? Results<Object>{
                    if results.count != 1 {
                        XCTFail()
                    }
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
    
    
    func testSyncModule(){
        #if targetEnvironment(simulator)
        
        print("This test requires a real device.")
        
        #else
        // success //
        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.debug = true
            config.dbType = .REALM
            config.dbHost = "node.awareframework.com:1001"
            config.dbPath = "sync_db"
        })
        if let engine = sensor.dbEngine as? RealmEngine {
            engine.removeAll(DeviceData.self)
            for _ in 0..<100 {
                engine.save(DeviceData())
            }
        }
        let successExpectation = XCTestExpectation(description: "success sync")
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareDeviceSyncCompletion,
                                                              object: sensor, queue: .main) { (notification) in
                                                                if let userInfo = notification.userInfo{
                                                                    if let status = userInfo["status"] as? Bool {
                                                                        if status == true {
                                                                            successExpectation.fulfill()
                                                                        }
                                                                    }
                                                                }
        }
        sensor.sync(force: true)
        wait(for: [successExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(observer)
        
        ////////////////////////////////////
        
        // failure //
        let sensor2 = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.debug = true
            config.dbType = .REALM
            config.dbHost = "node.awareframework.com.com" // wrong url
            config.dbPath = "sync_db"
        })
        let failureExpectation = XCTestExpectation(description: "failure sync")
        let failureObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareDeviceSyncCompletion,
                                                                     object: sensor2, queue: .main) { (notification) in
                                                                        if let userInfo = notification.userInfo{
                                                                            if let status = userInfo["status"] as? Bool {
                                                                                if status == false {
                                                                                    failureExpectation.fulfill()
                                                                                }
                                                                            }
                                                                        }
        }
        if let engine = sensor2.dbEngine as? RealmEngine {
            engine.removeAll(DeviceData.self)
            for _ in 0..<100 {
                engine.save(DeviceData())
            }
        }
        sensor2.sync(force: true)
        wait(for: [failureExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(failureObserver)
        
        #endif
    }
    
    
    
    
    
    
    
    ///////////////////////////////////////////
    
    
    //////////// storage ///////////
    
    var realmToken:NotificationToken? = nil
    
    func testSensorModule(){
        
//        #if targetEnvironment(simulator)
//
//        print("This test requires a real device.")
//
//        #else
        
        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
            config.debug = true
            config.dbType = .REALM
            config.dbPath = "sensor_module"
        })
        let expect = expectation(description: "sensor module")
        if let realmEngine = sensor.dbEngine as? RealmEngine {
            // remove old data
            realmEngine.removeAll(DeviceData.self)
            // get a RealmEngine Instance
            if let realm = realmEngine.getRealmInstance() {
                // set Realm DB observer
                realmToken = realm.observe { (notification, realm) in
                    switch notification {
                    case .didChange:
                        // check database size
                        let results = realm.objects(DeviceData.self)
                        print(results.count)
                        XCTAssertGreaterThanOrEqual(results.count, 1)
                        realm.invalidate()
                        expect.fulfill()
                        self.realmToken = nil
                        break;
                    case .refreshRequired:
                        break;
                    }
                }
            }
        }
        
        let storageExpect = expectation(description: "sensor storage notification")
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareDevice,
                                                       object: sensor,
                                                       queue: .main) { (notification) in
                                                            storageExpect.fulfill()
                                                            NotificationCenter.default.removeObserver(token!)
        }
        
        sensor.start() // start sensor
        
        wait(for: [expect,storageExpect], timeout: 10)
        sensor.stop()

//        #endif
    }

    
}
