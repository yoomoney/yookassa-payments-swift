import UIKit

protocol FixedLengthCodeControlDelegate: class {
    func fixedLengthCodeControl(
        _ fixedLengthCodeControl: FixedLengthCodeControl,
        didGetCode code: String
    )
}

class FixedLengthCodeControl: UIView {

    // MARK: - Public properties

    weak var delegate: FixedLengthCodeControlDelegate?

    // MARK: - Private properties

    private var length: Int = 0

    // MARK: - UI properties

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Space.double
        return view
    }()

    private var singleCharacterViews: [SingleCharacterView] = []

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - First responder

    override var isFirstResponder: Bool {
        return singleCharacterViews.contains { $0.isFirstResponder }
    }

    override func resignFirstResponder() -> Bool {
        guard let oldFirstResponder = singleCharacterViews.first(where: { $0.isFirstResponder }) else { return false }
        return oldFirstResponder.resignFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        guard let newFirstResponder = singleCharacterViews.first(where: { $0.character == nil }) else { return false }
        return newFirstResponder.becomeFirstResponder()
    }
}

// MARK: - Public methods

extension FixedLengthCodeControl {

    func setLength(_ length: Int) {
        self.length = length
        singleCharacterViews.forEach {
            $0.removeFromSuperview()
        }
        singleCharacterViews = []
        for _ in 0..<length {
            let view = SingleCharacterView()
            view.delegate = self
            singleCharacterViews.append(view)
            stackView.addArrangedSubview(view)
        }
        if #available(iOS 11.0, *), length == 6 {
            stackView.setCustomSpacing(Space.quadruple, after: stackView.arrangedSubviews[2])
        }
    }

    func setIsEditable(_ isEditable: Bool) {
        singleCharacterViews.forEach {
            $0.isEditable = isEditable
        }
    }

    func clear() {
        singleCharacterViews.forEach {
            $0.character = nil
        }
        if isFirstResponder {
            _ = becomeFirstResponder()
        }
    }
}

// MARK: - Private methods

private extension FixedLengthCodeControl {

    func setup() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - SingleCharacterViewDelegate

extension FixedLengthCodeControl: SingleCharacterViewDelegate {

    func singleCharacterView(_ singleCharacterView: SingleCharacterView, didGetCharacter character: Character) {
        guard let index = singleCharacterViews.firstIndex(of: singleCharacterView) else { return }
        if index == length - 1 {
            delegate?.fixedLengthCodeControl(self, didGetCode: String(singleCharacterViews.compactMap { $0.character }))
        } else {
            _ = singleCharacterViews[index + 1].becomeFirstResponder()
        }
    }

    func singleCharacterViewDidGetBackspaceCharacter(_ singleCharacterView: SingleCharacterView) {
        guard let index = singleCharacterViews.firstIndex(of: singleCharacterView), index != 0 else { return }
        singleCharacterViews[index - 1].character = nil
        _ = singleCharacterViews[index - 1].becomeFirstResponder()
    }
}
