import SwiftUIKit


struct ResetActionExamples: View {
    
    @State private var resetAction: ResetAction?
    @State private var resetAll = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.clear
                VStack(spacing: nil) {
                    ChildView()
                    
                    ChildView()
                        .disableResetAction()
                    
                    ChildView()
                }
                .padding()
                .childResetAction { action in
                    _resetAction.wrappedValue = action
                }
                .onChangePolyfill(of: resetAction){
                    if resetAll {
                        if let resetAction {
                            resetAction()
                        } else {
                            resetAll = false
                        }
                    }
                }
            }
            .background(.regularMaterial)
            
            Divider().ignoresSafeArea()

            VStack(spacing: 0) {
                ExampleTitle("Reset Action")
                    .padding(.vertical)
                
                HStack {
                    Button("Reset"){ resetAction?() }
                        .disabled(resetAction == nil)
                    
                    Button("Reset All"){
                        resetAll = true
                        resetAction?()
                    }
                    .disabled(resetAction == nil)
                }
                .lineLimit(1)
                .padding()
            }
        }
    }
    
    struct ChildView: View {
        
        @State private var value = 0.0
        
        var body: some View {
            Slider(value: $value)
                .resetAction(active: value != 0){
                    withAnimation(.bouncy){ value = 0 }
                }
        }
    }
    
}


#Preview("ResetAction Example") {
    ResetActionExamples()
        .previewSize()
}
