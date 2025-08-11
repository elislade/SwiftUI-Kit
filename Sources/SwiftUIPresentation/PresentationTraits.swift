import SwiftUI


public struct PresentationTraits: OptionSet, Sendable {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let fullscreen = PresentationTraits(rawValue: 1 << 0)
    
    public static let pinnedTop = PresentationTraits(rawValue: 1 << 1)
    public static let pinnedBottom = PresentationTraits(rawValue: 1 << 2)
    public static let pinnedLeading = PresentationTraits(rawValue: 1 << 3)
    public static let pinnedTrailing = PresentationTraits(rawValue: 1 << 4)
    
    public static let pinned: Self = [pinnedTop, pinnedBottom, pinnedLeading, .pinnedTrailing]
    
    public static func pinned(_ edges: Edge.Set) -> Self {
        var pins: Self = []
        
        if edges.contains(.leading) { pins.insert(.pinnedLeading) }
        if edges.contains(.trailing) { pins.insert(.pinnedTrailing) }
        
        if edges.contains(.top) { pins.insert(.pinnedTop) }
        if edges.contains(.bottom) { pins.insert(.pinnedBottom) }
        
        return pins
    }
    
}

struct BeingPresentedKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}

struct PresentationTraitsEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: PresentationTraits { .init() }
    
}

struct PresentedOnTraitsEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: PresentationTraits { .init() }
    
}

public extension EnvironmentValues {
    
    var _isBeingPresented: Bool {
        get { self[BeingPresentedKey.self] }
        set { self[BeingPresentedKey.self] = newValue }
    }
    
}


public extension EnvironmentValues {
    
    /// Empty traits indicates no traits but does not indicate whether it's being presented on or not.
    /// To detect presentation use the `isBeingPresentedOn` which will be `true` for views that have another view being presented on it.
    var presentedOnWithTraits: PresentationTraits {
        get { self[PresentedOnTraitsEnvironmentKey.self] }
        set { self[PresentedOnTraitsEnvironmentKey.self] = newValue }
    }
    
    
    /// Empty traits indicates no traits but does not indicate whether it's presented or not.
    /// To detect presentation use the ``isBeingPresented`` which will be true for presented views
    var presentationTraits: PresentationTraits {
        get { self[PresentationTraitsEnvironmentKey.self] }
        set { self[PresentationTraitsEnvironmentKey.self] = newValue }
    }
    
    /// `True` when the view is being presented by native presentation bridging **or** by custom defined `SwiftUIKit` presentations.
    var isBeingPresented: Bool {
        isPresented || _isBeingPresented
    }
    
}


struct PresentationTraitsPreferenceKey: PreferenceKey {
    
    static var defaultValue: PresentationTraits { .init() }
    
    static func reduce(value: inout PresentationTraits, nextValue: () -> PresentationTraits) {
        value.formUnion(nextValue())
    }
    
}


public extension View {
    
    nonisolated func addPresentationTraits(_ traits: PresentationTraits) -> some View {
        transformEnvironment(\.presentationTraits){
            $0.formUnion(traits)
        }
    }
    
    func preferredPresentationTraits(_ traits: PresentationTraits) -> some View {
        preference(key: PresentationTraitsPreferenceKey.self, value: traits)
    }
    
    func childPrefersPresentationTraits(_ perform: @escaping (PresentationTraits) -> Void) -> some View {
        onPreferenceChange(PresentationTraitsPreferenceKey.self, perform: perform)
    }
    
}
