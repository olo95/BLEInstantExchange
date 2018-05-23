
import CoreBluetooth

protocol BLEPeripheralDelegate {
    
}

class BLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let serviceUUID = "9ef8ef4d-f59c-455a-ade2-83271ced561e"
    private let characteristicUUID = "f945af3b-95a5-4d55-a80a-2a1c1e7564a8"
    
    private let peripheralDelegate: BLEPeripheralDelegate
    private lazy var service = CBMutableService(type: CBUUID(string: serviceUUID), primary: true)
    private lazy var peripheralManager: CBPeripheralManager = {
        CBPeripheralManager(delegate: self, queue: nil)
    }()
    
    init(peripheralDelegate: BLEPeripheralDelegate) {
        self.peripheralDelegate = peripheralDelegate
    }
    
    private func setPeripheralService() {
        
    }
    
    func send(message: String) {
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
}
