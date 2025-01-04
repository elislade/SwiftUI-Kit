import SwiftUIKit


public struct FocusExamples : View {

    @State private var presentedIndices: Set<Int> = []
    @State private var useAccessory = false
    @State private var useCustomFocusedView = false
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Focus Presentation"){
            ZStack {
                Color.clear
                
                LazyVGrid(columns: [.init(.adaptive(minimum: 90, maximum: 120))]){
                    ForEach(0...8){ i in
                        Button(action: {
                            Binding($presentedIndices, contains: i).wrappedValue.toggle()
                        }){
                            RoundedRectangle(cornerRadius: 20)
                                .aspectRatio(1.3, contentMode: .fit)
                                .scaleEffect(presentedIndices.contains(i) ? 1.1 : 1)
                        }
                        .buttonStyle(.plain)
                        .presentationBackground {
                            Rectangle().fill(.tint)
                                .colorInvert()
                                .opacity(0.5)
//                            Rectangle()
//                                .fill(.black)
//                                .blendMode(.saturation)
                        }
                        .focusPresentation(isPresented: Binding($presentedIndices, contains: i)){ state in
                            TipView(next: { presentedIndices = [i+1] })
                                .padding(.init(state.edge))
                        }
                    }
                }
            }
            .padding()
            .animation(.smooth, value: presentedIndices)
            .focusPresentationContext()
        } parameters: {
            Toggle(isOn: .init(get: { !presentedIndices.isEmpty }, set: {
                if $0 {
                    presentedIndices.insert(.random(in: 0...8))
                } else {
                    presentedIndices = []
                }
            })){
                Text("Presented")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $useCustomFocusedView){
                Text("Custom Focused View")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $useAccessory){
                Text("Accessory")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
        }
    }
    
    
    struct TipView: View {
        
        var next: (() -> Void)?
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("This is a Tip")
                    .font(.title2.bold())
                
                Text("You can do many usefull things with this tip like...")
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.5)
                
                if let next {
                    Button("Next Tip", action: next)
                        .buttonStyle(.macOSBasic)
                }
            }
            .padding()
            .frame(maxWidth: 250)
            .background{
                RoundedRectangle(cornerRadius: 15)
                    .fill(.bar)
                    .shadow(radius: 8, y: 5)
            }
        }
    }
    
}


#Preview("Focus Examples"){
    FocusExamples()
        .previewSize()
}
