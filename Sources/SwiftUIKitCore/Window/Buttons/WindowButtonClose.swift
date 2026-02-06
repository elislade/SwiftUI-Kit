import SwiftUI


public struct WindowButtonClose: View {
    
    @State private var action: () -> Void = {}
    
    let shouldQuit: Bool
    
    public init(shouldQuit: Bool = false) {
        self.shouldQuit = shouldQuit
    }
    
    public var body: some View {
        Button(role: .destructive) {
            action()
        } label : {
            Label{
                Text("Close Window\(shouldQuit ? " and Quit." : ".")")
            } icon: {
                Image(systemName: "xmark")
            }
        }
        .tint(.red)
        #if os(macOS)
        .windowReference{ window in
            action = {
                window.close()
            }
        }
        #endif
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
