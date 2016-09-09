import UIKit

/**
 A `UITextView` subclass that automatically resizes based on the size of its content text with a smooth animation.
 */
open class ResizingTextView: UITextView {
    
    /*
     *  MARK: - Instance Properties
     */
    
    /// The duration of the animation while resizing the text view in seconds. Defaults to `0.1`.
    var resizeDuration: TimeInterval = 0.1
    
    fileprivate var heightConstraint: NSLayoutConstraint!
    
    /*
     *  MARK: - Object Lifecycle
     */
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        attachHeightConstraint()
        registerForTextChangeNotification()
    }
    
    fileprivate func attachHeightConstraint() {
        if !findHeightConstraint() {
            createHeightConstraint()
        }
    }
    
    fileprivate func findHeightConstraint() -> Bool {
        for constraint in constraints {
            if constraint.firstAttribute == .height {
                heightConstraint = constraint
                return true
            }
        }
        return false
    }
    
    fileprivate func createHeightConstraint() {
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: heightForCurrentText())
        
        addConstraint(heightConstraint)
    }
    
    fileprivate func heightForCurrentText() -> CGFloat {
        return sizeThatFits(self.frame.size).height
    }
    
    fileprivate func registerForTextChangeNotification() {
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
    
    func didUpdateText(_ sender: AnyObject) {
        let newHeight = heightForCurrentText()
        if newHeight != heightConstraint.constant {
            updateHeightConstraint(newHeight)
        }
    }
    
    fileprivate func updateHeightConstraint(_ newHeight: CGFloat) {
        heightConstraint.constant = newHeight
        setNeedsLayout()
        
        UIView.animate(withDuration: resizeDuration,
                       delay: 0,
                       options: .layoutSubviews,
                       animations: { self.layoutIfNeeded() },
                       completion: nil)
    }
    
}
