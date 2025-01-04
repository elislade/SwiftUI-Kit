import SwiftUI
import SwiftUIKitCore


/// Layout views evenly in a circle with provided data
public struct CircularLayoutView<Data, ID, Content: View>: View where ID == Data.Element.ID, Data : RandomAccessCollection, Data.Element : Identifiable, Data.Index == Int {
    
    let data: Data
    let radius: Double
    let compensateForRotation: Bool
    let content: (Data.Element) -> Content
    
    
    /// - Parameters:
    ///   - data: A `RandomAccessCollection` of data where each `Element` conforms to `Idetifiable`.
    ///   - compensateForRotation: If true, elements will be rotated by an equal and opposite roation to always be pointing their origonal rotation. Defaults to false.
    ///   - content: A view builder  that  produces a view for each element of data.
    public init(
        data: Data,
        radius: Double = 100,
        compensateForRotation: Bool = false,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ){
        self.data = data
        self.radius = radius
        self.compensateForRotation = compensateForRotation
        self.content = content
    }

    public var body: some View {
        ZStackCollectionLayout(
            CircularCollectionLayout(
                radius: radius,
                compensateForRotation: compensateForRotation
            ),
            data: data
        ) { item in
            content(item)
        }
    }
}


extension Color: @retroactive Identifiable {
    public var id: Int { hashValue }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}


public struct CircularCollectionLayout : RelativeCollectionLayoutModifier {
    
    let radius: Double
    let compensateForRotation: Bool
    let range: ClosedRange<Angle>
    let offset: Angle
    
    public init(
        radius: Double,
        offset: Angle = .zero,
        range: ClosedRange<Angle> = Angle.zero...Angle(degrees: 360),
        compensateForRotation: Bool = false
    ) {
        self.radius = radius
        self.offset = offset
        self.range = range
        self.compensateForRotation = compensateForRotation
    }
    
    public func layoutItem(_ content: Content, index: Int, count: Int) -> some View {
        let degrees = ((range.upperBound.degrees / Double(count)) * Double(index)) + offset.degrees
        content
            .rotationEffect(.degrees(degrees))
            .offset(x: radius)
            .rotationEffect(.degrees(-degrees))
            .offset(x: -radius)
            .rotationEffect(.degrees(compensateForRotation ? 0 : degrees))
            .offset(x: compensateForRotation ? radius : -radius)
    }
    
}
