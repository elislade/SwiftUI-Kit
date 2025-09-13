import SwiftUI
import RegexBuilder


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct RoutingRegexModifier<R:RegexComponent> where R.RegexOutput: Sendable, R.RegexOutput: Equatable {
    
    @Environment(\.routeDelay) private var delay
    
    @State private var id = UUID()
    @State private var previousMatch: R.RegexOutput?
    @State private var children: [RoutePreference] = []
    
    let regex: R
    let action: (R.RegexOutput) async -> Void
    var other: (() -> Void)? = nil
    
    private var childIsActive: Bool {
        for child in children {
            if child.isActive { return true }
        }
        return false
    }
    
    @discardableResult private func handle(_ comps: [LinkComponent]) async -> Bool {
        guard !comps.isEmpty, !children.isEmpty else { return false }
        var foundMatch = false
        
        for child in children {
            if foundMatch {
                await _ = child.handle([])
            } else if await child.handle(Array(comps.dropFirst())) {
                foundMatch = true
            }
        }
        
        return foundMatch
    }
    
    private func exhaustOtherChildren() async {
        for child in children {
            _ = await child.handle([])
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 20)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(RoutePreferenceKey.self){
                children = $0
            }
            .resetPreference(RoutePreferenceKey.self)
            .background{
                Color.clear.preference(key: RoutePreferenceKey.self, value: [
                    .init(
                        id: id,
                        isActive: previousMatch != nil || childIsActive,
                        handle: { comps in
                            if let path = comps.first?.path, let match = path.firstMatch(of: regex) {
                                if let previousMatch, previousMatch != match.output {
                                    self.previousMatch = nil
                                    await exhaustOtherChildren()
                                    other?()
                                    //try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 20)
                                    //await action(match.output)
                                    return false
                                }
                                
                                self.previousMatch = match.output
                                
                                if comps.count == 1 {
                                    await exhaustOtherChildren()
                                    await action(match.output)
                                    print("PATH MATCH", path)
                                    return true
                                }
                                
                                let wasHandled = await handle(comps)
                                
                                // Only proceed if another next match does not already exists.
                                if !wasHandled {
                                    await action(match.output)
                                    try? await Task.sleep(nanoseconds: nanoseconds(seconds: delay))
                                    return await handle(comps)
                                }
                                
                                return wasHandled
                            }
                            
                            self.previousMatch = nil
                            
                            // this was not a match so cancel all other routes belonging to this one.
                            await exhaustOtherChildren()
  
                            other?()
                            return false
                        }
                    )
                ])
            }
    }
    
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension RoutingRegexModifier: ViewModifier {}
