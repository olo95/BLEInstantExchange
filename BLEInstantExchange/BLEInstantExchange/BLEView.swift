
import FlexLayout
import PinLayout

class BLEView: UIView {
    
    let rootFlexContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var exchangeMessageTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    lazy var exchangeMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send message", for: .normal)
        return button
    }()
    
    lazy var exchangeMessageResponseTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Response"
        return label
    }()
    
    lazy var exchangeMessageResponseLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset BLE", for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setContainer() {
        rootFlexContainer.flex
            .direction(.column)
            .justifyContent(.center)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .margin(8)
                    .define { flex in
                        flex.addItem(exchangeMessageResponseTitleLabel).height(44).grow(1)
                        flex.addItem(exchangeMessageResponseLabel).height(44).grow(2)
                }
                flex.addItem()
                    .direction(.row)
                    .margin(8)
                    .define { flex in
                        flex.addItem(exchangeMessageButton).height(44).grow(1)
                        flex.addItem(exchangeMessageTextField).height(44).grow(2)
                }
                flex.addItem(resetButton).marginTop(32).height(44)
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
