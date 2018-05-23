
import CoreBluetooth

protocol BLECentralDelegate {
    func onReceived(message: String)
}

class BLECentralManager: NSObject, CBCentralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let serviceUUID = CBUUID(string: "9ef8ef4d-f59c-455a-ade2-83271ced561e")
    private let characteristicUUID = CBUUID(string: "f945af3b-95a5-4d55-a80a-2a1c1e7564a8")
    private let centralDelegate: BLECentralDelegate
    
    private lazy var centralManager = CBCentralManager(delegate: self, queue: nil)
    
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func scanForExchange() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stop() {
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil, let services = peripheral.services, services.contains(where: { $0.uuid == serviceUUID }) else {
            return
        }
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
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
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }), let messageData = characteristic.value, let message = String(data: messageData, encoding: .utf8) else {
            return
        }
        centralDelegate.onReceived(message: message)
    }
}
