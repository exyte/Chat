//
//  Created by Alex.M on 01.06.2022.
//

import SwiftUI
import AssetsPicker

/*
 TODO: - Create preview from media
        - Make each media deletable
 */
struct MediaSendPreview: View {
    var medias: [Media]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(medias) { media in

                    // TODO: Uncomment from here
//                    AsyncImage(url: url) { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 70)
//                    } placeholder: {
//                        Text("Loading")
//                    }
                    // TODO: to here
                    // TODO: Remove from here
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(1, contentMode: .fit)
                    // TODO: to here
                        .frame(maxHeight: 70)
                        .padding()
                }
            }
        }
    }
}
