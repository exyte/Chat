<img src="https://raw.githubusercontent.com/exyte/media/master/common/header.png">
<img align="right" src="https://raw.githubusercontent.com/exyte/media/master/Chat/pic1.png" width="300">

<p><h1 align="left">Chat</h1></p>

<p><h4>Chat with fully customizable message cells and built-in media picker written with SwiftUI</h4></p>

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br></br>
[![Travis CI](https://travis-ci.org/exyte/Chat.svg?branch=master)](https://travis-ci.org/exyte/Chat)
[![Version](https://img.shields.io/cocoapods/v/Chat.svg?style=flat)](http://cocoapods.org/pods/ExyteChat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ExyteChat.svg?style=flat)](http://cocoapods.org/pods/ExyteChat)
[![Platform](https://img.shields.io/cocoapods/p/ExyteChat.svg?style=flat)](http://cocoapods.org/pods/ExyteChat)
[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)

# Usage

Create an indicator like this:
```swift
@State var messages: [Message] = []

var body: some View {
    ChatView(messages: viewModel.messages) { draft in
        viewModel.send(draft: draft)
    }
}
```
where  
   `messages` - list of messages to display  
   `didSendMessage` - a closure which gets called when the user presses send button  

`Message` is a type `Chat` is using on the inside, here it expects the user to provide a list of `Message` structs, and it also returns a `Message` in `didSendMessage` closure. You can map it both ways on your own Message model your API expects.

You may customize message cells like this: 
```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} messageBuilder: { message, positionInGroup, showAttachmentClosure in
    VStack {
        Text(message.text)
        if !message.attachments.isEmpty {
            ForEach(message.attachments, id: \.id) { at in
                AsyncImage(url: at.thumbnail)
            }
        }
    }
}
```
`messageBuilder`'s parameters:     
- message containing user, attachments, etc.   
- position of message in its continuous group of messages from the same user     
- pass attachment to this closure to use ChatView's fullscreen media viewer     

### Modifiers
if you are not using your own `messageBuilder`:   
`avatarSize` - default avatar is a circle, you can specify its diameter here   
`messageUseMarkdown` - whether default message cell uses markdown     

`assetsPickerLimit` - max media count user can select in the media picker      
`enableLoadMore(offset: Int, handler: @escaping ChatPaginationClosure)` - when user scrolls to `offset`-th meassage from the end, call the handler function, so user can load more messages       
`chatNavigation(title: String, status: String? = nil, cover: URL? = nil)` - pass info for Chat's navigation bar  

<img src="https://raw.githubusercontent.com/exyte/media/master/Chat/pic2.png" width="300">

## Example

To try out the Chat examples:
- Clone the repo `git clone git@github.com:exyte/Chat.git`
- Open terminal and run `cd <ChatRepo>/Example`
- Wait for SPM to finish downloading packages
- Try it!

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/exyte/Chat.git")
]
```

### CocoaPods

```ruby
pod 'ExyteChat'
```

### Carthage

```ogdl
github "Exyte/Chat"
```

## Requirements

* iOS 16+
* Xcode 14+

## Our other open source SwiftUI libraries
[PopupView](https://github.com/exyte/PopupView) - Toasts and popups library    
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll  
[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - A tabbar with number of preset animations         
[MediaPicker](https://github.com/exyte/mediapicker) - Customizable media picker     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators     
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation    

