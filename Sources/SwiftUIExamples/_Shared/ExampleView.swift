import SwiftUIKit


struct ExampleView<E: View, P: View>: View {
    
    @Environment(\.deviceOrientation) private var orientation
    
    @State private var panelSize = CGSize.zero
    @State private var color = Color(
        hue: .random(in: 0...1),
        saturation: 0.9,
        brightness: 0.9
    )
    
    let title: String
    @ViewBuilder let example: E
    @ViewBuilder let parameters: P
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let maxHeight = (size.height / 1.8) - 75
            let isLandscape = size.width > size.height * 1.2
            Color.clear.overlay {
                example
            }
            .releaseContainerSafeArea(edges: [.top, .leading])
            .safeAreaInsets(
                isLandscape ? .trailing : .bottom,
                isLandscape ? panelSize.width : panelSize.height
            )
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    ExampleTitle(title)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    if !(parameters is EmptyView) {
                        ViewThatFits(in: .vertical) {
                            VStack(spacing: 0) {
                                parameters
                            }
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    parameters
                                }
                            }
                            .stickyContext()
                        }
                        .overlay(alignment: .top) {
                            Divider().ignoresSafeArea()
                        }
                    }
                }
                .frame(
                    maxHeight: isLandscape ? .infinity : panelSize.height < maxHeight ? nil : maxHeight,
                    alignment: .top
                )
                .examplePanelBG()
                .padding(10)
                .onGeometryChangePolyfill(of: \.size){ panelSize = $0 }
                .frame(maxWidth: isLandscape ? 400 : nil)
            }
            .background{
                ExampleBackground()
                    .ignoresSafeArea()
            }
        }
        .presentationContext()
        #if os(macOS)
        .containerShape(RoundedRectangle(cornerRadius: 16))
        #else
        .containerShape(RoundedRectangle(cornerRadius: 64))
        #endif
        .tint(color)
        .captureContainerSafeArea(edges: .vertical)
        .ignoresSafeAreaOppositeNotch()
        .persistentSystemOverlays(.hidden)
    }
    
}

extension View {
    
    @ViewBuilder func examplePanelBG() -> some View {
        if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            clipShape(ContainerRelativeShape())
                .background{
                    Color.clear.glassEffect(in: .containerRelative)
                }
        } else {
            background {
               ContainerRelativeShape()
                    .fill(.bar)
                    .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
            }
            .overlay {
                EdgeHighlightMaterial(ContainerRelativeShape())
            }
            .clipShape(ContainerRelativeShape())
            .background{
                OuterShadowMaterial(
                    ContainerRelativeShape(),
                    fill: .black.opacity(0.1),
                    radius: 15,
                    y: 8
                )
            }
        }
    }
    
}

struct ExampleBackground: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.background)
            
            Rectangle()
                .fill(.tint)
                .opacity(0.04)
        }
    }
    
}

extension ExampleView where P == EmptyView {
    
    init(_ title: String, @ViewBuilder content: @escaping () -> E) {
        self.title = title
        self.example = content()
        self.parameters = EmptyView()
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
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    func previewSize() -> some View {
        frame(width: 340, height: 600)
            .resetActionContext()
    }
#else
    func previewSize() -> some View {
       background{
            InlineEnvironmentValue(\.colorScheme){ scheme in
                switch scheme {
                case .light: Color.white
                case .dark: Color.black
                @unknown default: Color.clear
                }
            }
            .ignoresSafeArea()
        }
        .resetActionContext()
        .listenForDeviceOrientation()
    }
#endif
    
}
