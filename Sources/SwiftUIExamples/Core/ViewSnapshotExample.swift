import SwiftUIKit


public struct ViewSnapshotExample: View {
    
    struct IDView {
        let id: UUID = .init()
        let view: AnyView
    }
    
    @State private var snapshot: IDView?
    @State private var signal = true
    @State private var showBackgroundBlurArtifacting = true
    
    public init(){}
    
    public var body: some View {
        VStack(spacing: 10) {
            Color.secondary.opacity(0.1).overlay {
                if let snapshot {
                    snapshot.view
                        .allowsHitTesting(false)
                        .transition(
                            .asymmetric(
                                insertion: .offset([0,400]),
                                removal: .scale(scale: 0, anchor: .top) + .opacity + .blur(radius: 20)
                            )
                            .animation(.bouncy)
                        )
                        .id(snapshot.id)
                        .zIndex(1)
                }
            }
            .zIndex(2)
            
            ZStack {
                if showBackgroundBlurArtifacting {
                    Circle()
                        .fill(.red)
                        .frame(width: 140, height: 140)
                }
                
                ScrollView {
                    VStack(spacing: 50) {
                        ForEach(0..<9){ i in
                            Rectangle()
                                .fill(Color.random)
                                .frame(height: 100)
                        }
                    }
                }
                .background(.regularMaterial)
            }
            .viewSnapshot(for: signal, initial: true){ v in
                snapshot = .init(view: v)
            }
            .id(showBackgroundBlurArtifacting)
        }
        .overlay(alignment: .center){
            Button { signal.toggle() } label: {
                Label{ Text("Capture") } icon: {
                    Image(systemName: "camera.aperture")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.8)
                        .padding(20)
                        .foregroundStyle(.white)
                        .symbolEffectBounce(value: signal)
                        .background{
                            Circle()
                                .fill(.white)
                                .shadow(radius: 10, y: 10)
                            Circle()
                                .fill(.red)
                                .padding(5)
                        }
                }
            }
            .frame(height: 80)
        }
        .ignoresSafeArea(edges: .bottom)
        .safeAreaInset(edge: .top, spacing: 0){
            VStack {
                ExampleTitle("View Snapshot")
                
                #if !os(watchOS)
                Toggle(isOn: $showBackgroundBlurArtifacting){
                    Text("BG Blur Artifacting")
                        .font(.exampleParameterTitle)
                        .minimumScaleFactor(0.8)
                }
                #endif
            }
            .padding()
            .background(.regularMaterial)
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .toggleStyle(.swiftUIKitSwitch)
    }
    
}


#Preview {
    ViewSnapshotExample()
        .previewSize()
}
