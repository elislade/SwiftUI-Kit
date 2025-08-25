import SwiftUI


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Font.Width {
    
    public func closest(in options: [Font.Width]) -> Font.Width {
        let distanceToValues: [(distance: Double, index: Int)] = options.indices.map{ i in
            (value - options[i].value, i)
        }
        
        let smallestToLargestDistances = distanceToValues.sorted(by: {
            pow($0.distance, 2) < pow($1.distance, 2)
        })
        
        let closestIndex = smallestToLargestDistances.first!.index
        return options[closestIndex]
    }
    
}

