import SwiftUI

struct ExampleCard<C: View>: View {
    
    let title: String
    @ViewBuilder let content: C
    
    var body: some View {
        VStack(spacing: 20){
            Text(title)
                .font(.title3[.semibold])
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            content
        }
        .padding(18)
        .background{
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder()
                .opacity(0.3)
        }
    }
}

#Preview {
    ExampleCard(title: "Example Card"){
        Button("Content"){}
    }
    .padding()
}
