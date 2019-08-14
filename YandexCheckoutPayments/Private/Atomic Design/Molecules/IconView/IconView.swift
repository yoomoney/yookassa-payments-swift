import UIKit

final class IconView: UIView {
    var image: UIImage {
        get {
            return imageView.image ?? UIImage()
        }
        set {
            invalidateIntrinsicContentSize()
            imageView.image = newValue
        }
    }

    let imageView: UIImageView = {
        $0.contentMode = .center
        return $0
    }(UIImageView())

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(imageView)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }

    override func tintColorDidChange() {
        applyStyles()
    }
}

extension IconView: IconViewInput {}
