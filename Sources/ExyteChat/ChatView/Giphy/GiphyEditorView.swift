import SwiftUI
import GiphyUISDK

struct GiphyEditorView: View {
    
    @Binding private var selectedMedia: GPHMedia?
    private let giphyConfig: GiphyConfiguration
    
    init(
        giphyConfig: GiphyConfiguration,
        selectedMedia: Binding<GPHMedia?>
    ) {
        self.giphyConfig = giphyConfig
        self._selectedMedia = selectedMedia
    }
    
    var body: some View {
        ZStack {
            GiphyPicker(
                giphyConfig: giphyConfig,
                selectedMedia: $selectedMedia
            )
            .ignoresSafeArea()
            .presentationDetents(
                [.fraction(giphyConfig.presentationDetents)]
            )
            .presentationDragIndicator(.hidden)
            
            if giphyConfig.showAttributionMark {
                GiphyAttributionMarkView()
            }
        }
    }
    
}
