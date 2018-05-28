
import CoreBluetooth
import RxSwift

protocol BLEPeripheralDelegate {
    func didAuthenticateCentral()
    func externalDataServiceRevealed()
    func didAddDataService()
}

class BLEPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    private let readProperties: CBCharacteristicProperties = [.read]
    private let readPermissions: CBAttributePermissions = [.readable]
    private let writeProperties: CBCharacteristicProperties = [.write]
    private let writePermissions: CBAttributePermissions = [.writeable]
    
    private let peripheralDelegate: BLEPeripheralDelegate
    private lazy var dataService = CBMutableService(type: Constants.dataServiceUUID, primary: true)
    private lazy var dataCharacteristic = CBMutableCharacteristic(type: Constants.dataCharacteristicUUID, properties: readProperties, value: nil, permissions: readPermissions)
    private lazy var authenticationService = CBMutableService(type: Constants.authenticationResultServiceUUID, primary: true)
    private lazy var authenticationCharacteristic = CBMutableCharacteristic(type: Constants.authenticationResultCharacteristicUUID, properties: writeProperties, value: nil, permissions: writePermissions)
    
    private var peripheralManager: CBPeripheralManager?
    private var secretName: String?
    private var communicationStatus: BLECommunicationStatus = .authenticating
    
    init(peripheralDelegate: BLEPeripheralDelegate) {
        self.peripheralDelegate = peripheralDelegate
        super.init()
    }
    
    func scanForExchange(with secretName: String) {
        self.secretName = secretName
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
        guard let secretName = secretName else { return }
        peripheralManager?.removeAllServices()
        authenticationService.characteristics = [authenticationCharacteristic]
        peripheralManager?.add(authenticationService)
        peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: secretName, CBAdvertisementDataServiceUUIDsKey: [Constants.authenticationResultServiceUUID]])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == Constants.authenticationResultCharacteristicUUID {
                guard let value = request.value?.hexEncodedString() else {
                    return
                }
                if value == "31" {
                    peripheralDelegate.didAuthenticateCentral()
                    peripheralManager?.respond(to: requests[0], withResult: .success)
                }
                if value == "32" {
                    peripheralDelegate.externalDataServiceRevealed()
                    peripheralManager?.respond(to: requests[0], withResult: .success)
                }
            }
        }
    }
    
    func addDataService() {
        dataService.characteristics = [dataCharacteristic]
        peripheralManager?.add(dataService)
        peripheralDelegate.didAddDataService()
    }
}
