import SwiftUI
import UniformTypeIdentifiers


public protocol DraggablePayload: Codable, Sendable {
    static var type: UTType { get }
}


public extension DraggablePayload {
    static var type: UTType { .data }
}


public extension View {
    
    @inlinable nonisolated func onDrag<Payload: DraggablePayload>(_ payload: Payload, preferredSize: CGSize? = nil) -> some View {
        onDrag({
            let item = NSItemProvider()
            
            item.registerDataRepresentation(
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
                   item.preferredPresentationSize = preferredSize
                }
            #endif
            
            return item
        })
    }
    
    
    @inlinable nonisolated func onDrop<Payload: DraggablePayload>(isTargeted: Binding<Bool>? = nil , _ callback: @escaping ([Payload], CGPoint) -> Void) -> some View {
        onDrop(of: [ Payload.type ], isTargeted: isTargeted){ providers, location in
            var items: [Payload] = []
            let group = DispatchGroup()
            
            for provider in providers {
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
                callback(items, location)
            }
    
            return true
        }
    }
    
}


public extension DynamicViewContent {
    
    @inlinable nonisolated func onInsert<Payload: DraggablePayload>(callback: @escaping (Int, [Payload]) -> Void) -> some DynamicViewContent {
        onInsert(of: [ Payload.type ]){ i, providers in
            var items: [Payload] = []
            let group = DispatchGroup()
            
            for provider in providers {
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
                callback(i, items)
            }
        }
    }
    
}
