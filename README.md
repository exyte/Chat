<img src="https://raw.githubusercontent.com/exyte/media/master/common/header.png">
<img src="https://raw.githubusercontent.com/exyte/media/master/Chat/pic1.png">

<p><h1>Chat</h1></p>

<p><h4>Chat with fully customizable message cells and built-in media picker written with SwiftUI</h4></p>

[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)
![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)
[![SPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://www.swift.org/package-manager/)
[![Cocoapods Compatible](https://img.shields.io/badge/cocoapods-Compatible-brightgreen.svg)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)


___

<p> We are a development agency building
<a href="https://clutch.co/profile/exyte#review-731233">phenomenal</a> apps.</p>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

# Features
- Displays your messages with pagination and allows you to create and "send" new messages (sending means calling a closure since user will be the one providing actual API calls)    
- Allows you to pass custom view builder for message and input view    
- Has a built-in photo/video library/camera picker for multiple media selection   
- Can display fullscreen menu on message long press (automatically shows scroll for big messages)
- Supports "reply to message" via message menu, remove and edit are **coming soon**
- Supports voice recording, video/photo and text, more content types are **coming soon**

# Usage

Create a chat view like this:
```swift
@State var messages: [Message] = []

var body: some View {
    ChatView(messages: viewModel.messages) { draft in
        viewModel.send(draft: draft)
    }
}
```
where:  
   `messages` - list of messages to display  
   `didSendMessage` - a closure which gets called when the user presses send button  

`Message` is a type `Chat` is using on the inside, here it expects the user to provide a list of `Message` structs, and it also returns a `Message` in `didSendMessage` closure. You can map it both ways on your own Message model your API expects.

## Customization
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

You may customize input view (text field with buttons at the bottom) like this: 
```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} inputViewBuilder: { textBinding, attachments, state, style, actionClosure in
    Group {
        switch style {
        case .message: // input view on chat screen
            VStack {
                HStack {
                    Button("Send") { actionClosure(.send) }
                    Button("Attach") { actionClosure(.photo) }
                }
                TextField("Write your message", text: textBinding)
            }
        case .signature: // input view on photo selection screen
            VStack {
                HStack {
                    Button("Send") { actionClosure(.send) }
                }
                TextField("Compose a signature for photo", text: textBinding)
                    .background(Color.green)
            }
        }
    }
}
```
`inputViewBuilder`'s parameters:  
- textBinding for your own TextField   
- attachments struct containing photos, videos, recording and a message you are replying to     
- state of input view - is controled by the library automatically if possible or through your calls of actionClosure
- style - .message or .signature (chat screen or photo selection screen)   
- actionClosure to call on taps of your custom buttons. For example, call actionClosure(.send) if you'd like to send your message, then the library will reset text and attachments and call sending closure `didSendMessage`

## Supported content types
Library allows to send following content in messages in any combination:
- Text with/without markdown
- Photo/video
- Audio recording

**Coming soon:**
- User's location
- Document

### Modifiers
if you are not using your own `messageBuilder`:   
`avatarSize` - default avatar is a circle, you can specify its diameter here   
`messageUseMarkdown` - whether default message cell uses markdown     

`assetsPickerLimit` - max media count user can select in the media picker      
`enableLoadMore(offset: Int, handler: @escaping ChatPaginationClosure)` - when user scrolls to `offset`-th message from the end, call the handler function, so user can load more messages       
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

