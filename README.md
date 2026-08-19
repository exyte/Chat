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
- Supports reply, edit, and delete via the message menu
- This library allows to send the following content in messages in any combination:
    - Arbitrarily styled text with `AttributedString` or markdown
    - Photo/video
    - Audio recording
    - Link with preview
    - Gif/Sticker
    - Documents (any file type, picked via the system document picker)
    - Location - a static location, or a live location share that keeps updating for 15 minutes, 1 hour, or 8 hours
    - Custom dictionary of any Sendable

## Migration to version 3

- `enableLoadMore(pageSize...)` renamed `enableLoadMore(offset...)` and its trailing closure doesn't have any arguments
- `linkPreviewsDisabled` refactored `linkPreviewsEnabled`
- `shouldShowLinkPreview` renamed `shouldShowPreviewForLink`
- `messageUseMarkdown` and `messageUseStyler` removed. now messages use markdown and underline links by default. if you'd like to use your own attributes, use `Message`'s init taking AttributedString. storing `AttributedString` directly instead of storing a string and applying attributes on-the-fly is more efficient.
- The closure arguments of `messageBuilder` and `inputViewBuilder` now each consist of a single struct (they are different structs). See [`ChatBuilderParameters.swift`](./Sources/ExyteChat/Views/ChatBuilderParameters.swift)

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

