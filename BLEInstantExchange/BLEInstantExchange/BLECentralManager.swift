
import CoreBluetooth
import RxSwift

protocol BLECentralDelegate {
    func onReceived(message: String)
    func peripheralIsValid()
}

class BLECentralManager: NSObject, CBCentralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let centralDelegate: BLECentralDelegate
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    private var isPeripheralValid: Bool = false
    var secretPassword: String = ""
    
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: [UUIDConstants.secretPasswordServiceUUID], options: nil)
        } else if central.state == .poweredOff {
            centralManager?.stopScan()
        }
    }
    
    func scanForExchange() {
        connectedPeripheral = nil
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stop() {
        centralManager?.stopScan()
        connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, peripheralName.elementsEqual(advertismentDataLocalNameKey) else {
            return
        }
        if let connectedPeripheral = connectedPeripheral { centralManager?.cancelPeripheralConnection(connectedPeripheral) }
        connectedPeripheral = peripheral
        central.connect(connectedPeripheral!, options: nil)
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices([UUIDConstants.dataServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            return
        }
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if isPeripheralValid {
            guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == UUIDConstants.dataServiceUUID }) else {
                return
            }
            connectedPeripheral?.discoverCharacteristics(nil, for: service)
        } else {
            guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == UUIDConstants.secretPasswordServiceUUID }) else {
                return
            }
            connectedPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristic = service.characteristics?.first(where: { $0.uuid == UUIDConstants.dataCharacteristicUUID }) else {
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if isPeripheralValid, characteristic.uuid == UUIDConstants.dataCharacteristicUUID, let messageData = characteristic.value, let message = String(data: messageData, encoding: .utf8) {
            centralDelegate.onReceived(message: message)
        } else {
            guard characteristic.uuid == UUIDConstants.secretPasswordCharacteristicUUID, let messageData = characteristic.value, let message = String(data: messageData, encoding: .utf8) else {
                return
            }
            if message == secretPassword {
                centralDelegate.peripheralIsValid()
                connectedPeripheral?.discoverServices([UUIDConstants.dataServiceUUID])
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
}
