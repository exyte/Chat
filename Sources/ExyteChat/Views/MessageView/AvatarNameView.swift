import SwiftUI

struct AvatarNameView: View {

    let name: String
    let avatarSize: CGFloat

    var body: some View {
        let letter =
            if let firstLetter = name.first {
                firstLetter.uppercased()
            } else {
                ""
            }
        Text(letter)
            .viewSize(avatarSize)
            .clipShape(Circle())
    }
}

struct AvatarNameView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarNameView(
            name: "Fred",
            avatarSize: 32
        )
    }
}
