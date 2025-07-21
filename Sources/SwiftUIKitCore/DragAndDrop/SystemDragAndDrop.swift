import SwiftUI
import UniformTypeIdentifiers


public protocol DraggablePayload: Codable, Sendable {
    static var dragType: UTType { get }
    static var dragVisibility: NSItemProviderRepresentationVisibility { get }
}

public extension DraggablePayload {
    static var dragType: UTType { .data }
    static var dragVisibility: NSItemProviderRepresentationVisibility { .ownProcess }
}


public extension View {
    
    #if os(watchOS) || os(tvOS)
    
    nonisolated func onDrag<Payload: DraggablePayload>(_ payload: Payload, preferredSize: CGSize? = nil) -> Self {
        self
    }
    
    nonisolated func onDrop<Payload: DraggablePayload>(isTargeted: Binding<Bool>? = nil , _ callback: @escaping ([Payload], CGPoint) -> Void) -> Self {
        self
    }
    
    #else
    
    nonisolated func onDrag<Payload: DraggablePayload>(_ payload: Payload, preferredSize: CGSize? = nil) -> some View {
        onDrag({
            NSItemProvider(encoding: payload, with: preferredSize)
        })
    }
    
    nonisolated func onDrop<Payload: DraggablePayload>(isTargeted: Binding<Bool>? = nil , _ callback: @MainActor @escaping ([Payload], CGPoint) -> Void) -> some View {
        onDrop(of: [ Payload.dragType ], isTargeted: isTargeted){ providers, location in
            Task { @MainActor in
                let res: [Payload] = try await providers.decode()
                callback(res, location)
            }
            return true
        }
    }
    
    #endif
    
}


public extension DynamicViewContent {
    
    nonisolated func onInsert<Payload: DraggablePayload>(callback: @MainActor @escaping (Int, [Payload]) -> Void) -> some DynamicViewContent {
        onInsert(of: [ Payload.dragType ]){ i, providers in
            Task { @MainActor in
                let items: [Payload] = try await providers.decode()
                callback(i, items)
            }
        }
    }
  
}

extension NSItemProvider: @unchecked @retroactive Sendable {}

public extension NSItemProvider {
    
    func load(typeIdentifier: String) async throws -> Data? {
        try await withCheckedThrowingContinuation{ continuation in
            loadDataRepresentation(forTypeIdentifier: typeIdentifier){ data, err in
                if let err {
                    continuation.resume(throwing: err)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
    
    convenience init<Payload: DraggablePayload>(encoding payload: Payload, with preferredSize: CGSize? = nil){
        self.init()
        
        self.registerDataRepresentation(
            forTypeIdentifier: Payload.dragType.identifier,
            visibility: Payload.dragVisibility
        ){ callback in
            do {
                let data = try JSONEncoder().encode(payload)
                callback(data, nil)
            } catch {
                callback(nil, error)
            }
            return nil
        }
        
        #if os(iOS)
            if let preferredSize {
               self.preferredPresentationSize = preferredSize
            }
        #endif
    }
    
}

public extension Collection where Element == NSItemProvider {
    
    func decode<Payload: DraggablePayload>() async throws -> [Payload] {
        var items: [Payload] = []
        for provider in self {
            if
                let data = try await provider.load(typeIdentifier: Payload.dragType.identifier)
            {
                items.append(try JSONDecoder().decode(Payload.self, from: data))
            }
        }
        return items
    }
    
}
