
import RxSwift

protocol BLEViewModelDelegate {
    
}

class BLEViewModel {
    
    let bag = DisposeBag()
    let delegate: BLEViewModelDelegate
    let peripheralAuthenticated = BehaviorSubject<Bool>(value: false)
    let receivedAuthentication = BehaviorSubject<Bool>(value: false)
    
    init(viewModelDelegate: BLEViewModelDelegate) {
        delegate = viewModelDelegate
        
        Observable.combineLatest(peripheralAuthenticated, receivedAuthentication)
            .filter { $0.0 && $0.1 }
            .subscribe( onNext: { _ in
                
            }).disposed(by: bag)
    }
}
