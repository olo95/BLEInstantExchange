
import CoreBluetooth
import RxSwift

protocol BLECentralDelegate {
    func onReceived(message: String)
    func didFindPeripheral()
}

class BLECentralManager: NSObject, CBCentralManagerDelegate {
    
    private let centralDelegate: BLECentralDelegate
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var authorizationCharacteristic: CBCharacteristic?
    
    private var isPeripheralValid: Bool = false
    private var secretName: String?
    private var communicationStatus: BLECommunicationStatus = .authenticating
    
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
//            centralManager?.scanForPeripherals(withServices: [Constants.authenticationResultServiceUUID], options: nil)
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        } else if central.state == .poweredOff {
            centralManager?.stopScan()
        }
    }
    
    func scanForExchange(with secretName: String?) {
        connectedPeripheral = nil
        self.secretName = secretName
        communicationStatus = .authenticating
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stop() {
        centralManager?.stopScan()
        connectedPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let secretName = self.secretName, let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, peripheralName.elementsEqual(secretName) else {
            return
        }
        if let connectedPeripheral = connectedPeripheral { centralManager?.cancelPeripheralConnection(connectedPeripheral) }
        connectedPeripheral = peripheral
        guard let connectedPeripheral = connectedPeripheral else { return }
        central.stopScan()
        central.connect(connectedPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralDelegate.didFindPeripheral()
        connectedPeripheral?.delegate = self
//        connectedPeripheral?.discoverServices([Constants.authenticationResultServiceUUID])
        connectedPeripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Siema")
    }
    
    func indicateDataServiceAdded() {
        guard let authorizationCharacteristic = self.authorizationCharacteristic else {
            return
        }
        connectedPeripheral?.writeValue("2".data(using: .utf8)!, for: authorizationCharacteristic, type: .withResponse)
    }
    
    func readData() {
        communicationStatus = .transmitting
        connectedPeripheral?.discoverServices([Constants.dataServiceUUID])
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        let serviceUUID = communicationStatus == .authenticating ? Constants.authenticationResultServiceUUID : Constants.dataServiceUUID
        let characteristicUUID = communicationStatus == .authenticating ? Constants.authenticationResultCharacteristicUUID : Constants.dataCharacteristicUUID
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else { return }
        connectedPeripheral?.discoverCharacteristics([characteristicUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        let characteristicUUID = communicationStatus == .authenticating ? Constants.authenticationResultCharacteristicUUID : Constants.dataCharacteristicUUID
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else { return }
        if characteristicUUID == Constants.authenticationResultCharacteristicUUID { authorizationCharacteristic = characteristic }
        communicationStatus == .authenticating ? connectedPeripheral?.writeValue("1".data(using: .utf8)!, for: characteristic, type: .withResponse) : connectedPeripheral?.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, characteristic.uuid == Constants.dataCharacteristicUUID, let messageData = characteristic.value, let message = String(data: messageData, encoding: .utf8) else {
            return
        }
        centralDelegate.onReceived(message: message)
    }
}
