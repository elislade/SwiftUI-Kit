import SwiftUIKit


public struct FocusExamples : View {

    @State private var useAccessory = true
    @State private var useCustom = true
    
    static let gridItem = GridItem(.adaptive(minimum: 100), spacing: 16)
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Focus Presentation"){
            Color.clear.overlay{
                LazyVGrid(columns: [ Self.gridItem ], spacing: 16){
                    ForEach(0..<15){ i in
                        ItemView(
                            useCustom: useCustom,
                            useAccessory: useAccessory
                        )
                    }
                }
                .scaleEffect(1.5)
            }
            .padding()
            .presentationContext()
        } parameters: {
            Toggle(isOn: $useCustom){
                Text("Custom Focused View")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            Toggle(isOn: $useAccessory){
                Text("Accessory")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
        }
    }
    
    
    struct ItemView: View {
        
        @Namespace private var ns
        @State private var isPresented: Bool = false
        
        let useCustom: Bool
        let useAccessory: Bool
        
        private var custom: some View {
            VStack(alignment: .leading) {
                ContainerRelativeShape()
                    .fill(.tint)

                Text("Focus Item")
                    .font(.title3[.bold])
            }
            .frame(minHeight: 166)
            .padding()
            .background{
                ContainerRelativeShape()
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.6), radius: 20, y: 5)
                
                ContainerRelativeShape()
                    .strokeBorder()
                    .opacity(0.1)
            }
            .containerShape(RoundedRectangle(cornerRadius: 28))
        }
        
        private var accessory: some View {
            AccessoryView()
                .anchorLayoutPadding(10)
                .transition(.scale(0.8).animation(.bouncy))
        }
        
        private var inner: some View {
            Button{ isPresented.toggle() } label: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.tint)
            }
            .buttonStyle(.plain)
            .aspectRatio(1.8, contentMode: .fit)
        }
        
        var body: some View {
            if useCustom && useAccessory {
                inner.focusPresentation(
                    isPresented: $isPresented,
                    focus: { custom },
                    accessory: { accessory }
                )
            } else if useCustom {
                inner.focusPresentation(
                    isPresented: $isPresented,
                    focus: { custom }
                )
            } else if useAccessory {
                inner.focusPresentation(
                    isPresented: $isPresented,
                    accessory: { accessory }
                )
            } else {
                inner
                    .presentationBackdrop{ Color.black.opacity(0.8) }
                    .focusPresentation(isPresented: $isPresented)
            }
        }
        
    }
    
    
    struct AccessoryView: View {
        
        var body: some View {
            VStack(alignment: .center, spacing: 14) {
                Text("Focus Accessory")
                    .font(.title2.bold())
                
                Text("This is focus accessory content placed along side the focus view.")
                    .font(.callout)
                    .opacity(0.5)
            }
            .multilineTextAlignment(.center)
            .frame(width: 240)
            .padding(30)
            .background{
                RoundedRectangle(cornerRadius: 28)
                    .fill(.regularMaterial)
                    .shadow(radius: 8, y: 5)
            }
        }
    }
    
}


#Preview("Focus Examples"){
    FocusExamples()
        .previewSize()
}
