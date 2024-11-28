import SwiftUI

public struct WindowButtonEmpty: View {
    
    public init(){}
    
    public var body: some View {
        Button(action: {}){
            Color.clear
        }
        .tint(.clear)
        .disabled(true)
    }
    
}


#Preview {
    HStack {
        WindowButtonEmpty()
            .padding()
            .buttonStyle(.windowMain)
        
        WindowButtonEmpty()
            .padding()
            .buttonStyle(.windowPanel)
    }
}
