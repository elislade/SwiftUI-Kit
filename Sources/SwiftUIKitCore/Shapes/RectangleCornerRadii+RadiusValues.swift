import SwiftUI

public extension RectangleCornerRadii {
    init(_ values: RadiusValues, rightToLeft: Bool = false){
        self.init(
            topLeading: rightToLeft ? values.topRight : values.topLeft,
            bottomLeading: rightToLeft ? values.bottomRight : values.bottomLeft,
            bottomTrailing: rightToLeft ? values.bottomLeft : values.bottomRight,
            topTrailing: rightToLeft ? values.topLeft : values.topRight
        )
    }
}


public extension RadiusValues {
    init(_ values: RectangleCornerRadii, rightToLeft: Bool = false){
        self.init(
            topLeft: rightToLeft ? values.topTrailing : values.topLeading,
            topRight: rightToLeft ? values.topLeading: values.topTrailing,
            bottomRight: rightToLeft ? values.bottomLeading: values.bottomTrailing,
            bottomLeft: rightToLeft ? values.bottomTrailing : values.bottomLeading
        )
    }
}