`Message` stores the text in an `AttributedString`. You can pass your own `AttributedString` or a simple `String`, in which case `Message`'s init will apply default attributes: markdown and links underlines.

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
} messageBuilder: { params in
    let message = params.message
    VStack {
        Text(message.attributedText)
        if !message.attachments.isEmpty {
            ForEach(message.attachments, id: \.id) { at in
                AsyncImage(url: at.thumbnail)
            }
        }
    }
}
```

To customize only some messages while keeping the default style for others, use `messageBuilder` and return your custom view for the messages you want to style, and `params.defaultMessageView()` for the rest. This way you can mix custom message cards with ExyteChat's built-in styling in the same chat.

```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
} messageBuilder: { params in
    if needsCustomUI(params.message) {
        MyCustomMessageView(message: params.message)
    } else {
        params.defaultMessageView()
    }
}
```

Here `params` is a [`MessageBuilderParameters`](./Sources/ExyteChat/Views/ChatBuilderParameters.swift) struct, it has the following parameters:  
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
} inputViewBuilder: { params in
    let action = params.inputViewActionClosure
    Group {
        switch params.inputViewStyle {
        case .message: // input view on chat screen
            VStack {
                HStack {
                    Button("Send") { action(.send) }
                    Button("Attach") { action(.photo) }
                }
                TextField("Write your message", text: params.text)
            }
        case .signature: // input view on photo selection screen
            VStack {
                HStack {
                    Button("Send") { action(.send) }
                }
                TextField("Compose a signature for photo", text: params.text)
                    .background(Color.green)
            }
        }
    }
}

```
Here `params` is an [`InputViewBuilderParameters`](./Sources/ExyteChat/Views/ChatBuilderParameters.swift) struct, it has the following parameters:   
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
    case reply, edit, delete

    func title() -> String {
        switch self {
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        case .delete:
            "Delete"
        }
    }
    
    func icon() -> Image {
        switch self {
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            Image(systemName: "square.and.pencil")
        case .delete:
            Image(systemName: "trash")
        }
    }

    // Optional
    // Return true to show a confirmation alert before calling your messageMenuAction closure.
    // The action will be styled in red in the menu.
    func isDestructive() -> Bool { self == .delete }

    // Optional
    // Implement this method to conditionally include menu actions on a per message basis
    // The default behavior is to include all menu action items
    static func menuItems(for message: ExyteChat.Message) -> [Action] {
        message.user.isCurrentUser ? [.reply, .edit, .delete] : [.reply]
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
    case .delete:
        yourViewModel.delete(message: message)
    }
}
```
`messageMenuAction`'s parameters:  
- `selectedMenuAction` - action selected by the user from the menu. NOTE: when declaring this variable, specify its type (your custom descendant of MessageMenuAction) explicitly    
- `defaultActionClosure` - a closure taking a case of default implementation of MessageMenuAction which provides simple actions handlers; you call this closure passing the selected message and choosing one of the default actions (.copy, .reply, .edit, .share) if you need them; or you can write a custom implementation for all your actions, in that case just ignore this closure
- `message` - message for which the menu is displayed
    
When implementing your own `MessageMenuActionClosure`, write a switch statement passing through all the cases of your `MessageMenuAction`, inside each case write your own action handler, or call the default one. NOTE: not all default actions work out of the box - e.g. for `.edit` you'll still need to provide a closure to save the edited text on your BE. Please see CommentsExampleView in ChatExample project for MessageMenuActionClosure usage example.

## Small view builders:
These use `AnyView`, so please try to keep them easy enough
- `mainHeaderBuilder` - a header for the whole chat, which will scroll together with all the messages and headers  
- `headerBuilder` - date section header builder   
- `betweenListAndInputViewBuilder` - content to display in between the chat list view and the input view   

## Modifiers   
`isListAboveInputView` - messages table above the input field view or not    
`showScrollToBottomButton` - little arrow button appearing when offset != 0     
`showNetworkConnectionProblem` - display network error on/off    
`showDateHeaders` - show section headers with dates between days, default is `true`     
`isScrollEnabled` - forbid scrolling for messages' `UITableView`      
`keyboardDismissMode` - set keyboard dismiss mode for the chat list (.interactive, .onDrag, or .none), default is .none    
`autoFocusTextInputOnChatOpen` - automatically focus the inputTextView when the chat view is opened, default is `false`
`showMessageMenuOnLongPress` - turn menu on long tap on/off    
`showShareAttachmentButton` - show/hide the share button in the fullscreen attachment viewer, default is `true`    
`messageMenuAnimationDuration` - control how fast/snappy the message menu animations feel    
`contentInsets` - set additional content insets for the messages list   
`onContentOffsetChange` - get table's content offset updates  
`scrollTo` - scroll to messageID, certain pixels offset, top or bottom
`onWillDisplayCell` - UITableView's will display cell delegate calls this closure     
`enableLoadMore(offset: Int = 0, _ handler: @escaping ()->())` - when user scrolls up to `offset`-th message from the end, call the handler   function, so user can load more messages    
`localization` - can be localized in the Localizable.strings files    
`onLiveLocationBroadcast` - `(LiveLocationBroadcastEvent) -> Void`, called as this device's own active live location share progresses - `.updated(messageId:liveLocation:)` on every fresh fix, `.ended(messageId:)` when it stops (see Location Attachments below)    

### Update transactions
`updateTransaction` - awaitable updates helper similar in usage to `tableView.performBatchUpdates`
```swift
await updateTransaction(animationMode: .natural) {
    self.messages.append(nextMessage)
    self.currentTableContentOffset = offset
}
``` 
available modes are:
- `none` - no animations
- `natural` - standard UITableView's animations
- `keepStable` - no animations + if you insert rows to the "front" of the table - it keeps the current scroll position (normally it would jump because contentSize and contentOffset changed)

### Delete action (default menu)
If you use the default message menu (no custom `MessageMenuAction` enum), you can add a "Delete" button with a confirmation alert using:

```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
}
.deleteMenuActionClosure(activeFor: { $0.user.isCurrentUser }) { message in
    yourViewModel.delete(message: message)
}
```
- `activeFor` - optional predicate; when provided, the Delete button only appears for messages where it returns `true`
- The closure is called only after the user confirms the alert

If you define your own `MessageMenuAction` enum with a `.delete` case marked `isDestructive()`, use that instead — the confirmation alert is handled automatically there too.

### Reactions    
`messageReactionDelegate` - provide a custom reaction delegate for handling and configuring message reactions    
`onMessageReaction` - configure reactions using closures (didReactTo, canReactTo, available reactions, emoji search, overview, etc.)  

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

### makes sense only for built-in message view    
`showMessageTimeView` - show timestamp in a corner of the message    
`showUsername` - show username on top of message
`messageLinkPreviewLimit` - limit the maximum number of link previews per message    
`linkPreviewsEnabled` - enable or disable message link previews globally    
`shouldShowPreviewForLink` - provide custom logic to decide whether a specific URL should show a preview    
`setMessageFont` - pass custom font to use for messages      

`showAvatar` - show user avatars    
`avatarSize` - the default avatar is a circle, you can specify its diameter here    
`tapAvatarClosure` - closure to call on avatar tap    
`avatarBuilder` - custom avatar view builder. NOTE: this view is not autosizing, `avatarSize` will still be applied, since it needs to be fixed and same for all user avatars   

### makes sense only for built-in input view    
`inputViewText` - binding to current text in the default input text field    
`setAvailableInputs` - construct an array of these:    
    - `.text`    
    - `.media`    
    - `.audio`    
    - `.giphy`    
    - `.document`    
    - `.location`    
`setRecorderSettings` - customize audio recorder settings    
`audioRecordingMode` - choose how audio recording is triggered:    
    - `.holdToRecord` (default) - hold the mic button to record; slide up to lock into hands-free mode    
    - `.tapToToggle` - tap the mic button once to start recording, tap the stop button to finish. No lock capsule    
`assetsPickerLimit` - set a limit for MediaPicker built into the library    
`setMediaPickerSelectionParameters` - a struct holding MediaPicker selection parameters (selection limit, media type, selection style, etc.)    
`setMediaPickerParameters` - configure low-level MediaPicker parameters    
`orientationHandler` - handle screen rotation during media picking    
`photoPickerBackend` - choose which photo/video picker is presented when the user taps to attach media:    
    - `.custom` (default) - ExyteMediaPicker fully customizable built-in media picker    
    - `.system` - Apple's native `PhotosPicker` for apps that don't need a customized picker UI. Selected items are shown as a removable thumbnail strip above the input field, and camera capture always uses the ExyteMediaPicker regardless of this setting.    

The attach button on the left opens a popup menu to choose between Media and GIF when both are available via `setAvailableInputs`. If `photoPickerBackend` is `.system`, a separate Camera entry is also added to the menu, since Apple's native `PhotosPicker` can't capture photos/video itself; with the default `.custom` backend, camera capture is reachable from within the media picker itself, so no separate entry is needed. If there's only one attachment option in total, tapping the button triggers it directly with no popup. The right side of the input field shows a clear ("x") button to quickly clear typed text once the field is non-empty.    

### Customize default colors and images
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

## Attachment Sharing

Users can share attachments out of the chat via the system share sheet. There are two entry points:

- **Fullscreen media viewer** - tapping an image/video attachment opens the fullscreen viewer, which shows a share button that shares the currently displayed attachment. Toggle it with `showShareAttachmentButton` (see Modifiers), default is `true`.
- **Message context menu** - long tap on a message shows a `Share` action (`DefaultMessageMenuAction.share`) whenever the message has at least one attachment that finished uploading. Selecting it shares all of that message's attachments together in a single share sheet. This action is only included for `DefaultMessageMenuAction`; if you supply your own `MessageMenuAction` enum (see Custom message menu) you decide whether to include a share action.

Remote attachments (non-`file://` URLs) are downloaded to a temporary file before sharing so that actions like Save Image/Video and AirDrop work with real file data instead of just a link.

