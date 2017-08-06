//
//  ViewController.swift
//  Lynn
//
//  Created by Alexander Li on 7/21/17.
//  Copyright © 2017 Alexander Li. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    //MARK: Navigation
    override func viewDidDisappear(_ animated: Bool) {
        print("segue")
        if (bluetoothConnected){
            centralManager.cancelPeripheralConnection(sensorTag!)
        }
    }
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    
    var myList:[String] = []
    var handle: DatabaseHandle?
    var handle2: DatabaseHandle?
    var ref: DatabaseReference?
    
    var inThisQueue = false
    var thisQueue = Queue.chosenQueue
    
    var peopleAhead:Int!
    
    //Bluetooth variables
    let timerPauseInterval:TimeInterval = 5.0
    let timerScanInterval:TimeInterval = 2.0
    let sensorName = "SH-HC-08" //
    var serviceUUID = "FFE0"
    var characteristicUUID = "FFE1"
    var keepScanning = false;
    var centralManager:CBCentralManager!
    var sensorTag:CBPeripheral?
    var sensorCharacteristic:CBCharacteristic?
    var bluetoothConnected = false;
    
    @IBOutlet weak var connectionLabel: UILabel!
    
    //MARK: Adding
    @IBAction func saveBtn(_ sender: Any) {
        if (myTextField.text != "") {
            addChildToQueue(childName: myTextField.text!)
            myTextField.text = ""
            inThisQueue = true
            Queue.linesJoined.append(thisQueue!)
            self.view.backgroundColor = .white
        }
    }
    
    func addChildToQueue(childName: String){
        let currentDateTime = Date()
        
        ref?.child("Queues").child(thisQueue!).child(String(describing: currentDateTime)).setValue(childName)
    }
    
    //MARK: Removing
    
    @IBAction func popButton(_ sender: Any) {
        if (peopleAhead > 0){
        ref?.child("Queues").child(thisQueue!).child(myList[1]).removeValue()
        myList.remove(at: 1)
        }
    }
    
    
    //MARK: General
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myTextField.delegate = self
        
        ref = Database.database().reference()
        
        self.title = thisQueue
        
        //Bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        connectionLabel.text = "Not Connected"
        
        handle = ref?.child("Queues").child(thisQueue!).observe(.childAdded, with: { (snapshot) in
            //***Adding keys to myList instead of the values now to allow for easy deleting of top person
            if let item = snapshot.key as String? {
                self.myList.append(item)
                self.peopleAhead = self.myList.count-1
                self.countLabel.text = String(self.peopleAhead)
                self.waitLabel.text = String(self.peopleAhead*5) + "min"
                //Queue.queues.append(item)
            }
        })
        if (Queue.linesJoined.contains(thisQueue!)){
            inThisQueue = true
            self.view.backgroundColor = .white
        }
        
        handle2 = ref?.child("Queues").child(thisQueue!).observe(.childRemoved, with: { (snapshot) in
            //***Adding keys to myList instead of the values now to allow for easy deleting of top person
            if (snapshot.key as String?) != nil {
                self.myList.remove(at: 0)
                self.peopleAhead = self.myList.count
                self.countLabel.text = String(self.peopleAhead)
                self.waitLabel.text = String(self.peopleAhead*5) + "min"
                //Queue.queues.append(item)
            }
        })
    }
    
    
    //MARK: Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if (myTextField.text != "") {
            addChildToQueue(childName: myTextField.text!)
            myTextField.text = ""
            inThisQueue = true
            Queue.linesJoined.append(thisQueue!)
            self.view.backgroundColor = .white
        }
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var showAlert = true
        var message = ""
        
        switch central.state {
        case .poweredOff:
            message = "Bluetooth on this device is currently powered off."
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        case .poweredOn:
            showAlert = false
            message = "Bluetooth LE is turned on and ready for communication."
            
            print(message)
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            // Option 2: Scan for devices that have the service you're interested in...
            let sensorTagAdvertisingUUID = CBUUID(string: serviceUUID)
            centralManager.scanForPeripherals(withServices: [sensorTagAdvertisingUUID], options: nil)
        }
        
        if showAlert {
            let alertController = UIAlertController(title: "Central Manager State", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.show(alertController, sender: self)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO Peripheral!!!")
        connectionLabel.text = "Connected"
        bluetoothConnected = true;
        peripheral.discoverServices(nil)
        pauseScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print(advertisementData)
            if (peripheralName == sensorName){
                sensorTag = peripheral
                sensorTag!.delegate = self
                centralManager.connect(sensorTag!, options: nil)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                //print("Discovered service \(service)")
                if (service.uuid == CBUUID(string: serviceUUID)) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS")
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                // Temperature Data Characteristic
                //print("Characteristic \(characteristic)")
                if characteristic.uuid == CBUUID(string: characteristicUUID) {
                    print("FOUND CHARACTERISTIC")
                    sensorCharacteristic = characteristic
                    sensorTag?.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (error != nil) {
            print("Error reading characteristics")
            return;
        }
        
        if (characteristic.value != nil) {
            let dataBLE = String(data: characteristic.value!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            if (dataBLE != nil){
                let index = dataBLE?.index((dataBLE?.startIndex)!, offsetBy: 1)
                let shorterDataBLE = dataBLE?.substring(to: index!)
                if (shorterDataBLE == "p"){
                    addChildToQueue(childName: "Annonymous")
                }
                }
            }
        }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bluetoothConnected = false;
        connectionLabel.text = "Not Connected"
        print("**** DISCONNECTED FROM SENSOR TAG!!!")
        sensorTag = nil
    }
    
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            let sensorTagAdvertisingUUID = CBUUID(string: serviceUUID)
            centralManager.scanForPeripherals(withServices: [sensorTagAdvertisingUUID], options: nil)
        }
    }
    
}

