import SwiftUIKit


struct DragAndDropExamples: View {
    
    @State private var from = ["A", "B", "C"]
    @State private var to: [String] = []
    
    var body: some View {
        HStack(spacing: 0){
            StringList(items: $from)
                .frame(maxWidth: 200)
            
            Divider().ignoresSafeArea()
            
            StringList(items: $to)
                .frame(maxWidth: 200)
        }
    }
    
    
    private struct StringList: View {
        
        @Binding var items: [String]
        @State private var dropLocation: CGPoint?
        
        var body: some View {
            //ScrollView {
                VStack(spacing: 16) {
                    ForEach(items){
                        Text($0)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(.red))
                            .onDrag($0)
                            .transitions(.scale(0.8), .opacity)
                    }
                    
                    Color.clear
                }
                .padding()
            //}
            .overlay{
                if let dropLocation {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .position(dropLocation)
                    Text(dropLocation.debugDescription)
                }
            }
            .animation(.fastSpring, value: items)
            .onDrop{ results, location in
                dropLocation = location
                items.append(contentsOf: results)
            }
        }
    }
}


extension String: DraggablePayload { }


#Preview("Drag & Drop") {
    DragAndDropExamples()
}