## Document Attachments

To let users attach arbitrary files, add `.document` to `setAvailableInputs`:

```swift
.setAvailableInputs([.text, .media, .document])
```

Tapping the attach button opens the system `UIDocumentPickerViewController` (multi-selection is enabled). Picked files show up as removable chips above the input field, get sent alongside the rest of the message, and arrive as regular `Attachment`s with `type == .document`:

```swift
if let document = message.attachments.first(where: { $0.type == .document }) {
    document.fileName  // original file name
    document.fileSize  // bytes, if available  
    document.full      // local file URL right after sending, replace with a remote URL once you've uploaded it (see Large Attachment Support)  
}  
```

Tapping a document bubble opens the fullscreen viewer with an "Open" button that calls `UIApplication.shared.open(attachment.full)` - this works well once `full` is a real `https://` URL (opens it in Safari/downloads), but not for local `file://` URLs, so make sure to upload the file and swap in a remote URL before other participants receive the message.

## Location Attachments

To let users attach their location, add `.location` to `setAvailableInputs`:

```swift
.setAvailableInputs([.text, .media, .location])
```

Your app's `Info.plist` needs `NSLocationWhenInUseUsageDescription` for the location picker to be able to request permission.

Tapping the attach button opens a map (`LocationPickerView`) where the user can drop a location (tap the map, or tap the location button to center on their current position) and either:
- **Send this location** - sends a single static location, or
- **Share Live Location** - opens a dialog to pick a duration (**15 minutes**, **1 hour**, or **8 hours**) and starts a live share

Static locations and live shares are two different, unrelated model types - a static location is just a coordinate, a live share is a whole different concept (it keeps updating, has a duration, can be stopped). `Message`/`DraftMessage` carry them as two independent optional fields, `location: StaticLocation?` and `liveLocation: LiveLocation?`, never both at once for a given message:

