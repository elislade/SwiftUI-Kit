import SwiftUI

// Routing is an asynchronous route handling system built upon SwiftUI/URL routing.
// It can be used to elegantly route to views even if they are not in a known hierarchy.

public extension View {
    
    /// The root from which routing will be handled.
    /// - Parameters:
    ///   - scheme: The URL scheme to match for links. Defaults to "https".
    ///   - port: The URL port to match for links. Defaults to nil. Nil port passes all matches.
    ///   - host: The URL host to match for links. Defaults to "*". "*" matches any host.
    ///   - shouldDeferUnhandled: Bool defining if links that arn't currently matched deffered to try again later. Defaults to false.
    /// - Returns: A modified router view.
    /// - Note: If shouldDefer is true the last unmatched link that passes router qualifications, will be stored until shouldDefer becomes false again; at which point it will be evaluated. This can be used to handle links that open the app with blocked access like onboarding. Eg. If onboarding is visible set deffered to true, once onboarding finishes set to false and the link will continue.
    nonisolated func router(
        _ scheme: String = "https",
        port: Int? = nil,
        host: String = "*",
        shouldDeferUnhandled: Bool = false
    ) -> some View {
        modifier(RoutingModifier(
            scheme: scheme,
            port: port,
            host: host,
            shouldDefer: shouldDeferUnhandled
        ))
    }
    
    nonisolated func routesDisabled(_ disabled: Bool = true) -> some View {
        resetPreference(RoutePreferenceKey.self, reset: disabled)
    }
    
    
    /// Defines a route namespace for child views.
    /// - NOTE: Use a `routeNamespace` as a parent indicator when the `onRoute` is not a parent, but a sibling or cousin of the content being routed to.
    /// An example of this pattern is when exposing `TabView` content through its `TabBarItem` where the item is not a view parent of its content.
    /// - Parameter component: The Path component of this view.
    /// - Returns: A modified view that handles routing.
    nonisolated func routeNamespace(_ component: String) -> some View {
        modifier(RoutingPathModifier(
            path: component,
            action: { },
            other: nil
        ))
    }
    
    
    /// Defines a route component to match relative to parent components or namespaces containing it. Any routes inside are treated as child routes to this one.
    /// - NOTE: Use this over `onRoute` when you care about the view state staying in sync with the route state; otherwise the router may miss routes that it thinks are deactivated but were actived by user action not by previous route. This should be preferred over onRoute as route state should always be in sync with actual view state.
    /// - NOTE: `prepare` will not be followed by an `isActive` set to true when it is unable to find a suitable leaf node to handle the link after calling the function. Use `prepare` to expose views that can be crawled for matches on next pass. If you prefer override control just set the binding to true even if you know an exact match may not be found. Prepare will not be called if a match is already found in the graph.
    /// - Parameters:
    ///   - component: The path component to match against.
    ///   - isActive: A binding to whether this route is active or not.
    ///   - prepare: An asynchronous closure that will run before possibly activating from a route. Defaults to nil.
    /// - Returns: A modified routing view.
    nonisolated func routeBinding(
        _ component: String,
        isActive: Binding<Bool>,
        prepare: (() async -> Void)? = nil
    ) -> some View {
        modifier(RoutingPathModifier(
            path: component,
            isActive: isActive,
            action: prepare,
            other: {}
        ))
    }
    
    
    /// Defines a route component to match relative to parent components or namespaces containing it. Any routes inside are treated as child routes to this one.
    /// - Parameters:
    ///   - component: The path component to match.
    ///   - action: The action to perform when a route with this path as its leaf is called.
    ///   - other: Optional action to perform when another route is called that is not this one. Defaults to nil.
    /// - Returns: A modified view that handles routing.
    nonisolated func onRoute(_ component: String, perform action: @escaping () async -> Void, other: (() -> Void)? = nil) -> some View {
        modifier(RoutingPathModifier(
            path: component,
            action: action,
            other: other
        ))
    }
    
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    nonisolated func onRouteRegex<R: RegexComponent>(_ component: R, perform action: @escaping (R.RegexOutput) async -> Void, other: (() -> Void)? = nil) -> some View where R.RegexOutput: Sendable, R.RegexOutput : Equatable {
        modifier(RoutingRegexModifier(
            regex: component,
            action: action,
            other: other
        ))
    }
    
    
    /// If a link has the matched query key you gets its value as a string in the action.
    /// - Parameters:
    ///   - key: The key that is to be matched
    ///   - action: A closure that recieves the vcale of the key.
    /// - Returns: A modified view.
    nonisolated func onRouteQuery(_ key: String, perform action: @escaping (String) async -> Void) -> some View {
        modifier(RoutingQueryModifier(
            keys: [key],
            action: { args in
                if let first = args.first {
                    await action(first)
                }
            }
        ))
    }
    
    nonisolated func onRouteQuery(_ keys: String..., perform action: @escaping ([String]) async -> Void) -> some View {
        modifier(RoutingQueryModifier(keys: keys, action: action))
    }
    
    
    /// Delays any subroute walking for every component.
    /// - Parameter delay: Delay in seconds.
    /// - Returns: A modified view.
    func routeDelay(_ delay: Double) -> some View {
        environment(\.routeDelay, delay)
    }
    
    
    /// Catches routes from any downstream relayers and exposes them.
    ///
    ///     struct Example: View {
    ///
    ///         @State private var showContent = false
    ///
    ///         var body: some View {
    ///             Rectangle().sheet(isPresented: $showContent){
    ///                 InnerContent()
    ///                     .routeRelay()
    ///             }
    ///             .routeRelayReceiver()
    ///         }
    ///     }
    ///
    /// - Note: Use just outside of severed environments/view hirarchies. Can be used in conjunction with SwiftUI native presentation adapters on iOS 17 and above.
    /// - Returns: A modified relay reciever view.
    nonisolated func routeRelayReceiver() -> some View {
        preferenceRelayReceiver(RoutePreferenceKey.self)
    }
    
    
    /// Relays routes to the first parent receiver.
    ///
    ///     struct Example: View {
    ///
    ///         @State private var showContent = false
    ///
    ///         var body: some View {
    ///             Rectangle().sheet(isPresented: $showContent){
    ///                 InnerContent()
    ///                     .routeRelay()
    ///             }
    ///             .routeRelayReceiver()
    ///         }
    ///     }
    ///
    /// - Note: Use inside on the view that is being severed. Can be used in conjunction with SwiftUI native presentation adapters on iOS 17 and above.
    /// - Returns: A modified relay view.
    func routeRelay() -> some View {
        preferenceRelay(RoutePreferenceKey.self)
    }
    
}


extension EnvironmentValues {
    
    // TODO: Change to `Duration` when dropping iOS 15 generation support.
    @Entry var routeDelay: Double = 0.3
    
}

