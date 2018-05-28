
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
        central.stop()
        peripheral.stop()
        peripheral.scanForExchange(with: mainView.secretPasswordTextField.text!)
        central.scanForExchange(with: mainView.secretPasswordTextField.text!)
    }
    
    @objc private func onResetButtonTapped() {
        central.stop()
        peripheral.stop()
    }
}

extension BLEViewController: BLEViewModelDelegate {
    
}

extension BLEViewController: BLECentralDelegate {
    func onReceived(message: String) {
        mainView.exchangeMessageResponseLabel.text = message
    }
    
    func didFindPeripheral() {
        viewModel.peripheralAuthenticated.onNext(true)
    }
}

extension BLEViewController: BLEPeripheralDelegate {
    func externelDataServiceRevealed() {
        viewModel.externalDataServiceRevealed.onNext(true)
    }
    
    func didAuthenticateCentral() {
        viewModel.receivedAuthentication.onNext(true)
    }
}

