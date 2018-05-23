
import FlexLayout
import PinLayout

class BLEView: UIView {
    
    let rootFlexContainer = UIView()
    
    init() {
        super.init(frame: .zero)
        setContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setContainer() {
        rootFlexContainer.flex
            .define { flex in
            
        }
        addSubview(rootFlexContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
    }
}
