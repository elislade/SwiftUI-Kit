import SwiftUI


/// Layout views evenly in a circle with provided data
public struct CircularLayoutView<Data, ID, Content: View>: View where ID == Data.Element.ID, Data : RandomAccessCollection, Data.Element : Identifiable, Data.Index: BinaryInteger {
    
    let data: Data
    let compensateForRotation: Bool
    let content: (Data.Element) -> Content
    
    
    /// - Parameters:
    ///   - data: A `RandomAccessCollection` of data where each `Element` conforms to `Idetifiable`.
    ///   - compensateForRotation: If true, elements will be rotated by an equal and opposite roation to always be pointing their origonal rotation. Defaults to false.
    ///   - content: A view builder  that  produces a view for each element of data.
    public init(
        data: Data,
        compensateForRotation: Bool = false,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ){
        self.data = data
        self.compensateForRotation = compensateForRotation
        self.content = content
    }
    
    private var degStep: Double { 360 / Double(data.count) }
    
    private func index(_ ele: Data.Element) -> Data.Index {
        data.firstIndex(where: { $0.id == ele.id })!
    }
    
    private func view(_ ele: Data.Element, _ proxy: GeometryProxy) -> some View {
        Color.clear
            .frame(width: 1, height: min(proxy.size.height, proxy.size.width))
            .overlay(alignment: .bottom){
                content(ele)
                    .rotationEffect(compensateForRotation ? Angle(degrees: -degStep * Double(index(ele))): .zero)
            }
            .rotationEffect(Angle(degrees: degStep * Double(index(ele))))
    }
    
    public var body: some View {
        GeometryReader{ p in
            ZStack {
                Color.clear
                ForEach(data){ view($0, p).transition(.scale) }
            }
        }
        .animation(.bouncy, value: data.count)
    }
}


extension Color: Identifiable {
    public var id: Int { hashValue }
}

extension Int: Identifiable {
    public var id: Int { self }
}