```swift
public struct StaticLocation {
    public var latitude: Double
    public var longitude: Double
}

public struct LiveLocation {
    public var latitude: Double
    public var longitude: Double
    public var lastUpdateAt: Date   // when this coordinate fix was captured
    public var startedAt: Date    // when this share started
    public var expiresAt: Date    // when this share ends

    public var isActive: Bool     // Date() < expiresAt
    public var isEnded: Bool      // !isActive
}
```

Both also expose a `coordinate: CLLocationCoordinate2D` computed property and a `StaticLocation(coordinate:)` / `LiveLocation(coordinate:lastUpdateAt:startedAt:expiresAt:)` convenience init, for when you're working with CoreLocation/MapKit types directly.

In the message list, a static location renders as a small map with a simple map marker. A live share renders Telegram-style: the sender's avatar as a pin on the map (with a small accent-colored dot underneath), plus a colored footer bar below the map showing "Live Location", "updated Xm ago"/"updated just now", and a circular badge counting down the minutes left. Once it ends, the map desaturates and the footer switches to "Live location ended". This is exactly what the sender sees too - a live share looks the same in your own outgoing message bubble as it does for everyone else, there's no separate "you are sharing" banner anywhere else in the UI.

Tapping any location bubble (yours or a peer's) opens `FullscreenLocationView`, an interactive fullscreen map with an "Open in Maps" button. If it's a live share, the same live status bar (with countdown) is repeated at the bottom - and if it's a live share **you are currently broadcasting from this device**, that bar also includes a **Stop Sharing** button, so the only place the sender can end their own broadcast is on the message itself (their own bubble, or its fullscreen view), exactly like everyone else's read-only view of it.

### How live location sharing works

The device's location tracking (`CLLocationManager`) is entirely internal to ExyteChat - you never touch CoreLocation yourself. What the library *can't* do is push updates to other participants, since it has no networking layer of its own (same as for regular messages):

1. When the user starts a live share, `InputViewModel` assigns the outgoing `DraftMessage` a stable `id` up front so later updates can find it again.
2. Once you call your `didSendMessage` closure for that draft, `ChatView` starts a `CLLocationManager` session (`LiveLocationBroadcaster`) that keeps sampling the device's location. Only one share can broadcast at a time - starting a new live share ends whichever one was already active (you'll see its `.ended` event fire before the new share's first `.updated`), the same way Telegram only lets you broadcast one live location at once.
3. On every fix, `onLiveLocationBroadcast(.updated(messageId, liveLocation))` is called - use it to update that message's `liveLocation` in your own message store/backend (see `MockChatInteractor.updateLiveLocation` in the example project) and propagate it to other participants however your app does that.
4. When the share ends - duration elapsed, sender tapped **Stop Sharing**, or it got superseded by a new share - one final `.updated` is delivered with `expiresAt` set to "now" (so every viewer's UI flips to "ended" immediately instead of waiting out the original duration), then `.ended(messageId)` fires.

```swift
ChatView(messages: viewModel.messages) { draft in
    viewModel.send(draft: draft)
}
.setAvailableInputs([.text, .media, .location])
.onLiveLocationBroadcast { event in
    switch event {
    case .updated(let messageId, let liveLocation):
        yourViewModel.updateLiveLocation(messageId: messageId, liveLocation: liveLocation)
    case .ended(let messageId):
        print("Live location sharing ended for \(messageId)")
    }
}
```

**Background limitation:** live updates keep flowing while your app is active or briefly backgrounded, but not indefinitely once the app is fully suspended. To keep broadcasting while backgrounded for longer, your app needs to opt into the `location` `UIBackgroundModes` entry (Info.plist) and the matching background modes capability/entitlement in Xcode - ExyteChat detects this automatically (`allowsBackgroundLocationUpdates` is only set when your app declares that background mode) and otherwise degrades gracefully instead of crashing.

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
- Media
- GIF
- Camera
- Document
- Location

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

## Running the Examples

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
[CalendarView](https://github.com/exyte/CalendarView) - Calendar view with fully customizable month/day cells     
[OpenAI](https://github.com/exyte/OpenAI) Wrapper lib for [OpenAI REST API](https://platform.openai.com/docs/api-reference/introduction)    
[AnimatedGradient](https://github.com/exyte/AnimatedGradient) - Animated linear gradient     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[FlagAndCountryCode](https://github.com/exyte/FlagAndCountryCode) - Phone codes and flags for every country    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation
