import SwiftUI

struct ExampleControlGroup<Content: View> : View {
    
    @ViewBuilder let content: Content
    
    var body: some View {
        ViewThatFits(in: .horizontal){
            HStack{
                content
            }
            #if !os(watchOS)
            .frame(minWidth: 320, maxWidth: 440)
            #endif
            
            VStack{
                content
            }
        }
    }
    
}

#Preview {
    ExampleControlGroup{
        Text("A")
        Text("B")
    }
}
