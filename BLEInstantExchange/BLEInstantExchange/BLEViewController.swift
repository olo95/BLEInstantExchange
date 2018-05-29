
import UIKit
import RxSwift

class BLEViewController: UIViewController {

    private lazy var viewModel: BLEViewModel = {
       return BLEViewModel(viewModelDelegate: self)
    }()
    
    private lazy var central: BLECentralManager = {
        return BLECentralManager(centralDelegate: self)
    }()
    
    private lazy var peripheral: BLEPeripheralManager = {
        return BLEPeripheralManager(peripheralDelegate: self)
    }()
    
    private var mainView: BLEView {
        return view as! BLEView
    }
    
    override func loadView() {
        view = BLEView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        mainView.exchangeMessageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onExchangeButtonTapped)))
        mainView.resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onResetButtonTapped)))
    }
    
    @objc private func onExchangeButtonTapped() {
        guard !(mainView.exchangeMessageTextField.text!.isEmpty) && !(mainView.secretPasswordTextField.text!.isEmpty) else {
            return
        }
        viewModel.dataServiceRevealed.onNext(false)
        viewModel.externalDataServiceRevealed.onNext(false)
        viewModel.peripheralAuthenticated.onNext(false)
        viewModel.receivedAuthentication.onNext(false)
        viewModel.externalAuthorizationCharacteristicObtained.onNext(false)
        central.stop()
        peripheral.stop()
        peripheral.scanForExchange(with: mainView.secretPasswordTextField.text!, exchangeMessage: mainView.exchangeMessageTextField.text!)
        central.scanForExchange(with: mainView.secretPasswordTextField.text!)
    }
    
    @objc private func onResetButtonTapped() {
        central.stop()
        peripheral.stop()
    }
}

extension BLEViewController: BLEViewModelDelegate {
    func dataTransmittingEnabled() {
        peripheral.prepareForDataRead()
        central.readData()
    }
    
    func devicesAuthorized() {
        peripheral.addDataService()
    }
}

extension BLEViewController: BLECentralDelegate {
    func externalAuthorizationCharacteristicObtained() {
        viewModel.externalAuthorizationCharacteristicObtained.onNext(true)
    }
    
    func onReceived(message: String) {
        mainView.exchangeMessageResponseLabel.text = message
    }
    
    func didFindPeripheral() {
        viewModel.peripheralAuthenticated.onNext(true)
    }
}

extension BLEViewController: BLEPeripheralDelegate {
    func didAddDataService() {
        viewModel.dataServiceRevealed.onNext(true)
        central.indicateDataServiceAdded()
    }
    
    func externalDataServiceRevealed() {
        viewModel.externalDataServiceRevealed.onNext(true)
    }
    
    func didAuthenticateCentral() {
        viewModel.receivedAuthentication.onNext(true)
    }
}

