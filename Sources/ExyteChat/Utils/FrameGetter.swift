//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import SwiftUI

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != self.size {
                        DispatchQueue.main.async {
                            self.size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

struct MaxHeightGetter: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size.height > self.height {
                        DispatchQueue.main.async {
                            self.height = proxy.size.height
                        }
                    }
                    return Color.clear
                }
            )
    }
}

extension View {

    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
    
    func maxHeightGetter(_ height: Binding<CGFloat>) -> some View {
        modifier(MaxHeightGetter(height: height))
    }
}

actor MessageMenuPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

struct MessageMenuPreferenceViewSetter: View {
    let id: String

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: MessageMenuPreferenceKey.self,
                            value: [id: geometry.frame(in: .global)])
        }
    }
}

struct FinalMeasuringTrickView<Content: View>: View {
    @Binding var size: CGSize
    @State private var rawSize: CGSize = .zero
    var id: String?

    let content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            if let id {
                                print("measuring", id, rawSize, geo.size)
                            }
                            if geo.size.height != 0 {
                                rawSize = geo.size
                            }
                        }
                        .onChange(of: geo.size) { _ , newSize in
                            if let id {
                                print("measuring", id, rawSize, newSize)
                            }
                            if newSize.height != 0 {
                                rawSize = newSize
                            }
                        }
                }
            )
            .onChange(of: rawSize) { _ , newValue in
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(16)) // 1 frame
                    if let id {
                        print("measuring", id, "rawSize change", rawSize, newValue)
                    }
                    if rawSize == newValue {
                        size = newValue
                    }
                }
            }
            .hidden()
    }
}
