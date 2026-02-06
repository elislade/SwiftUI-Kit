import SwiftUI


public struct WindowButtonZoom: View {

    @State private var action: () -> Void = { }
    @State private var fullscreen = true
    
    public init(){}
    
    public var body: some View {
        Button{
            action()
        } label: {
            Label{
                Text("Maximize Window")
            } icon: {
                Image(systemName: "plus")
            }
        }
        .tint(.green)
        #if os(macOS)
        .windowReference{ window in
            action = {
                window.collectionBehavior.insert(.fullScreenPrimary)
                window.toggleFullScreen(nil)
            }
        }
        #endif
    }
    
}


#Preview {
    HStack {
        WindowButtonZoom()
            .buttonStyle(.windowMain)
        
        WindowButtonZoom()
            .buttonStyle(.windowPanel)
    }
    .padding()
}
