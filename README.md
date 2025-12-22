<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

<table>
    <thead>
        <tr>
            <th>Chat</th>
            <th>Media</th>
            <th>Audio Messages</th>
            <th>Extra</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <img src="https://github.com/exyte/Chat/assets/1358172/baf0167f-b3e0-4df2-bd3b-b6b1c4ee385d" />
            </td>
            <td>
                <img src="https://github.com/exyte/Chat/assets/1358172/d62876ef-4475-4f07-933a-9d9366b02e28" />
            </td>
            <td>
                <img src="https://github.com/exyte/Chat/assets/1358172/ebd2040d-1cf0-4066-9391-592af1426571" />
            </td>
            <td>
                <img src="https://github.com/exyte/Chat/assets/1358172/053bcd73-0db7-44da-abd6-0a57f0f88a4b" />
            </td>
        </tr>
    </tbody>
</table>

<p><h1>Chat</h1></p>
<p><h4>A SwiftUI Chat UI framework with fully customizable message cells and a built-in media picker</h4></p>

![](https://img.shields.io/github/v/tag/exyte/Chat?label=Version)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FChat%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/exyte/Chat)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fexyte%2FChat%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/exyte/Chat)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swiftpackageindex.com/exyte/Chat)
[![Cocoapods](https://img.shields.io/badge/Cocoapods-Deprecated%20after%202.4.2-yellow.svg)](https://cocoapods.org/pods/ExyteChat)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

# Features
- Displays your messages with pagination and allows you to create and "send" new messages (sending means calling a closure since user will be the one providing actual API calls)
- Allows you to pass a custom view builder for messages and input views
- Has a built-in photo and video library/camera picker for multiple media asset selection
- Sticker keyboard that integrates with Giphy
- Can display a fullscreen menu on long press a message cell (automatically shows scroll for big messages)
- Supports "reply to message" via message menu or through a closure. Remove and edit are **coming soon**
- This library allows to send the following content in messages in any combination:
    - Arbitrarily styled text with `AttributedString` or markdown
    - Photo/video
    - Audio recording
    - Link with preview
    - Gif/Sticker
    **Coming soon:**
    - User's location
    - Documents

# Usage

Create a chat view like this:
```swift
@State var messages: [Message] = []

var body: some View {
    ChatView(messages: messages) { draft in
        yourViewModel.send(draft: draft)
    }
}
```
where:  
   `messages` - list of messages to display  
   `didSendMessage` - a closure which is called when the user presses the send button  

`Message` is a type that `Chat` uses for the internal implementation. In the code above it expects the user to provide a list of `Message` structs, and it returns a `DraftMessage` in the `didSendMessage` closure. You can map it both ways to your own `Message` model that your API expects or use as is.

## Available chat types
Chat type - determines the order of messages and direction of new message animation. Available options:
- `conversation` - the latest message is at the bottom, new messages appear from the bottom  
- `comments` - the latest message is at the top, new messages appear from the top  

Reply mode - determines how replying to message looks. Available options:
- `quote` - when replying to message A, new message will appear as the newest message, quoting message A in its body  
- `answer` - when replying to message A, new message with appear directly below message A as a separate cell without duplicating message A in its body  

To specify any of these pass them through `init`:
```swift
ChatView(messages: viewModel.messages, chatType: .comments, replyMode: .answer) { draft in
    yourViewModel.send(draft: draft)
}
```

## Custom UI
You may customize message cells like this: 
```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} messageBuilder: { message, positionInUserGroup, positionInMessagesSection, positionInCommentsGroup, showContextMenuClosure, messageActionClosure, showAttachmentClosure in
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
- `message` - the message containing user info, attachments, etc.   
- `positionInUserGroup` - the position of the message in its continuous collection of messages from the same user    
- `positionInMessagesSection` position of message in the section of messages from that day
- `positionInCommentsGroup` - position of message in its continuous group of comments (only works for .answer ReplyMode, nil for .quote mode)  
- `showContextMenuClosure` - closure to show message context menu   
- `messageActionClosure ` - closure to pass user interaction, .reply for example   
- `showAttachmentClosure` - you can pass an attachment to this closure to use ChatView's fullscreen media viewer    

You may customize the input view (a text field with buttons at the bottom) like this: 
```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} inputViewBuilder: { textBinding, attachments, inputViewState, inputViewStyle, inputViewActionClosure, dismissKeyboardClosure in
    Group {
        switch inputViewStyle {
        case .message: // input view on chat screen
            VStack {
                HStack {
                    Button("Send") { inputViewActionClosure(.send) }
                    Button("Attach") { inputViewActionClosure(.photo) }
                }
                TextField("Write your message", text: textBinding)
            }
        case .signature: // input view on photo selection screen
            VStack {
                HStack {
                    Button("Send") { inputViewActionClosure(.send) }
                }
                TextField("Compose a signature for photo", text: textBinding)
                    .background(Color.green)
            }
        }
    }
}
```
`inputViewBuilder`'s parameters:  
- `textBinding` to bind your own TextField   
- `attachments` is a struct containing photos, videos, recordings and a message you are replying to     
- `inputViewState` - the state of the input view that is controlled by the library automatically if possible or through your calls of `inputViewActionClosure`
- `inputViewStyle` - `.message` or `.signature` (the chat screen or the photo selection screen)   
- `inputViewActionClosure` for calling on taps on your custom buttons. For example, call `inputViewActionClosure(.send)` if you want to send your message with your own button, then the library will reset the text and attachments and call the `didSendMessage` sending closure   
- `dismissKeyboardClosure` - call this to dismiss keyboard    

## Custom message menu
Long tap on a message will display a menu for this message (can be turned off, see Modifiers). To define custom message menu actions declare an enum conforming to `MessageMenuAction`. Then the library will show your custom menu options on long tap on message instead of default ones, if you pass your enum's name to it (see code sample). Once the action is selected special callback will be called. Here is a simple example:
```swift
enum Action: MessageMenuAction {
    case reply, edit

    func title() -> String {
        switch self {
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        }
    }
    
    func icon() -> Image {
        switch self {
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            Image(systemName: "square.and.pencil")
        }
    }
    
    // Optional
    // Implement this method to conditionally include menu actions on a per message basis
    // The default behavior is to include all menu action items
    static func menuItems(for message: ExyteChat.Message) -> [Action] {
        if message.user.isCurrentUser  {
            return [.edit]
        } else {
            return [.reply]
        }
    }
}

ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} messageMenuAction: { (action: Action, defaultActionClosure, message) in // <-- here: specify the name of your `MessageMenuAction` enum
    switch action {
    case .reply:
        defaultActionClosure(message, .reply)
    case .edit:
        defaultActionClosure(message, .edit { editedText in
            // update this message's text on your BE
            print(editedText)
        })
    }
}
```
`messageMenuAction`'s parameters:  
- `selectedMenuAction` - action selected by the user from the menu. NOTE: when declaring this variable, specify its type (your custom descendant of MessageMenuAction) explicitly    
- `defaultActionClosure` - a closure taking a case of default implementation of MessageMenuAction which provides simple actions handlers; you call this closure passing the selected message and choosing one of the default actions (.reply, .edit) if you need them; or you can write a custom implementation for all your actions, in that case just ignore this closure
- `message` - message for which the menu is displayed
    
When implementing your own `MessageMenuActionClosure`, write a switch statement passing through all the cases of your `MessageMenuAction`, inside each case write your own action handler, or call the default one. NOTE: not all default actions work out of the box - e.g. for `.edit` you'll still need to provide a closure to save the edited text on your BE. Please see CommentsExampleView in ChatExample project for MessageMenuActionClosure usage example.

## Custom swipe actions

```swift
// Example: Adding Swipe Actions to your ChatView
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} 
.swipeActions(edge: .leading, performsFirstActionWithFullSwipe: false, items: [
    // SwipeActions are similar to Buttons, they accept an Action and a ViewBuilder
    SwipeAction(action: onDelete, activeFor: { $0.user.isCurrentUser }, background: .red) {
        swipeActionButtonStandard(title: "Delete", image: "xmark.bin")
    },
    // Set the background color of a SwipeAction in the initializer,
    // instead of trying to apply a background color in your ViewBuilder
    SwipeAction(action: onReply, background: .blue) {
        swipeActionButtonStandard(title: "Reply", image: "arrowshape.turn.up.left")
    },
    // SwipeActions can also be selectively shown based on the message,
    // here we only show the Edit action when the message is from the current sender
    SwipeAction(action: onEdit, activeFor: { $0.user.isCurrentUser }, background: .gray) {
        swipeActionButtonStandard(title: "Edit", image: "bubble.and.pencil")
    }
])
```
`swipeActions`'s parameters:  
- `edge` - either the leading or trailing edge of the Message
- `performsFirstActionWithFullSwipe` - if true, a full swipe will trigger the first `SwipeAction` provided in the `items` list
- `items` - list of `SwipeAction`s to include

## Small view builders:
These use `AnyView`, so please try to keep them easy enough
- `betweenListAndInputViewBuilder` - content to display in between the chat list view and the input view   
- `mainHeaderBuilder` - a header for the whole chat, which will scroll together with all the messages and headers  
- `headerBuilder` - date section header builder   

## Modifiers 
`isListAboveInputView` - messages table above the input field view or not   
`showDateHeaders` - show section headers with dates between days, default is `true`    
`isScrollEnabled` - forbid scrolling for messages' `UITableView`   
`showMessageMenuOnLongPress` - turn menu on long tap on/off    
`showNetworkConnectionProblem` - display network error on/off    
`keyboardDismissMode` - set keyboard dismiss mode for the chat list (.interactive, .onDrag, or .none), default is .none    
`assetsPickerLimit` - set a limit for MediaPicker built into the library   
`setMediaPickerSelectionParameters` - a struct holding MediaPicker selection parameters (assetsPickerLimit and others like mediaType, selectionStyle, etc.).   
`orientationHandler` - handle screen rotation

`enableLoadMore(offset: Int, handler: @escaping ChatPaginationClosure)` - when user scrolls to `offset`-th message from the end, call the handler function, so the user can load more messages. NOTE: New messages won't appear in the chat unless it's scrolled up to the very top - it's an optimization. 

### Customize default UI
You can use `chatTheme` to customize colors and images of default UI. You can pass all/some colors and images:

```swift
.chatTheme(
    ChatTheme(
        colors: .init(
            mainBackground: .red,
            buttonBackground: .yellow,
            addButtonBackground: .purple
        ),
        images: .init(
            camera: Image(systemName: "camera")
        )
    )
)

