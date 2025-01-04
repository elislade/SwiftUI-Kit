import SwiftUIKit


extension Font {
    
    static var exampleTitle: Font {
        .system(.largeTitle, design: .serif)[.italic][.bold]
    }
    
    static var exampleSectionTitle: Font {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            .title2[.bold][.expanded]
        } else {
            .title[.bold]
        }
    }

    static var exampleParameterTitle: Font {
        .title3[.semibold]
    }
    
    static var exampleParameterValue: Font {
        .body[.monospacedDigit]
    }
    
}
