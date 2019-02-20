import UIKit

/**
 A `UITextView` subclass that automatically resizes based on the size of its content text with a smooth animation.
 */
open class ResizingTextView: UITextView {
    
    public enum ResizableHeight {
        case height(CGFloat)
        case numberOfLines(Int)
        case infinite
    }
    
    /*
     *  MARK: - Instance Properties
     */
    
    /// The duration of the animation while resizing the text view in seconds. Defaults to `0.1`.
    public var resizeDuration: TimeInterval = 0.1
    
    /// The maximum height that the text view should resize to.
    ///
    /// Once the `frame`'s height has reached this value,
    /// `showsVerticalScrollIndicator` and `isScrollEnabled` are set to `true`.
    ///
    /// Once the `frame`'s height is below this value,
    /// `showsVerticalScrollIndicator` and `isScrollEnabled` are set back to their previous values.
    ///
    /// The default value is `ResizableHeight.infinite`
    public var maxResizableHeight: ResizableHeight = .infinite
    
    /// The minimum height that the text view should resize to.
    ///
    /// The default value is `ResizableHeight.numberOfLines(1)`
    public var minResizableHeight: ResizableHeight = .numberOfLines(1)
    
    /// This closure will be called before the text view's `height` is changed.
    /// The parameter is the height that the text view will be updated to as a `CGFloat`.
    public var willChangeHeight: ((CGFloat) -> Void)?
    
    /// This closure will be called after the text view's `height` is changed.
    /// The parameter is the height that the text view was updated to as a `CGFloat`.
    public var didChangeHeight: ((CGFloat) -> Void)?
    
    // MARK: Private Properties
    
    private var heightConstraint: NSLayoutConstraint!
    
    private var initialIsScrollEnabled: Bool = true
    private var initialShowsVerticalScrollIndicator: Bool = true
    
    private var maxHeight: CGFloat? {
        return calculateHeight(for: maxResizableHeight)
    }
    
    private var minHeight: CGFloat? {
        return calculateHeight(for: minResizableHeight)
    }
    
    private var isMaxHeight: Bool = false {
        didSet {
            if !oldValue {
                initialIsScrollEnabled = isScrollEnabled
                initialShowsVerticalScrollIndicator = showsVerticalScrollIndicator
            }
            isScrollEnabled = isMaxHeight ? true : initialIsScrollEnabled
            showsVerticalScrollIndicator = isMaxHeight ? true : initialShowsVerticalScrollIndicator
        }
    }
    
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
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        didUpdateText(self)
    }
    
    /*
     *  MARK: - Auto Resizing
     */
    
    @objc func didUpdateText(_ sender: AnyObject) {
        var newHeight = heightForCurrentText()
        
        if let maxHeight = maxHeight, newHeight >= maxHeight {
            newHeight = maxHeight
            isMaxHeight = true
        } else {
            if let minHeight = minHeight, newHeight < minHeight {
                newHeight = minHeight
            }
            isMaxHeight = false
        }
        
        if newHeight != heightConstraint.constant {
            updateHeightConstraint(newHeight)
        }
    }
    
    private func updateHeightConstraint(_ newHeight: CGFloat) {
        willChangeHeight?(newHeight)
        UIView.transition(with: self,
                          duration: resizeDuration,
                          animations: { [weak self, newHeight] in
                            self?.heightConstraint.constant = newHeight
            },
                          completion: { [weak self, newHeight] _ in
                            self?.didChangeHeight?(newHeight)
                            self?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        })
    }
    
    private func calculateHeight(for resizableHeight: ResizableHeight) -> CGFloat? {
        switch resizableHeight {
        case .height(let height): return height
        case .numberOfLines(let lines): return height(forNumberOfLines: lines)
        case .infinite: return nil
        }
    }
    
    private func height(forNumberOfLines numberOfLines: Int) -> CGFloat? {
        if let font = font {
            let padding = contentInset.top + contentInset.bottom + textContainerInset.top + textContainerInset.bottom
            return (font.lineHeight * CGFloat(numberOfLines)) + padding
        } else {
            NSLog("ResizingTextView failed to calculate the height restriction, `font` cannot be `nil`.")
            return nil
        }
    }
    
}
