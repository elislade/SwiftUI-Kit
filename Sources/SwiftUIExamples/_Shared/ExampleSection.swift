import SwiftUIKit

struct ExampleSection<C: View, Label: View> : View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSize
    @Environment(\.scrollTo) private var scrollTo
    @State private var isExpanded = false
    @State private var id = UniqueID()
    
    let content: C
    let label: Label
    
    init(
        isExpanded: Bool = false,
        @ViewBuilder content: @escaping () -> C,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label()
        self.isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Toggle(isOn: $isExpanded.animation(.smooth.speed(1.6))){
                HStack {
                    label
                }
                .font(.exampleSectionTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .toggleStyle(ToggleStyle())
            .background{
                LinearGradient(
                    colors: [
                        .black, .black.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            #if !os(watchOS)
            .sticky(edges: .top)
            #endif
            .fixedSize(
                horizontal: horizontalSize == .compact ? false : !isExpanded,
                vertical: true
            )
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .fixedSize(horizontal: false, vertical: true)
                .transition(
                    .offset([0, 200])
                    + .opacity
                    + .scale(0.8)
                )
            }
        }
        #if !os(watchOS)
        .frame(
            minWidth: isExpanded ? 320 : nil,
            maxWidth: horizontalSize == .compact || !isExpanded ? nil : 440
        )
        #endif
        .id(id)
        .onChange(of: isExpanded){
            if isExpanded {
                scrollTo(id)
            }
        }
    }
    
    
    struct ToggleStyle: SwiftUI.ToggleStyle  {
        
        func makeBody(configuration: Configuration) -> some View {
            Button{
                configuration.isOn.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer(minLength: 10)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(configuration.isOn ? 90 : 0))
                        .font(.title3[.bold])
                        .opacity(0.5)
                }
                #if !os(watchOS)
                .padding(.horizontal, 5)
                #endif
                .frame(height: .controlSize)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        
    }
    
    
}

extension ExampleSection where Label == Text {
    
    init(
        _ title: String,
        isExpanded: Bool = false,
        @ViewBuilder content: @escaping () -> C
    ) {
        self.label = Text(title)
        self.isExpanded = isExpanded
        self.content = content()
    }
    
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ExampleSection{
                Color.random.frame(height: 260)
            } label: {
                Text("Section A")
            }
            
            ExampleSection{
                Color.random.frame(height: 260)
            } label: {
                Text("Section B")
            }
            
            ExampleSection{
                Color.random.frame(height: 260)
            } label: {
                Text("Section C")
            }
        }
    }
    .stickyContext()
    .preferredColorScheme(.dark)
}
