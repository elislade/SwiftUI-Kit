import SwiftUI

public struct WindowCloseButton: View {
    
    @Environment(\.performWindowAction) private var performWindowAction
   
    public init(){}
    
    public var body: some View {
        Button(action: { performWindowAction(.close) }){
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 6, height: 6)
                .font(.caption.weight(.heavy))
                .padding(5)
                .opacity(0.5)
                .background(Circle().opacity(0.1))
        }
        .buttonStyle(.plain)
        .padding(10)
    }
    
}

#Preview {
    WindowCloseButton().padding()
}
