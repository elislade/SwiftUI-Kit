import SwiftUI


public protocol TextStyle {
    
    associatedtype Body: View
    
    func style(text: Text) -> Body
    
}

public extension TextStyle {
    
    func callAsFunction(_ text: Text) -> Body {
        style(text: text)
    }
    
}


// MARK: - None Implementation


public struct NoTextStyle: TextStyle {
    
    public func style(text: Text) -> Text {
        text
    }
    
}

public extension TextStyle where Self == NoTextStyle {
    
    static var none: NoTextStyle { Self() }
    
}


// MARK: - Type Eraser


public struct AnyTextStyle: TextStyle {
    
    let base: any TextStyle
    
    public init(_ base: some TextStyle) {
        self.base = base
    }
    
    public func style(text: Text) -> some View {
        AnyView(base(text))
    }
    
}


// MARK: - View Environment


extension EnvironmentValues {
    
    @Entry var textStyle = AnyTextStyle(.none)
    
}

public extension View {
    
    func textStyle(_ style: some TextStyle) -> some View {
        environment(\.textStyle, AnyTextStyle(style))
    }
    
    func textStyle(_ style: AnyTextStyle) -> some View {
        environment(\.textStyle, style)
    }
    
}

public extension Text {
    
    func environmentStyled() -> some View {
        InlineEnvironmentValue(\.textStyle){ style in
            style(self)
        }
    }
    
    func style<Style: TextStyle>(_ style: Style) -> Style.Body {
        style(self)
    }
    
}
