import SwiftUI


public struct WindowButtonMinimize: View {
    
    @State private var action: () -> Void = {}
    
    public init() { }
    
    public var body: some View {
        Button{
            action()
        } label: {
            Label{
                Text("Minimize Window")
            } icon: {
                Image(systemName: "minus")
            }
        }
        .tint(.orange)
        #if os(macOS)
        .windowReference{ window in
            action = { window.miniaturize(nil) }
        }
        #endif
    }
    
}


#Preview {
    HStack {
        WindowButtonMinimize()
            .buttonStyle(.windowMain)
        
        WindowButtonMinimize()
            .buttonStyle(.windowPanel)
    }
    .padding()
}
