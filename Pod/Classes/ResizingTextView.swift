import UIKit

/**
 A `UITextView` subclass that automatically resizes based on the size of its content text with a smooth animation.
 */
open class ResizingTextView: UITextView {
    
    /*
     *  MARK: - Instance Properties
     */
    
    /// The duration of the animation while resizing the text view in seconds. Defaults to `0.1`.
    public var resizeDuration: TimeInterval = 0.1
    
    private var heightConstraint: NSLayoutConstraint!
    
    /// This closure will be called before the text view's `height` is changed.
    /// The parameter is the height that the text view will be updated to as a `CGFloat`.
    public var willChangeHeight: ((CGFloat) -> Void)?
    
    /// This closure will be called after the text view's `height` is changed.
    /// The parameter is the height that the text view was updated to as a `CGFloat`.
    public var didChangeHeight: ((CGFloat) -> Void)?
    
    /*
     *  MARK: - Object Lifecycle
     */
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        attachHeightConstraint()
        registerForTextChangeNotification()
    }
    
    private func attachHeightConstraint() {
        if !findHeightConstraint() {
            createHeightConstraint()
        }
    }
    
    private func findHeightConstraint() -> Bool {
        for constraint in constraints {
            if constraint.firstAttribute == .height {
                heightConstraint = constraint
                return true
            }
        }
        return false
    }
    
    private func createHeightConstraint() {
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: heightForCurrentText())
        
        addConstraint(heightConstraint)
    }
    
    private func heightForCurrentText() -> CGFloat {
        return sizeThatFits(self.frame.size).height
    }
    
    private func registerForTextChangeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ResizingTextView.didUpdateText(_:)),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
     *  MARK: - Auto Resizing
     */
    
    @objc func didUpdateText(_ sender: AnyObject) {
        let newHeight = heightForCurrentText()
        if newHeight != heightConstraint.constant {
            updateHeightConstraint(newHeight)
        }
    }
    
    private func updateHeightConstraint(_ newHeight: CGFloat) {
        willChangeHeight?(newHeight)
        heightConstraint.constant = newHeight
        setNeedsLayout()
        
        UIView.animate(withDuration: resizeDuration,
                       delay: 0,
                       options: .layoutSubviews,
                       animations: { self.layoutIfNeeded() },
                       completion: { [weak self] _ in
                        self?.didChangeHeight?(newHeight)
            })
    }
    
}
