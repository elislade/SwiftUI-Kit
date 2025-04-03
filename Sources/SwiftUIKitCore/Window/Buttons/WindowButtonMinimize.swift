import SwiftUI


public struct WindowButtonMinimize: View {
    
    @Environment(\.performWindowAction) private var perform
    
    public init() { }
    
    public var body: some View {
        Button{ perform(.minimize) } label: {
            Label{
                Text("Minimize Window")
            } icon: {
                Image(systemName: "minus")
            }
        }
        .tint(.orange)
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
