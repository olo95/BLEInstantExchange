
import CoreBluetooth
import RxSwift

protocol BLEPeripheralDelegate {
    
}

class BLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    private let advertismentDataLocalNameKey = "BLEInstantMessage"
    private let readProperties: CBCharacteristicProperties = [.read]
    private let readPermissions: CBAttributePermissions = [.readable]
    
    private let peripheralDelegate: BLEPeripheralDelegate
    private lazy var dataService = CBMutableService(type: UUIDConstants.dataServiceUUID, primary: true)
    private lazy var dataCharacteristic = CBMutableCharacteristic(type: UUIDConstants.dataCharacteristicUUID, properties: readProperties, value: nil, permissions: readPermissions)
    private lazy var secretPasswordService = CBMutableService(type: UUIDConstants.secretPasswordServiceUUID, primary: true)
    private lazy var secretPasswordCharacteristic = CBMutableCharacteristic(type: UUIDConstants.secretPasswordCharacteristicUUID, properties: readProperties, value: nil, permissions: readPermissions)
    
    private var peripheralManager: CBPeripheralManager?
    
    private var exchangeMessage: String?
    var isConnectedSafe: Bool = false
    var secretPassword: String = ""
    
    init(peripheralDelegate: BLEPeripheralDelegate) {
        self.peripheralDelegate = peripheralDelegate
        super.init()
    }
    
    func exchange(message: String) {
        dataService.characteristics = [dataCharacteristic]
        secretPasswordService.characteristics = [secretPasswordCharacteristic]
        exchangeMessage = message
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func stop() {
        peripheralManager?.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()
        } else if peripheral.state == .poweredOff {
            stop()
        }
    }
    
    private func startAdvertising() {
        peripheralManager?.removeAllServices()
        peripheralManager?.add(secretPasswordService)
        peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: advertismentDataLocalNameKey, CBAdvertisementDataServiceUUIDsKey: [UUIDConstants.secretPasswordServiceUUID]])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if isConnectedSafe {
            guard let message = exchangeMessage, request.characteristic.uuid == UUIDConstants.dataCharacteristicUUID else {
                peripheralManager?.respond(to: request, withResult: .unlikelyError)
                return
            }
            request.value = message.data(using: .utf8)
            peripheralManager?.respond(to: request, withResult: .success)
        } else {
            guard let message = exchangeMessage, request.characteristic.uuid == UUIDConstants.secretPasswordCharacteristicUUID else {
                peripheralManager?.respond(to: request, withResult: .unlikelyError)
                return
            }
            request.value = message.data(using: .utf8)
            peripheralManager?.respond(to: request, withResult: .success)
        }
    }
    
    func onConnectionSafe() {
        peripheralManager?.add(dataService)
        isConnectedSafe = true
    }
}
