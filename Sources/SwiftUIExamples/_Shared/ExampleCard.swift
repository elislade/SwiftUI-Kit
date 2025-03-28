import SwiftUI

struct ExampleCard<C: View>: View {
    
    let title: String
    @ViewBuilder let content: C
    
    var body: some View {
        VStack(spacing: nil){
            Text(title)
                .font(.title3[.semibold])
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            content
        }
        .padding()
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
