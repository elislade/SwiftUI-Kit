import SwiftUI


public struct AnchorHelper {
    
    public static func presentationEdge(for presentationAnchor: UnitPoint, and sourceAnchor: UnitPoint) -> Edge? {
        
        if presentationAnchor.x == 0 && sourceAnchor.x == 1 {
            return .leading
        } else if presentationAnchor.x == 1 && sourceAnchor.x == 0 {
            return .trailing
        }
        
        if presentationAnchor.y == 0 && sourceAnchor.y == 1 {
            return .top
        } else if presentationAnchor.y == 1 && sourceAnchor.y == 0 {
            return .bottom
        }
        
        return nil
    }
    
    
    // MARK: - Source
    
    
    public static func sourceAnchor(for rect: CGRect, in size: CGSize) -> UnitPoint {
        UnitPoint(
            x: sourceAnchorX(for: rect, in: size),
            y: sourceAnchorY(for: rect, in: size)
        )
    }
    
    public static func sourceAnchorAxis(_ axis: Axis, for rect: CGRect, in size: CGSize) -> Double {
        switch axis {
        case .horizontal: sourceAnchorX(for: rect, in: size)
        case .vertical: sourceAnchorY(for: rect, in: size)
        }
    }
    
    public static func sourceAnchorX(for rect: CGRect, in size: CGSize) -> Double {
        let midX = size.width / 2
        let h: Double = rect.midX > midX ? 1 : rect.midX < midX ? 0 : 0.5
        
        if size.height < size.width {
            return 1 - h
        } else {
            return h
        }
    }
    
    public static func sourceAnchorY(for rect: CGRect, in size: CGSize) -> Double {
        let v: Double = rect.midY > size.height / 2 ? 0 : 1
        
        if size.height < size.width {
            return 1 - v
        } else {
            return v
        }
    }
    
    
    // MARK: - Presentation
    
    
    public static func presentationAnchor(for rect: CGRect, in size: CGSize) -> UnitPoint {
        UnitPoint(
            x: presentationAnchorX(for: rect, in: size),
            y: presentationAnchorY(for: rect, in: size)
        )
    }
    
    public static func presentationAnchorAxis(_ axis: Axis, for rect: CGRect, in size: CGSize) -> Double {
        switch axis {
        case .horizontal: presentationAnchorX(for: rect, in: size)
        case .vertical: presentationAnchorY(for: rect, in: size)
        }
    }
    
    public static func presentationAnchorX(for rect: CGRect, in size: CGSize) -> Double {
        let midX = size.width / 2
        return rect.midX > midX ? 1 : rect.midX < midX ? 0 : 0.5
    }
    
    public static func presentationAnchorY(for rect: CGRect, in size: CGSize) -> Double {
        return rect.midY > size.height / 2 ? 1 : 0
    }
    
}
