
import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BLEViewController: BLEViewModelDelegate {
    
}

extension BLEViewController: BLECentralDelegate {
    
}

extension BLEViewController: BLEPeripheralDelegate {
    
}

