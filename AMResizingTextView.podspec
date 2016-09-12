Pod::Spec.new do |s|
  s.name             = "AMResizingTextView"
  s.version          = "0.2.0"
  s.summary          = "A `UITextView` subclass that automatically resizes based on the size of its content text with a smooth animation. Written in Swift"

  s.homepage         = "https://github.com/AnthonyMDev/AMResizingTextView"
  s.license          = 'MIT'
  s.author           = { "Anthony Miller" => "AnthonyMDev@gmail.com" }
  s.source           = { :git => "https://github.com/AnthonyMDev/AMResizingTextView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AnthonyMDev'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'UIKit'
end
