import SwiftUIKit


public struct IndirectScrollExample: View {
    
    public init() {}
    
    public var body: some View {
        InlineBinding(CGPoint.zero){ value in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.gray)
                    .offset(x: value.wrappedValue.x, y: value.wrappedValue.y)
                    .padding()
                
                Button("Test"){}
            }
            .indirectGesture(
                IndirectScrollGesture(useMomentum: false)
                    .onChanged { g in
                        value.x.wrappedValue += g.deltaX
                        value.y.wrappedValue += g.deltaY
                    }
                    .onEnded { g in
                        withAnimation(.snappy){
                            value.wrappedValue = .zero
                        }
                    }
            )
        }
    }
    
}


#Preview {
    IndirectScrollExample()
}
