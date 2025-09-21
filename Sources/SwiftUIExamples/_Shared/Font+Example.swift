import SwiftUIKit


extension Font {
    
    static var exampleTitle: Font {
        .system(.largeTitle, design: .serif)[.italic][.bold]
    }
    
    static var exampleSectionTitle: Font {
        .title2[.bold][.expanded]
    }

    static var exampleParameterTitle: Font {
        .title3[.semibold]
    }
    
    static var exampleParameterValue: Font {
        .body[.monospacedDigit]
    }
    
}
