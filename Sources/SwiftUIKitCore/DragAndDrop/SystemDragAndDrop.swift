import SwiftUI
import UniformTypeIdentifiers


public protocol DraggablePayload: Codable, Sendable {
    static var type: UTType { get }
}


public extension DraggablePayload {
    static var type: UTType { .data }
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
    
    nonisolated func onDrop<Payload: DraggablePayload>(isTargeted: Binding<Bool>? = nil , _ callback: @escaping ([Payload], CGPoint) -> Void) -> some View {
        onDrop(of: [ Payload.type ], isTargeted: isTargeted){ providers, location in
            providers.decode{ callback($0, location) }
            return true
        }
    }
    
    #endif
    
}


public extension DynamicViewContent {
    
    nonisolated func onInsert<Payload: DraggablePayload>(callback: @escaping (Int, [Payload]) -> Void) -> some DynamicViewContent {
        onInsert(of: [ Payload.type ]){ i, providers in
            providers.decode{ callback(i, $0) }
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
            forTypeIdentifier: Payload.type.identifier,
            visibility: .ownProcess
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
    
    func decode<Payload: DraggablePayload>(completion: @escaping ([Payload]) -> Void) {
        var items: [Payload] = []
        let group = DispatchGroup()
        
        for provider in self {
            group.enter()
            provider.loadDataRepresentation(forTypeIdentifier: Payload.type.identifier){ data, err in
                if let data, let item = try? JSONDecoder().decode(Payload.self, from: data) {
                    DispatchQueue.main.sync {
                        items.append(item)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main){
            completion(items)
        }
    }
    
    func decode<Payload: DraggablePayload>() async -> [Payload] {
        await withCheckedContinuation{ continuation in
            decode{
                continuation.resume(returning: $0)
            }
        }
    }
    
}
