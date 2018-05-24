
import CoreBluetooth

protocol BLEPeripheralDelegate {
    
}

class BLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let serviceUUID = CBUUID(string: "9ef8ef4d-f59c-455a-ade2-83271ced561e")
    private let characteristicUUID = CBUUID(string: "f945af3b-95a5-4d55-a80a-2a1c1e7564a8")
    private let readProperties: CBCharacteristicProperties = [.read]
    private let readPermissions: CBAttributePermissions = [.readable]
    
    private let peripheralDelegate: BLEPeripheralDelegate
    private lazy var service = CBMutableService(type: serviceUUID, primary: true)
    private lazy var characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: readProperties, value: nil, permissions: readPermissions)
    private var peripheralManager: CBPeripheralManager?
    
    private var exchangeMessage: String?
    
    init(peripheralDelegate: BLEPeripheralDelegate) {
        self.peripheralDelegate = peripheralDelegate
        super.init()
    }
    
    func exchange(message: String) {
        service.characteristics = [characteristic]
        exchangeMessage = message
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func stop() {
        peripheralManager?.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()
        }
    }
    
    private func startAdvertising() {
        peripheralManager?.removeAllServices()
        peripheralManager?.add(service)
        peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: advertismentDataLocalNameKey, CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard let message = exchangeMessage, request.characteristic.uuid == characteristicUUID else {
            peripheralManager?.respond(to: request, withResult: .unlikelyError)
            return
        }
        request.value = message.data(using: .utf8)
        peripheralManager?.respond(to: request, withResult: .success)
        stop()
    }
}
