import SwiftUI

struct FontDescriptor {
    
    static func testFont() {
        #if canImport(UIKit)
        let d1 = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let fd = d1.withDesign(.serif)!
        let f = UIFont(descriptor: fd, size: 50)
        print("UIAppleFam".capitalized, f.familyName)
        print("UIAppleFont", f.fontName)
        //print("UIAppleDisplay", f.displayName)
        print("UIApple -----------")
        
        //        if #available(iOS 17.0, *) {
        //            let traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
        //
        //            let all: [UIFont.TextStyle] = [
        //                .caption2, .caption1, .footnote,  .callout, .body, .subheadline, .headline,
        //                .title3, .title2, .title1, .largeTitle, .extraLargeTitle2, .extraLargeTitle
        //            ]
        //            for style in all {
        //                let f = UIFont.preferredFont(forTextStyle: style)
        //                let f2 = UIFont.preferredFont(forTextStyle: style, compatibleWith: traits)
        //                print("\(style)", f.pointSize, f2.pointSize, f2.pointSize / f.pointSize)
        //            }
        //
        //            //kCTFontStyleNameKey
        //            print("----")
        //        }
        
        #elseif canImport(AppKit)
        
        let d1 = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
        
        let d = d1.withDesign(.serif)
        let f = NSFont(descriptor: d!, size: 50)!
        print("NSAppleFam", f.familyName)
        print("NSAppleFont", f.fontName)
        print("NSAppleDisplay", f.displayName)
        print("NSApple -----------")
        
        #endif
    }
    
}
