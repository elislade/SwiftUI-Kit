import SwiftUIKit


struct ReadableScrollViewExample : View {
    
    @State private var resetAction: ResetAction?
    @State private var size: CGFloat = 1000
    @State private var offset = CGPoint()
    @State private var axis: Axis.Set = [.vertical]
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Readable Scroll View"){
            ReadableScrollView(
                axis,
                contentOffset: { offset = $0 }
            ) {
                ZStack {
                    if axis.contains(.horizontal) {
                        HStack(spacing: 0){
                            ForEach(0...100){ i in
                                Color.primary
                                    .frame(width: 1)
                                    .frame(maxWidth: .infinity)
                                    .opacity(i.isMultiple(of: 10) ? 0.3 : 0.1)
                            }
                        }
                        .frame(
                            width: size,
                            height: axis.contains(.vertical) ? size : nil
                        )
                    }
                    
                    if axis.contains(.vertical) {
                        VStack(spacing: 0){
                            ForEach(0...100){ i in
                                Color.primary
                                    .frame(height: 1)
                                    .frame(maxHeight: .infinity)
                                    .opacity(i.isMultiple(of: 10) ? 0.3 : 0.1)
                            }
                        }
                        .frame(
                            width: axis.contains(.horizontal) ? size : nil,
                            height: size
                        )
                    }
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                HStack {
                    Image(systemName: "arrow.left.and.right.circle.fill")
                    Text(offset.x, format: .increment(0.1))
                    Spacer(minLength: 20)
                    Text(offset.y, format: .increment(0.1))
                    Image(systemName: "arrow.up.and.down.circle.fill")
                }
                .padding()
                .font(.title[.semibold][.monospacedDigit])
                .symbolRenderingMode(.hierarchical)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            }
            .childResetAction{ _resetAction.wrappedValue = $0 }
        } parameters: {
            Toggle(isOn: Binding($axis, contains: .horizontal)){
                Text("Horizontal Axis")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            Toggle(isOn: Binding($axis, contains: .vertical)){
                Text("Vertical Axis")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            HStack {
                Text("Reset Action")
                    .font(.exampleParameterTitle)
                    .fixedSize()
                
                Spacer()
                
                Button("Trigger", action: { resetAction?() })
                    .disabled(resetAction == nil)
            }
            .exampleParameterCell()
            
            VStack {
                HStack{
                    Text("Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(size, format: .number)
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $size, in: 300...1300, step: 10)
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview("Readable Scroll View") {
    ReadableScrollViewExample()
        .previewSize()
}
