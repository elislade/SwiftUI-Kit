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
                #if !os(watchOS)
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
                    .background(.regularMaterial)
                    .ignoresSafeArea(edges: .bottom)

                    Divider().ignoresSafeArea()
                }
                #endif
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        #if os(watchOS)
                        Rectangle()
                            .fill(.background)
                            .aspectRatio(1.5, contentMode: .fit)
                            .overlay { example }
                            .overlay(alignment: .bottom) { Divider() }
                            .clipped()
                            .sticky(edges: .top)
                        #endif
                        
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
                #if os(watchOS)
                .ignoresSafeArea(edges: [.top, .horizontal])
                #endif
            }
            #if !os(watchOS)
            .safeAreaInset(edge: .top, spacing: 0){
                if proxy.size.width < proxy.size.height {
                    ZStack {
                        Color.clear
                        example
                    }
                    .frame(width: proxy.size.width, height: maxSize.height)
                    .paddingAddingSafeArea()
                    .background(.regularMaterial)
                    .overlay(alignment: .bottom) { Divider().ignoresSafeArea() }
                }
            }
            #endif
        }
        .presentationContext()
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
    func previewSize() -> some View {
        InlineEnvironmentValue(\.colorScheme){ sch in
            self
                .background{
                    switch sch {
                    case .light: Color.white
                    case .dark: Color.black
                    @unknown default: Color.clear
                    }
                }
        }
        
    }
#endif
    
}
