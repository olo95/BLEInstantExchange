
import CoreBluetooth

protocol BLECentralDelegate {
    func onReceived(message: String)
}

class BLECentralManager: NSObject, CBCentralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let serviceUUID = CBUUID(string: "9ef8ef4d-f59c-455a-ade2-83271ced561e")
    private let characteristicUUID = CBUUID(string: "f945af3b-95a5-4d55-a80a-2a1c1e7564a8")
    private let centralDelegate: BLECentralDelegate
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func scanForExchange() {
        connectedPeripheral = nil
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stop() {
        centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, peripheralName.elementsEqual(advertismentDataLocalNameKey) else { return }
//        guard let services = peripheral.services else { return }
//        services.forEach {
//            print($0.uuid)
//        }
//        print("////////////////////////////////////////////////////////////////////////")
//        guard services.contains(where: { $0.uuid == serviceUUID }) else { return }
        if let connectedPeripheral = connectedPeripheral { centralManager?.cancelPeripheralConnection(connectedPeripheral) }
        connectedPeripheral = peripheral
        central.connect(connectedPeripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            return
        }
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return
        }
        connectedPeripheral = peripheral
        connectedPeripheral?.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return
        }
        connectedPeripheral = peripheral
        connectedPeripheral?.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == self.characteristicUUID, let messageData = characteristic.value, let message = String(data: messageData, encoding: .utf8) else {
            return
        }
        centralDelegate.onReceived(message: message)
        stop()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
}
