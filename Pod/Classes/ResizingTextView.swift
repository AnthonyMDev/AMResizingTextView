import UIKit

/**
 A `UITextView` subclass that automatically resizes based on the size of its content text with a smooth animation.
*/
public class ResizingTextView: UITextView {
  
  /*
  *  MARK: - Instance Properties
  */
  
  /// The duration of the animation while resizing the text view in seconds. Defaults to `0.1`.
  var resizeDuration: NSTimeInterval = 0.1

  private var heightConstraint: NSLayoutConstraint!
  
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
      if constraint.firstAttribute == .Height {
        heightConstraint = constraint
        return true
      }
    }
    return false
  }
  
  private func createHeightConstraint() {
    heightConstraint = NSLayoutConstraint(item: self,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: heightForCurrentText())
    
    addConstraint(heightConstraint)
  }
  
  private func heightForCurrentText() -> CGFloat {
    return sizeThatFits(self.frame.size).height
  }
  
  private func registerForTextChangeNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "didUpdateText:",
      name: UITextViewTextDidChangeNotification,
      object: self)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  /*
  *  MARK: - Auto Resizing
  */
  
  func didUpdateText(sender: AnyObject) {
    let newHeight = heightForCurrentText()
    if newHeight != heightConstraint.constant {
      updateHeightConstraint(newHeight)
    }
  }
  
  private func updateHeightConstraint(newHeight: CGFloat) {
    heightConstraint.constant = newHeight
    setNeedsLayout()
    
    UIView.animateWithDuration(resizeDuration,
      delay: 0,
      options: .LayoutSubviews,
      animations: { () -> Void in
        self.layoutIfNeeded()
      },
      completion: nil)
  }
  
}
