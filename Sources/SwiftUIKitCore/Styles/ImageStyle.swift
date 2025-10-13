import SwiftUI


public protocol ImageStyle {
    
    associatedtype Body: View
    
    func style(image: Image) -> Body
    
}

public extension ImageStyle {
    
    func callAsFunction(_ image: Image) -> Body {
        style(image: image)
    }
    
}


// MARK: - None Implementation


public struct NoImageStyle: ImageStyle {
    
    public func style(image: Image) -> Image {
        image
    }
    
}

public extension ImageStyle where Self == NoImageStyle {
    
    static var none: NoImageStyle { Self() }
    
}


// MARK: - Type Eraser


public struct AnyImageStyle: ImageStyle {
    
    let base: any ImageStyle
    
    public init(_ base: some ImageStyle) {
        self.base = base
    }
    
    public func style(image: Image) -> some View {
        AnyView(base(image))
    }
    
}


// MARK: - View Environment


extension EnvironmentValues {
    
    @Entry var imageStyle = AnyImageStyle(.none)
    
}

public extension View {
    
    func imageStyle(_ style: some ImageStyle) -> some View {
        environment(\.imageStyle, AnyImageStyle(style))
    }
    
    func imageStyle(_ style: AnyImageStyle) -> some View {
        environment(\.imageStyle, style)
    }
    
}

public extension Image {
    
    func environmentStyled() -> some View {
        InlineEnvironmentValue(\.imageStyle){ style in
            style(self)
        }
    }
    
    func style<Style: ImageStyle>(_ style: Style) -> Style.Body {
        style(self)
    }
    
}
