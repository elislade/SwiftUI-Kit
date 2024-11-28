import SwiftUI


public struct WindowButtonClose: View {
    
    @Environment(\.performWindowAction) private var perform
    
    let shouldQuit: Bool
    
    public init(shouldQuit: Bool = false) {
        self.shouldQuit = shouldQuit
    }
    
    public var body: some View {
        Button(action: { perform(.close(shouldQuit: shouldQuit)) }){
            Label{
                Text("Close Window")
            } icon: {
                Image(systemName: "xmark")
            }
        }
        .tint(.red)
    }
    
}


#Preview {
    HStack {
        WindowButtonClose()
            .buttonStyle(.windowMain)
        
        WindowButtonClose()
            .buttonStyle(.windowPanel)
    }
    .padding()
}
