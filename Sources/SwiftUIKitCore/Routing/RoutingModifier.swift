import SwiftUI


struct RoutingModifier {
    
    let scheme: String
    let port: Int?
    let host: String
    let shouldDefer: Bool
    
    @State private var deferredURL: URL?
    @State private var children: [RoutePreference] = []
    
    private func valid(url: URL) -> Bool {
        (scheme == "*" || url.scheme == scheme) &&
        (host == "*" || url.host == host) &&
        (port != nil ? port == url.port : true)
    }
    
    @discardableResult private func handle(_ comps: [LinkComponent]) async -> Bool {
        var handled: [UUID: Bool] = [:]
        var next: RoutePreference? = children.filter({ !handled.keys.contains($0.id) }).first
        
        while let nextV = next {
            handled[nextV.id] = await nextV.handle(comps)
            next = children.filter({ !handled.keys.contains($0.id) }).first
        }
       
        return handled.values.contains(true)
    }
    
    @discardableResult private func handle(url: URL) async -> Bool {
        guard
            valid(url: url),
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return false
        }
        
        var components: [LinkComponent] = comps.path.components(separatedBy: "/")
            .filter({ !$0.isEmpty })
            .map{ .path($0) }
        
        if let items = comps.queryItems {
            components.append(.params(items.dictionary))
        }
   
        let handled = await handle(components)

        if !handled {
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
            return await handle(components)
        }
        
        return true
    }
    
}

extension RoutingModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(RoutePreferenceKey.self){
                children = $0
            }
            .preferenceKeyReset(RoutePreferenceKey.self)
            .onOpenURL{ url in
                Task {
                    if await !handle(url: url) && shouldDefer && valid(url: url) {
                        deferredURL = url
                    }
                }
            }
            .environment(\.openURL, OpenURLAction{ url in
                if valid(url: url) {
                    Task {
                        if await !handle(url: url) && shouldDefer {
                            deferredURL = url
                        }
                    }
                    return .handled
                } else {
                    return .systemAction
                }
            })
            .onChangePolyfill(of: shouldDefer){
                if !shouldDefer, let deferredURL {
                    Task {
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
                        await handle(url: deferredURL)
                        self.deferredURL = nil
                    }
                }
            }
    }
    
}

extension Collection where Element == URLQueryItem {
    
    var dictionary: [String: String] {
        reduce(into: [String: String]()){ res, partial in
            res[partial.name] = partial.value
        }
    }
    
}

enum UnhandledRouteBehaviour {
    case ignore
    case `defer`
    case retryAfterDelay(count: Int = 3)
}

enum LinkComponent: Equatable, Sendable {
    
    static func == (lhs: LinkComponent, rhs: LinkComponent) -> Bool {
        if let lp = lhs.params, let rp = rhs.params {
            return lp == rp
        } else if let lp = lhs.path, let rp = rhs.path {
            return lp == rp
        }
        return false
    }
    
    case path(String)
    case params([String: String])
    
    var path: String? {
        if case .path(let string) = self {
            return string
        }
        return nil
    }
    
    var params: [String: String]? {
        if case .params(let params) = self {
            return params
        }
        return nil
    }

}


struct RouteDestination {
    let paths: [String]
    let queryItems: [String: String]?
    
    func next() -> Self? {
        guard !paths.isEmpty else { return nil }
        return RouteDestination(paths: Array(paths.dropFirst()), queryItems: queryItems)
    }
}
