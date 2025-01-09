import SwiftUIKit


struct ExampleView<E: View, P: View>: View {
    
    @State private var color = Color(
        hue: .random(in: 0...1),
        saturation: 0.9,
        brightness: 0.9
    )
    
    let title: String
    var maxSize: CGSize = .init(width: 400, height: 340)
    
    @ViewBuilder let example: E
    @ViewBuilder let parameters: P
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0){
                if proxy.size.width > proxy.size.height {
                    ZStack {
                        Color.clear
                        example
                    }
                    .frame(
                        width: min(proxy.size.width / 1.7, proxy.size.width - 340),
                        height: proxy.size.height
                    )
                    .mask {
                        Rectangle().ignoresSafeArea()
                    }
                    .background(.bar)
                    .ignoresSafeArea(edges: .bottom)

                    Divider().ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ExampleTitle(title)
                            .padding(.vertical, 8)
                        
                        parameters
                    }
                    .toggleStyle(.swiftUIKitSwitch)
                    .paddingAddingSafeArea()
                }
                .scrollClipDisabledPolyfill()
                //.sceneInset(proxy.safeAreaInsets)
                //.environment(\.sceneProxy, proxy)
                .stickyContext()
            }
            .safeAreaInset(edge: .top, spacing: 0){
                if proxy.size.width < proxy.size.height {
                    ZStack {
                        Color.clear
                        example
                    }
                    .frame(width: proxy.size.width, height: maxSize.height)
                    .paddingAddingSafeArea()
                    .background(.bar)
                    .overlay(alignment: .bottom) { Divider().ignoresSafeArea() }
                }
            }
        }
        .presentationContext()
        .toolTipContext()
        .tint(color)
    }
    
}


#Preview {
    ExampleView(title: "Title"){
        Image(systemName: "text.below.photo.fill")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 200)
            .padding()
            .opacity(0.3)
    } parameters: {
        ExampleSection("Section"){
            Text("Parameters View")
                .padding()
        }
    }
    .previewSize()
}



extension View {
    
#if canImport(AppKit)
    func previewSize() -> some View {
        frame(width: 340, height: 600)
    }
#else
    func previewSize() -> Self {
        self
    }
#endif
    
}
