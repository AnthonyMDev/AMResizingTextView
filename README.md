# AMResizingTextView

[![Version](https://img.shields.io/cocoapods/v/AMResizingTextView.svg?style=flat)](http://cocoapods.org/pods/AMResizingTextView)
[![License](https://img.shields.io/cocoapods/l/AMResizingTextView.svg?style=flat)](http://cocoapods.org/pods/AMResizingTextView)
[![Platform](https://img.shields.io/cocoapods/p/AMResizingTextView.svg?style=flat)](http://cocoapods.org/pods/AMResizingTextView)

## Usage

Just initialize a `ResizingTextView` just as you would a `UITextView`, or set the custom class of a `UITextView` in interface builder to `ResizingTextView`. No other configuration is needed!

You can listen for updates to the text view's `height`, use the provided delegate closures.

```swift
textView.willChangeHeight = { newHeight in
    // do something before the height changes
}

textView.didChangeHeight = { newHeight in
    // do something after the height changes
}
```

## Installation

AMResizingTextView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AMResizingTextView'
```

## Author

Anthony Miller, AnthonyMDev@gmail.com

## License

AMResizingTextView is available under the MIT license. See the LICENSE file for more info.
