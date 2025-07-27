import SwiftUIKit


struct SnapshotTest: View {
    
    @State private var snapshot: AnyView?
    @State private var signal = true

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.clear
                snapshot
            }
            
            Divider()
            
            ZStack {
                Circle().fill(.red)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<50){ i in
                            Color.random.frame(height: 60)
                        }
                    }
                }
                .background(.bar)
            }
            .viewSnapshot(for: signal){
                snapshot = $0
            }
            
            Button("Capture") {
                signal.toggle()
            }
            .padding()
        }
    }
    
}


#Preview {
    SnapshotTest()
}
