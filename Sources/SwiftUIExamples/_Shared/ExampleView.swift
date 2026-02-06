import SwiftUIKit


struct ExampleView<Example: View, Parameters: View>: View {
    
    @State private var color: Color = .systemAllWithHue.randomElement()!
    
    let title: String
    @ViewBuilder let example: Example
    @ViewBuilder let parameters: Parameters
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            //let maxHeight = (size.height / 1.8) - 75
            let isLandscape = size.width > size.height * 1.2
            Color.black
                .ignoresSafeArea()
                .overlay {
                    AxisStack(
                        isLandscape ? .horizontal : .vertical,
                        alignment: .topLeading,
                        spacing:  isLandscape ? 10 : 0
                    ) {
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
                        .zIndex(2)
                    
                        ViewThatFits(in: .vertical) {
                            VStack(spacing: 0) {
                                ExampleTitle(title)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                
                                parameters
                            }
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ExampleTitle(title)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    
                                    parameters
                                }
                            }
                        }
                        .environment(\.colorScheme, .dark)
                        .frame(
                            maxWidth: isLandscape ? min(proxy.size.width / 2.5, 400) : nil
                        )
                        .zIndex(1)
                }
            }
        }
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
