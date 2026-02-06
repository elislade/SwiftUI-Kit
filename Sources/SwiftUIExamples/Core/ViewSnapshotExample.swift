import SwiftUIKit


public struct ViewSnapshotExample: View {
    
    struct Snap: Identifiable, Hashable {
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        let id = Date()
        let view: AnyView
        
    }
    
    @Namespace private var ns
    @State private var snapshots: [Snap] = []
    @State private var snapshotsToAdd: [Snap] = []
    @State private var selected: Snap?
    @State private var signal = true
    @State private var showBackgroundBlurArtifacting = true
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "View Snapshot"){
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<50){ i in
                       RoundedRectangle(cornerRadius: 22)
                            .fill(.tint)
                            .opacity(Double(i % 10) / 10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 22)
                                    .strokeBorder()
                                    .opacity(0.1)
                                
                                Text(i + 1, format: .number)
                                    .font(.largeTitle[.bold])
                            }
                            .frame(height: 100)
                    }
                }
                .padding(10)
            }
            .background(.regularMaterial)
            .background{
                if showBackgroundBlurArtifacting {
                    Rectangle()
                        .scaleEffect(0.5)
                }
            }
            .background(.background)
            .mask{
                RoundedRectangle(cornerRadius: 32)
                    .ignoresSafeArea()
            }
            .viewSnapshot(for: signal, initial: true){ view in
                selected = nil
                snapshotsToAdd.append(Snap(view: view))
            }
            .background {
                ForEach(snapshotsToAdd){ snap in
                    snap.view
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                        .transition(.identity)
                        .matchedGeometryEffect(id: snap.id, in: ns, isSource: snapshots.contains(snap))
                        .onAppear{ snapshots.insert(snap, at: 0) }
                        .background{
                            if !snapshots.contains(snap) {
                                Color.clear.onDisappear{
                                    snapshotsToAdd.removeAll(where: { $0.id == snap.id })
                                }
                            }
                        }
                }
            }
            .overlay {
                if let selected {
                    selected.view
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity(0.999))
                        .matchedGeometryEffect(id: selected.id, in: ns, isSource: true)
                        .onTapGesture{ self.selected = nil }
                        .id(selected.id)
                }
            }
            .ignoresSafeArea()
        } parameters: {
            #if !os(watchOS)
            Toggle(isOn: $showBackgroundBlurArtifacting){
                Text("Test BG Blur")
                    .font(.exampleParameterTitle)
                    .minimumScaleFactor(0.8)
            }
            .exampleParameterCell()
            #endif
            
            HStack(spacing: 10) {
                SnapList(
                    ns: ns,
                    viewing: $selected,
                    snaps: snapshots
                )
                .environment(\.layoutDirection, .rightToLeft)
                
                Button { signal.toggle() } label: {
                    Label{ Text("Capture") } icon: {
                        Image(systemName: "camera.aperture")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.6)
                            .foregroundStyle(.white)
                            .background{
                                ContainerRelativeShape().fill(.tint)
                            }
                    }
                }
                .labelStyle(.iconOnly)
                .keyboardShortcut(KeyEquivalent.space, modifiers: [])
            }
            .buttonStyle(.plain)
            .containerShape(RoundedRectangle(cornerRadius: 14))
            .frame(height: 74)
            .padding()

        }
        .animation(.smooth.speed(1.6), value: selected)
        .animation(.smooth.speed(1.6), value: snapshots)
    }
    
    
    struct SnapList: View {
        
        let ns: Namespace.ID
        @Binding var viewing: Snap?
        let snaps: [Snap]
        
        var body: some View {
            ScrollViewReader{ proxy in
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 8) {
                        ForEach(snaps) { snap in
                            snap.view
                                .id(snap.id)
                                .zIndex(
                                    Double(snaps.count - snaps.firstIndex(of: snap)!)
                                )
                                .aspectRatio(contentMode: .fit)
                                .hidden()
                                .background{
                                    if viewing == snap {
                                        Button{ viewing = nil } label: {
                                            Label{ Text("Close") } icon: {
                                                Image(systemName: "xmark")
                                            }
                                            .labelStyle(.iconOnly)
                                            .fontWeight(.heavy)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background{
                                                RoundedRectangle(cornerRadius: 5)
                                                    .opacity(0.1)
                                            }
                                        }
                                        .buttonStyle(.tinted)
                                    } else {
                                        snap.view
                                            .transition(.opacity(0.99))
                                            .matchedGeometryEffect(id: snap.id, in: ns, isSource: true)
                                    }
                                }
                                .onTapGesture{
                                    viewing = snap
                                }
                                .onAppear{
                                    withAnimation(.smooth){
                                        proxy.scrollTo(snap.id)
                                    }
                                }
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .clipShape(ContainerRelativeShape())
                .background{
                    ContainerRelativeShape()
                        .fill(.gray.opacity(0.4))
                }
            }
        }
    }
    
}


#Preview {
    ViewSnapshotExample()
        .previewSize()
}
