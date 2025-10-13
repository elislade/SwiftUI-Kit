import SwiftUIKit

struct ExampleSection<C: View> : View {
    
    @State private var isExpanded = false
    @State private var isSticking = false
    
    let title: String
    let content: C
    
    init(_ title: String, isExpanded: Bool = false, @ViewBuilder content: @escaping () -> C) {
        self.title = title
        self.isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        Toggle(isOn: $isExpanded.animation(.smooth.speed(1.6))){
            Text(title)
                .font(.exampleSectionTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .toggleStyle(ToggleStyle())
        .background{
            ZStack(alignment: .bottom) {
                VisualEffectView()
                Divider()
            }
            .ignoresSafeArea()
            .opacity(isSticking ? 1 : 0)
        }
        .sticky(edges: isExpanded ? .top : []){ isSticking = $0.isSticking }
        .fixedSize(horizontal: false, vertical: true)
        
        if isExpanded {
            VStack(spacing: 0) {
                content
            }
            .transitions(.hinge(.top), .opacity)
        }
    }
    
    
    struct ToggleStyle: SwiftUI.ToggleStyle  {
        
        func makeBody(configuration: Configuration) -> some View {
            Button{
                configuration.isOn.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(configuration.isOn ? 90 : 0))
                        .font(.title3[.bold])
                        .opacity(0.5)
                }
                .padding(.cellPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        
    }
    
    
}


#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ExampleSection("Section A"){
                Color.random.frame(height: 260)
            }
            
            ExampleSection("Section B"){
                Color.random.frame(height: 260)
            }
            
            ExampleSection("Section C"){
                Color.random.frame(height: 260)
            }
        }
    }
    .stickyContext()
}
