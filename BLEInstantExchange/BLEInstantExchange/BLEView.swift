
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
        textField.backgroundColor = .gray
        return textField
    }()
    
    lazy var exchangeMessageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send message", for: .normal)
        button.tintColor = .blue
        return button
    }()
    
    lazy var exchangeMessageResponseTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Response"
        return label
    }()
    
    lazy var exchangeMessageResponseLabel: UILabel = {
        let label = UILabel()
        return label
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
                        flex.addItem(exchangeMessageResponseTitleLabel).height(22).grow(1)
                        flex.addItem(exchangeMessageResponseLabel).height(22).grow(2)
                }
                flex.addItem()
                    .direction(.row)
                    .margin(8)
                    .define { flex in
                        flex.addItem(exchangeMessageButton).height(22).grow(1)
                        flex.addItem(exchangeMessageTextField).height(22).grow(2)
                }
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
