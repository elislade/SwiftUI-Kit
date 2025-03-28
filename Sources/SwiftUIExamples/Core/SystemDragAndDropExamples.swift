#if !os(tvOS) && !os(watchOS)

import SwiftUIKit


struct SystemDragAndDropExamples: View {
    
    @State private var groupA: [String] = ["A", "B", "C"]
    @State private var groupB: [String] = ["D", "E", "F"]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0){
                StringList(items: $groupA)
                
                Divider().ignoresSafeArea()
                
                StringList(items: $groupB)
            }
            .background{
                RoundedRectangle(cornerRadius: 30)
                    .fill(.bar)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder()
                    .opacity(0.1)
            }
            .padding()
            
            ExampleTitle("System Drag & Drop")
                .padding()
        }
    }
    
    
    struct StringList: View {
        
        @Namespace private var ns
        
        @Binding var items: [String]
        @State private var isDropping = false
        @State private var dropLocation: CGPoint?
        @State private var pendingDropIndex: Int?
        @State private var origin: CGPoint = .zero
        
        private var absoluteDropLocation: CGPoint? {
            guard let dropLocation else { return nil }
            return dropLocation.applying(.init(translationX: origin.x, y: origin.y))
        }
        
        var body: some View {
            VStack(spacing: 12) {
                ForEach(items){ item in
                    if pendingDropIndex == items.firstIndex(of: item) {
                        ExampleTile("")
                            .opacity(0.2)
                            .matchedGeometryEffect(id: "cursor", in: ns)
                    }
                    
                    ExampleTile(item)
                        .reorderingItem()
                        .onDrag(item)
                        .transitions(.scale(0.8), .opacity)
                }
                
                if let pendingDropIndex, !items.indices.contains(pendingDropIndex) {
                    ExampleTile("")
                        .opacity(0.2)
                        .transitions(.scale(1))
                        .matchedGeometryEffect(id: "cursor", in: ns)
                        .zIndex(1)
                }
            }
            .animation(.smooth, value: pendingDropIndex)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .padding()
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin }){ origin = $0 }
            .reorderingContext(axis: .vertical, location: absoluteDropLocation){ index in
                pendingDropIndex = index
            }
            .animation(.fastSpring, value: items)
            .onDrop(of: [.data], delegate: self)
        }
    }
}


extension String: DraggablePayload { }

extension SystemDragAndDropExamples.StringList: DropDelegate {
    
    func performDrop(info: DropInfo) -> Bool {
        isDropping = true
        info.itemProviders(for: [.data]).decode{ (strings: [String]) in
            if let pendingDropIndex {
                items.insert(contentsOf: strings, at: pendingDropIndex)
            } else {
                items.append(contentsOf: strings)
            }
            isDropping = false
            dropLocation = nil
        }
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.dropLocation = info.location
        return .init(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        if !isDropping {
            self.dropLocation = nil
        }
    }
    
}


#Preview("System Drag & Drop") {
    SystemDragAndDropExamples()
        .previewSize()
}


#endif
