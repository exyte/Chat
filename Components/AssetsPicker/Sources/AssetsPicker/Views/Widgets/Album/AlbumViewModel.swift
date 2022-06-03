//
//  Created by Alex.M on 03.06.2022.
//

#if os(iOS)
import UIKit.UIImage
#endif

class AlbumViewModel: ObservableObject {
    let album: AlbumModel
    
    init(album: AlbumModel) {
        self.album = album
    }
    
#if os(iOS)
    @Published var preview: UIImage? = nil
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    func fetchPreview() {
        guard preview == nil
        else { return }
        let side = 100.0 * UIScreen.main.scale * 2
        let size = CGSize(width: side, height: side)
        AssetUtils
            .image(from: album.medias.first?.source, size: size)
            .assign(to: &$preview)
    }
}
