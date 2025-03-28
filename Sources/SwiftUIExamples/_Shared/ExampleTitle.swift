import SwiftUI

struct ExampleTitle: View {
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        #if os(watchOS)
        Text(title)
            .font(.exampleTitle)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
        #else
        HStack(alignment: .lastTextBaseline, spacing: nil) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint)
                .frame(width: 16, height: 10)
                .overlay{
                    LinearGradient(
                        colors: [.white.opacity(0.2), .black.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                }
                .shearHorizontal(.degrees(-20))
            
            Text(title)
                .font(.exampleTitle)
                .offset(x: -4, y: 4)
                .layoutPriority(2)
                .multilineTextAlignment(.leading)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint)
                .frame(height: 10)
                .overlay{
                    LinearGradient(
                        colors: [.white.opacity(0.2), .black.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.overlay)
                }
                .shearHorizontal(.degrees(-20))
        }
        
        #endif
    }
    
}

#Preview {
    VStack(spacing: 32) {
        ExampleTitle("An Overcompensating Title That Keeps Going & Going.")
            .tint(.pink)
        
        ExampleTitle("An Adequate Title")
            .tint(.yellow)
    }
    .padding()
}
