#
# Be sure to run `pod lib lint Gatti.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.swift_version    = '5.0'
  s.name             = 'Gatti'
  s.version          = '0.1.2'
  s.summary          = 'Flying caret library for UITextField.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Library that provides a means to animate cursor moves between text fields.'

  s.homepage         = 'https://github.com/z-four/Gatti'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'z-four' => 'zfour.apps@gmail.com' }
  s.source           = { :git => 'https://github.com/z-four/Gatti.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10'

  s.source_files = 'Gatti/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Gatti' => ['Gatti/Assets/*.png']
  # }

  s.frameworks = 'UIKit'
end
