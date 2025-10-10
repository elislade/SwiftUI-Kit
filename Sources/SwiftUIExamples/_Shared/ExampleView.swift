import SwiftUIKit


struct ExampleView<E: View, P: View>: View {
    
    @Environment(\.deviceOrientation) private var orientation
    
    @State private var panelSize = CGSize.zero
    @State private var color = Color(
        hue: .random(in: 0...1),
        saturation: 0.9,
        brightness: 0.9
    )
    
    var maxSize: CGSize = .init(width: 400, height: 340)
    
    let title: String
    @ViewBuilder let example: E
    @ViewBuilder let parameters: P
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomTrailing){
                Color.clear.overlay {
                    example
                }
                .releaseContainerSafeArea(edges: [.top, .leading])
                .safeAreaInsets(
                    orientation.isLandscape ? .trailing : .bottom,
                    orientation.isLandscape ? 450 - 22 : panelSize.height - 22
                )
                
                VStack(spacing: 0) {
                    ExampleTitle(title)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    if !(parameters is EmptyView) {
                        Divider()
                        
                        if orientation.isLandscape {
                            ViewThatFits(in: .vertical){
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
                        } else {
                            if panelSize.height > proxy.size.height / 2.5 {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        parameters
                                    }
                                }
                                .stickyContext()
                                .frame(
                                    maxHeight: orientation.isLandscape ? .infinity : (proxy.size.height / 2.5) - 75
                                )
                            } else {
                                VStack(spacing: 0) {
                                    parameters
                                }
                            }
                        }
                    }
                }
                .examplePanelBG()
                .padding(22)
                .onGeometryChangePolyfill(of: \.size){ panelSize = $0 }
                .frame(maxWidth: orientation.isLandscape ? 450 : nil)
            }
            .background{ ExampleBackground() }
        }
        .presentationContext()
        #if os(macOS)
        .containerShape(RoundedRectangle(cornerRadius: 34))
        #else
        .containerShape(RoundedRectangle(cornerRadius: 64))
        #endif
        .tint(color)
        .captureContainerSafeArea()
        .ignoresSafeAreaOppositeNotch()
    }
    
}

extension View {
    
    @ViewBuilder func examplePanelBG() -> some View {
        if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0, *) {
            clipShape(ContainerRelativeShape())
                .glassEffect(in: .containerRelative)
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
        .resetActionContext()
        .listenForDeviceOrientation()
    }
#endif
    
}
