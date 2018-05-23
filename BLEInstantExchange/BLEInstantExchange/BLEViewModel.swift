
import Foundation

protocol BLEViewModelDelegate {
    
}

class BLEViewModel {
    
    let delegate: BLEViewModelDelegate
    
    init(viewModelDelegate: BLEViewModelDelegate) {
        delegate = viewModelDelegate
    }
}
