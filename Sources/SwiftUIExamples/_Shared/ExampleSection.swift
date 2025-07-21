import SwiftUIKit

struct ExampleSection<C: View> : View {
    
    let title: String
    @State private var isExpanded = false
    let content: C
    @State private var isSticking = false
    
    init(_ title: String, isExpanded: Bool = false, @ViewBuilder content: @escaping () -> C) {
        self.title = title
        self.isExpanded = isExpanded
        self.content = content()
    }
    
    private func toggle() {
        withAnimation(.smooth.speed(1.6)){
            isExpanded.toggle()
        }
    }
    
    var body: some View {
        Button(action: toggle){
            HStack(spacing: 0) {
                Text(title)
                    .font(.exampleSectionTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer(minLength: 14)
                
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .font(.title3[.bold])
                    .opacity(0.5)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.none)
        .background{
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.regularMaterial)
                
                Divider().ignoresSafeArea()
            }
            .paddingSubtractingSafeArea()
            .opacity(isSticking ? 1 : 0)
        }
        .sticky(edges: isExpanded ? .top : []){ isSticking = $0.isSticking }
        
        if isExpanded {
            VStack(spacing: 0) {
                content
            }
            .transitions(.hinge(.top), .opacity)
        }
    }
    
}


#Preview {
    GeometryReader { proxy in
        ScrollView {
            VStack(spacing: 0) {
                ExampleSection("Section Title"){
                    Color.random.frame(height: 200)
                }
                
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sceneInset(proxy.safeAreaInsets)
    }
}
