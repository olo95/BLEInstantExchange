
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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func setupUI() {
        mainView.exchangeMessageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onExchangeButtonTapped)))
        mainView.resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onResetButtonTapped)))
    }
    
    @objc private func onExchangeButtonTapped() {
        guard !(mainView.exchangeMessageTextField.text!.isEmpty) && !(mainView.secretPasswordTextField.text!.isEmpty) else {
            return
        }
        central.secretPassword = mainView.secretPasswordTextField.text!
        peripheral.secretPassword = mainView.secretPasswordTextField.text!
        central.stop()
        peripheral.stop()
        peripheral.exchange(message: mainView.secretPasswordTextField.text!)
        central.scanForExchange()
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
    
    func peripheralIsValid() {
        peripheral.onConnectionSafe()
    }
}

extension BLEViewController: BLEPeripheralDelegate {
    
}

