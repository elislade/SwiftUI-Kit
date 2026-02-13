import SwiftUIKit


struct ExampleView<Example: View, Parameters: View>: View {
    
    @State private var color: Color = .systemAllWithHue.randomElement()!
    @State private var parameterSize: Double = 60
    
    let title: String
    @ViewBuilder let example: Example
    @ViewBuilder let parameters: Parameters
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Color.black
                .ignoresSafeArea()
                .overlay {
                    VStack(spacing: 0){
                        Color.clear.contentShape(Rectangle()).overlay {
                            example
                        }
                        .contentMarginsIfAvailable(.bottom, 28.0)
                        .background(.secondary.opacity(0.15))
                        .background(.background)
                        .mask {
                            ContainerRelativeShape()
                                .ignoresSafeArea()
                        }
                        .containerShape(RoundedRectangle(cornerRadius: 28))
                 
                        ScrollViewReader{ proxy in
                            ScrollView{
                                VStack(alignment: .leading) {
                                    if size.width < 680 {
                                        ExampleTitle(title)
                                        
                                        VStack(spacing: 16) {
                                            parameters
                                        }
                                        .padding(.horizontal, 10)
                                        .environment(\.horizontalSizeClass, .compact)
                                    } else {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(alignment: .top, spacing: 0) {
                                                ExampleTitle(title)
                                                    .frame(minHeight: .controlSize)
                                                    .sticky(edges: .top)
                                                
                                                Spacer(minLength: 22)
                                                
                                                HStack(alignment: .top, spacing: 22) {
                                                    parameters
                                                }
                                                //.scrollTargetLayoutIfAvailable()
                                                .padding(10)
                                            }
                                            .frame(minWidth: size.width)
                                        }
                                        //.scrollTargetViewAlignedIfAvailable()
                                        .scrollClipDisabledIfAvailable()
                                        .environment(\.horizontalSizeClass, .regular)
                                    }
                                }
                                .toggleStyle(.example)
                                .buttonStyle(.example)
                                .onGeometryChangePolyfill(of: \.size.height){ size in
                                    //withAnimation(.smooth.speed(1.6)){
                                        parameterSize = size
                                    //}
                                }
                                .environment(\.scrollTo){ id in
                                    withAnimation(.smooth){
                                        proxy.scrollTo(id, anchor: .topLeading)
                                    }
                                }
                            }
                        }
                        .stickyContext()
                        .frame(maxHeight: parameterSize)
                        .stickyGrouping(size.width < 680 ? .displaced : .none)
                        .symbolRenderingMode(.hierarchical)
                        .environment(\.colorScheme, .dark)
                        .zIndex(1)
                }
            }
        }
        .animation(.smooth.speed(1.6), value: parameterSize)
        #if os(macOS)
        .containerShape(RoundedRectangle(cornerRadius: 16))
        #else
        .containerShape(RoundedRectangle(cornerRadius: 64))
        #endif
        .persistentSystemOverlays(.hidden)
        .presentationContext()
        .tint(color)
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

extension ExampleView where Parameters == EmptyView {
    
    init(_ title: String, @ViewBuilder content: @escaping () -> Example) {
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

extension Color {
    
    static let systemAllWithHue: Set<Color> = [
        .red, .orange, .brown, .yellow,
        .green, .mint, .teal, .cyan,
        .blue, .indigo, .purple, .pink
    ]
    
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
        .deviceOrientationListener()
        #if targetEnvironment(macCatalyst)
        .padding(.top, 36)
        #endif
    }
#endif
    
}


extension EnvironmentValues {
    
    @Entry var scrollTo: (AnyHashable) -> Void = { _ in }
    
}
