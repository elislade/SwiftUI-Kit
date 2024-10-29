import Foundation
import CoreText
import SwiftUI


public protocol FontResolver {
    
    func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont
    
}
