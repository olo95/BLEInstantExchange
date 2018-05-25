
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
    
    private var isPeripheralValid: Bool = false
    private var secretName: String?
    private var communicationStatus: BLECommunicationStatus = .authenticating
    
    init(centralDelegate: BLECentralDelegate) {
        self.centralDelegate = centralDelegate
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: [Constants.authenticationResultServiceUUID], options: nil)
        } else if central.state == .poweredOff {
            centralManager?.stopScan()
        }
    }
    
    func scanForExchange(with secretName: String?) {
        connectedPeripheral = nil
        self.secretName = secretName
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
        central.stopScan()
        central.connect(connectedPeripheral!, options: nil)
        centralDelegate.didFindPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices([Constants.authenticationResultServiceUUID])
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        let serviceUUID = communicationStatus == .authenticating ? Constants.authenticationResultServiceUUID : Constants.dataServiceUUID
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else { return }
        connectedPeripheral?.discoverCharacteristics([serviceUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        let characteristicUUID = communicationStatus == .authenticating ? Constants.authenticationRestultCharacteristicUUID : Constants.dataCharacteristicUUID
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else { return }
        communicationStatus == .authenticating ? connectedPeripheral?.writeValue("1".data(using: .utf8)!, for: characteristic, type: .withResponse) : connectedPeripheral?.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