// chat view with a full background image  
.chatTheme(
    ChatTheme(
        colors: .init(
            buttonBackground: .yellow,
            addButtonBackground: .purple
        ),
        images: .init(
            background: ChatTheme.Images.Background(
                portraitBackgroundLight: Image("chatBackgroundLight"),
                portraitBackgroundDark: Image("chatBackgroundDark"),
                landscapeBackgroundLight: Image("chatBackgroundLandscapeLight"),
                landscapeBackgroundDark: Image("chatBackgroundLandscapeDark")
            )
    )
)

```
By default the built-in MediaPicker will be auto-customized using the most logical colors from chatTheme. But you can always use `mediaPickerTheme` in a similar fashion to set your own colors.      

### makes sense only for built-in message view    
`avatarSize` - the default avatar is a circle, you can specify its diameter here   
`tapAvatarClosure` - closure to call on avatar tap    
`messageUseMarkdown` - use markdown (e.g. ** to make something bold) or not    
`messageUseStyler` - pass a function that converts the message's `String` to the styled `AttributedString`    
`showMessageTimeView` - show timestamp in a corner of the message    
`messageLinkPreviewLimit` - limit the maximum number of link previews per message
`linkPreviewsDisabled` - completely disable message link previews
`setMessageFont` - pass custom font to use for messages   

### makes sense only for built-in input view
`setAvailableInput` - hide some buttons in default InputView. Available options are:    
    - `.full` - media + text + audio   
    - `.textAndMedia`   
    - `.textAndAudio`   
    - `.textOnly`    
  
<img src="https://raw.githubusercontent.com/exyte/media/master/Chat/pic2.png" width="300">

## Large Attachment Support

The library provides full support for uploading multiple attachments larger than 100 MB and for reporting upload status on both the sender’s and receiver’s message views. It offers flexibility in how much progress tracking functionality the client implements, allowing developers to omit percentage-based updates if desired. Sending percentage updates to the receiver requires careful handling, as it involves multiple WebSocket calls to synchronize status between sender and receiver.

*Option 1*

No status is passed to an Attachment. This is the default behavior and shows no progress indicators. If the full attachment is uploaded to a resource server before the message is sent to the receiver, use this method, as it is the simplest and requires no progress tracking.

```swift
Attachment(
  fullUploadStatus: Attachment.UploadStatus? = nil
)
```

*Option 2*

A progress indicator is displayed without a percentage. Most chat applications handle multiple large (100 MB+) files, which may take several minutes to upload. In these cases, Option 1 results in a poor user experience because the receiver has no indication that the files are being uploaded. Option 2 allows both the sender and receiver to see a generic progress indicator during the upload.

```swift
Attachment(
  fullUploadStatus: Attachment.UploadStatus? = Attachment.UploadStatus.inProgress(nil)
)
```

*Option 3*: 

A progress indicator is displayed with a percentage. This option provides the best user experience, as it shows the progress of the upload. However, it adds implementation complexity: both the sender and receiver must remain synchronized through multiple WebSocket updates (e.g., 10%, 20%, …). For production-quality chat applications, implementing this option is recommended.

```swift
Attachment(
  fullUploadStatus: Attachment.UploadStatus? = Attachment.UploadStatus.inProgress(0)
)
```

When implementing status updates via Option 2/3 the following status updates need to be handled by the client:

```swift
// When the upload completes, send a final message to stop displaying the progress indicator.
let completeUpload = Attachment(fullUploadStatus: Attachment.UploadStatus.complete)
sendToServer(initialProgress)

// If the user cancels an attachment upload, report this to the receiver.
let cancelUpload = Attachment(fullUploadStatus: Attachment.UploadStatus.cancelled)
sendToServer(cancelUpload)

// If the upload to the resource server fails, send an error status to the receiver.
let errorUpload = Attachment(fullUploadStatus: Attachment.UploadStatus.error)
sendToServer(errorUpload)
```

## Sticker Keyboard

You can pick and send animated gifs via the integrated sticker keyboard. In order to use this functionality a client id must be granted via the [Giphy Developers](https://developers.giphy.com/) site.

To include the sticker keyboard:

```swift
.setAvailableInputs([.text, .giphy])
.giphyConfig(
    GiphyConfiguration(
        giphyKey: "client id",
        mediaTypeConfig: [.recents, .gifs, .stickers, .clips],
        showAttributionMark: true
    )
)
```

To approve a production client Id for your app, Giphy requires that you include a "Powered By GIPHY" attribution mark, see [attribution mark requirement](https://support.giphy.com/hc/en-us/articles/360035158592-What-conditions-does-my-app-project-need-to-meet-in-order-to-get-a-production-API-Key). Setting the showAttributionMark in the GiphyConfiguration struct will include a small overlay image on the giphy picker which meets the requirement needed for a production client key.


## Localization

You can localize the inputs using the standard SwiftUI localization process, add the input strings to each languages Localizable.strings file.  
The library uses the following text that can be localized:

- Type a message...
- Add signature...
- Cancel
- Recents
- Waiting for network
- Recording...
- Reply to

## Image Caching with Cache Keys

The Chat framework uses Kingfisher for efficient image caching. You can provide custom cache keys. By default, the cache key is the URL of the image.

### User Avatar Cache Keys

When creating a `User`, you can specify a custom cache key for the avatar image:

```swift
let user = User(
    id: "user123",
    name: "John Doe",
    avatarURL: URL(string: "https://example.com/avatar.jpg"),
    avatarCacheKey: "user_avatar_123", // Custom cache key
    isCurrentUser: false
)
```

### Attachment Cache Keys

For `Attachment` objects, you can specify separate cache keys for thumbnail and full-size images:

```swift
let attachment = Attachment(
    id: "attachment456",
    thumbnail: URL(string: "https://example.com/thumb.jpg"),
    full: URL(string: "https://example.com/full.jpg"),
    type: .image,
    thumbnailCacheKey: "thumb_456", // Cache key for thumbnail
    fullCacheKey: "full_456"        // Cache key for full image
)
```

## Examples
There are 2 example projects:    
- One has a simple bot posting random text/media messages every 2 seconds. It has no back end and no local storage. Every new start is clean and fresh.     
- Another has an integration with Firestore data base. It has all the necessary back end support, including storing media and audio messages, unread messages counters, etc. You'll have to create your own Firestore app and DB. Also replace `GoogleService-Info` with your own. After that you can test on multiple sims/devices.    

To set up the Firestore example:
1. Create your Firebase app at https://console.firebase.google.com/
2. Create a Firestore database (for lightweight text data) - see https://firebase.google.com/docs/firestore/manage-data/add-data
3. Create a Cloud Storage bucket (for images and voice recordings) - see https://firebase.google.com/docs/storage/web/start

## Examples

To try the Chat examples:
- Clone the repo `https://github.com/exyte/Chat.git`
- Open `ChatExample.xcodeproj` or `ChatFirestoreExample.xcodeproj` in Xcode
- Try it!

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/Chat.git")
]
```

## Requirements

* iOS 17+
* Xcode 15+

## Our other open source SwiftUI libraries
[PopupView](https://github.com/exyte/PopupView) - Toasts and popups library    
[AnchoredPopup](https://github.com/exyte/AnchoredPopup) - Anchored Popup grows "out" of a trigger view (similar to Hero animation)   
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll    
[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - A tabbar with a number of preset animations   
[MediaPicker](https://github.com/exyte/mediapicker) - Customizable media picker     
[OpenAI](https://github.com/exyte/OpenAI) Wrapper lib for [OpenAI REST API](https://platform.openai.com/docs/api-reference/introduction)    
[AnimatedGradient](https://github.com/exyte/AnimatedGradient) - Animated linear gradient     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[FlagAndCountryCode](https://github.com/exyte/FlagAndCountryCode) - Phone codes and flags for every country    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation

