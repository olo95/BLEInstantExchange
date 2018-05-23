
import CoreBluetooth

protocol BLECentralDelegate {
    
}

class BLECentralManager {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let serviceUUID = "9ef8ef4d-f59c-455a-ade2-83271ced561e"
    private let characteristicUUID = "f945af3b-95a5-4d55-a80a-2a1c1e7564a8"
    private let centralDelegate: BLECentralDelegate
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
    }
}
