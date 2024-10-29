import SwiftUI

struct ExampleTitle: View {
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: nil) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint)
                .frame(width: 16, height: 10)
                .transformEffect(.init(1, 0, -0.3, 1, 0, 0))
            
            Text(title)
                .font(.exampleTitle)
                .offset(x: -4, y: 4)
                .layoutPriority(2)
                .multilineTextAlignment(.leading)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint)
                .frame(height: 10)
                .transformEffect(.init(1, 0, -0.3, 1, 0, 0))
        }
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
