import SwiftUIKit


public struct ScrollPassthroughExample: View {
    
    public init(){}
    
    public var body: some View {
        ExampleView("Scroll Passthrough"){
            GeometryReader { proxy in
                ReadableScrollView(.vertical){
                    VStack(spacing: 0) {
                        Header()
                        VStack(spacing: 20) {
                            ForEach(0..<10){ _ in
                                RoundedRectangle(cornerRadius: 26)
                                    .aspectRatio(1.8, contentMode: .fit)
                                    .opacity(0.1)
                            }
                        }
                        .padding(20)
                    }
                    .background{
                        LinearGradient(
                            colors: [
                                .red, .orange, .yellow, .green, .blue, .purple
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .overscrollPinned(axis: .vertical)
                        .ignoresSafeArea()
                    }
                    .safeAreaInsets(proxy.safeAreaInsets)
                }
                .ignoresSafeArea()
            }
            .scrollPassthroughContext()
            .safeAreaInset(edge: .top, spacing: 0){
                Text("Additional Stuff")
                    .padding()
                    .background(.regularMaterial, in: .capsule)
            }
        }
    }
    
    
    struct Header: View {
        
        @Environment(\.scrollOffsetPassthrough) private var offset
        @State private var maxHeight: CGFloat = 0
        @State private var internalOffset: Double = 0
        
        private let range: ClosedRange<CGFloat> = 50...300
        
        var body: some View {
            GeometryReader { proxy in
                VStack(spacing: 12) {
                    RaisedControlMaterial(Circle())
                        .blendMode(.hardLight)
                        .frame(minHeight: 40, maxHeight: 120)
                    
                    Text("Scroll Passthough")
                }
                .lineLimit(1)
                .font(.largeTitle.weight(.bold))
                .minimumScaleFactor(0.05)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .padding(.top, proxy.safeAreaInsets.top)
                .background{
                    if let offset {
                        Rectangle()
                            .fill(.regularMaterial)
                            .overlay(alignment: .bottom){ Divider() }
                            .opacity(1 - maxHeight.fraction(in: range))
                            .onReceive(offset.map(\.y)){ y in
                                internalOffset = y * -1
                                maxHeight = max(range.upperBound + y, range.lowerBound)
                            }
                    }
                }
                .offset(y: internalOffset)
                .ignoresSafeArea()
            }
            .frame(height: maxHeight)
            .zIndex(10)
        }
    }
    
}


#Preview {
    ScrollPassthroughExample()
        .previewSize()
}
