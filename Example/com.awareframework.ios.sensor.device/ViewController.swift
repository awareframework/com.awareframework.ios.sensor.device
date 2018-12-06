//
//  ViewController.swift
//  com.awareframework.ios.sensor.device
//
//  Created by tetujin on 11/19/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_device

class ViewController: UIViewController {

    var sensor:DeviceSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let sensor = DeviceSensor.init(DeviceSensor.Config().apply{ config in
//            config.debug = true
//            config.dbType = .REALM
//            config.dbHost = "node.awareframework.com:1001"
//        })
//        sensor.start()
//        
//        sensor.sync(force: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

