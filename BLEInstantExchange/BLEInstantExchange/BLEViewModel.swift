
import RxSwift

protocol BLEViewModelDelegate {
    func devicesAuthorized()
    func dataTransmittingEnabled()
}

class BLEViewModel {
    
    let bag = DisposeBag()
    let delegate: BLEViewModelDelegate
    let peripheralAuthenticated = BehaviorSubject<Bool>(value: false)
    let receivedAuthentication = BehaviorSubject<Bool>(value: false)
    let dataServiceRevealed = BehaviorSubject<Bool>(value: false)
    let externalDataServiceRevealed = BehaviorSubject<Bool>(value: false)
    let externalAuthorizationCharacteristicObtained = BehaviorSubject<Bool>(value: false)
    
    init(viewModelDelegate: BLEViewModelDelegate) {
        delegate = viewModelDelegate
        
        Observable.combineLatest(peripheralAuthenticated, receivedAuthentication, externalAuthorizationCharacteristicObtained)
            .filter { $0.0 && $0.1 && $0.2 }
            .subscribe( onNext: { [weak self] _ in
                self?.delegate.devicesAuthorized()
            }).disposed(by: bag)
        
        Observable.combineLatest(dataServiceRevealed, externalDataServiceRevealed)
            .filter { $0.0 && $0.1 }
            .subscribe( onNext: { [weak self] _ in
                self?.delegate.dataTransmittingEnabled()
            }).disposed(by: bag)
    }
}
