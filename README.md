<p align="center">
  <img src="/Resources/logo.gif" height="150px">
</p>

[![Version](https://img.shields.io/cocoapods/v/Gatti.svg?style=flat)](https://cocoapods.org/pods/Gatti)
[![License](https://img.shields.io/cocoapods/l/Gatti.svg?style=flat)](https://cocoapods.org/pods/Gatti)
[![Platform](https://img.shields.io/cocoapods/p/Gatti.svg?style=flat)](https://cocoapods.org/pods/Gatti)

## What is it?

**Gatti** is a library for moving cursor between text fields in an elegant style. It is especially well suited for better user interactions such as on the auth screens.

Here is a quick example of how you can transform your screens!

<p align="center">
  <img src="/Resources/sample.gif" height="700px">
</p>

## Appearence

The library has a default appearance. So, when you don't specify the speed or color properties, `Gatti` uses the default values.

Default values:
- **speed**: TimeInterval
    - *default: 0.55*
- **color**: UIColor?
  - *default: .none (textField.tintColor by default)*

## How to use

```swift

 override func viewDidLoad() {
     super.viewDidLoad()
    
     // Attach cursor to the UIViewController
     Gatti.attach(to: self)
     
     // Attach cursor with delegate
     Gatti.attach(to: self, delegate: self)
     
     // Attach cursor only for some fields
     Gatti.attach(to: self, textFields: [UITextField])
     
     // Update cursor moving speed and set defaule color for all the text fields
     Gatti.update(to: self, speed: 0.8, color: .red)
     
     ...
     
     // Detach cursor from the screen
     Gatti.detach(from: self)
 }
```

#### Delegate

```swift

extension ViewController: UITextFieldDelegate, UITextFieldCaretDelegate {
    
    func caretWillAttach(to textField: UITextField) {
        // Will attach to the UITextField
    }
    
    func caretDidDetach(from textField: UITextField) {
        // Did detach from the UITextField
    }
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Handle UITextField delegate methods
        return true
    }
}
```

## Requirements

* iOS 10.0+
* CocoaPods 1.0.0+
* Swift 5

## Installation

Library is available through CocoaPods.
Edit your `Podfile` and specify the dependency:

```ruby
pod "Gatti"
```

## License

MIT License

Copyright (c) 2019 Dmitriy Zhyzhko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
