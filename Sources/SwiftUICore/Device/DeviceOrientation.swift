import SwiftUI


struct DeviceOrientationKey: EnvironmentKey {
    static var defaultValue: DeviceOrientation = .unknown
}


public extension EnvironmentValues {
    
    var deviceOrientation: DeviceOrientation {
        get { self[DeviceOrientationKey.self] }
        set { self[DeviceOrientationKey.self] = newValue }
    }
    
}


public enum DeviceOrientation : Int, Sendable, Equatable {
    case unknown = 0

    case portrait = 1
    case portraitUpsideDown = 2

    case landscapeLeft = 3
    case landscapeRight = 4

    case faceUp = 5
    case faceDown = 6
    
    public var isPortrait: Bool {
        switch self {
        case .portrait, .portraitUpsideDown: return true
        default: return false
        }
    }
    
    public var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight: return true
        default: return false
        }
    }
    
    public var isFlat: Bool {
        switch self {
        case .faceUp, .faceDown: return true
        default: return false
        }
    }
    
    public var inverse: DeviceOrientation {
        switch self {
        case .unknown: .unknown
        case .portrait: .portraitUpsideDown
        case .portraitUpsideDown: .portrait
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        case .faceUp: .faceDown
        case .faceDown: .faceUp
        }
    }
    
    public static func landscapeLeading(for layout: LayoutDirection) -> DeviceOrientation {
        switch layout {
        case .leftToRight: .landscapeLeft
        case .rightToLeft: .landscapeRight
        @unknown default: .landscapeLeft
        }
    }
    
    public static func landscapeTrailing(for layout: LayoutDirection) -> DeviceOrientation {
        switch layout {
        case .leftToRight: .landscapeRight
        case .rightToLeft: .landscapeLeft
        @unknown default: .landscapeRight
        }
    }
    
}


#if os(iOS)

struct DeviceOrientationModifier: ViewModifier {
    
    static let notification = UIDevice.orientationDidChangeNotification
    
    @State private var orientation: DeviceOrientation = .unknown
    
    private func update(_ orientation: UIDeviceOrientation) {
        guard
            orientation != .unknown,
            let orientation = DeviceOrientation(rawValue: orientation.rawValue),
            !orientation.isFlat
        else { return }
        
        self.orientation = orientation
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.deviceOrientation, orientation)
            .onReceive(NotificationCenter.default.publisher(for: DeviceOrientationModifier.notification)){ change in
                guard let device = change.object as? UIDevice else { return }
                update(device.orientation)
            }
            .onAppear{
                update(UIDevice.current.orientation)
            }
    }
    
}

#endif
