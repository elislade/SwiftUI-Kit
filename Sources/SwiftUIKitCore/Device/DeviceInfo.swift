import Darwin.POSIX

///
/// - Warning: Simulators do not report values correctly. Testing and usage needs to happen on physical devices.
final public class Device {
    
    @MainActor public static let current: Device = .init()
    
    private init() { }
    
    public private(set) lazy var modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }()
    
    
    /// A device may have asymmetric radius values. EG. MacBook Pro's have top radius but no bottom radius on bezel.
    public private(set) lazy var bezelRadius: RadiusValues = {
        switch modelName {
        case "iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone12,3", "iPhone12,5":
            // iPhone X, XS, iPhone 11 Pro, iPhone 11 Pro Max
            return 40
        case "iPhone11,8", "iPhone12,1":
            // iPhone XR, iPhone 11
            return 42
        case "iPhone13,1", "iPhone14,4":
            // iPhone 12 Mini, iPhone 13 Mini
            return 45
        case "iPhone13,2", "iPhone13,3", "iPhone13,4", "iPhone14,7", "iPhone14,8":
            //iPhone 12, 12 Pro, 12 Pro Max
            return 48
        case "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,1", "iPhone17,2","iPhone17,3", "iPhone17,4":
            // 14 Pro, 14 Pro Max
            // 15, 15 Plus, 15 Pro, 15 Pro Max
            // 16, 16 Plus, 16 Pro, 16 Pro Max
            return 55
        case "iPad14,1", "iPad14,2":
            // iPad Mini 6th Gen
            return 22
        case "iPad8,11", "iPad8,12", "iPad13,1", "iPad13,2", "iPad14,3", "iPad14,4", "iPad13,16", "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", "iPad14,5", "iPad14,6", "iPad16,3", "iPad16,4", "iPad16,5", "iPad16,6":
            // iPad Pro 11 4th gen, iPad Air 5... all same to current gen
            return 18.5
        default: return .zero
        }
    }()
    
}
