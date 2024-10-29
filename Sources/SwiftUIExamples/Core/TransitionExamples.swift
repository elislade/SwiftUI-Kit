import SwiftUIKit


struct TransitionExamples: View {
    
    @State private var transitions: [AnyTransition] = []
    @State private var show = false
    
    var body: some View {
        ExampleView(title: "Transitions"){
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    
                    if show {
                        Color.primary
                            .padding(-1)
                            .transitions(transitions)
                    }
                }
                
                LoadingLine(state: .progress(show ? 1 : 0))
            }
            .animation(.smooth, value: show)
            .background {
                VStack {
                    Text("Transitions")
                    Text("(\(transitions.count))")
                        .contentTransitionNumericText()
                        .animation(.smooth, value: transitions.count)
                }
                .font(.system(size: 48, weight: .bold))
                .fixedSize()
                .opacity(0.2)
            }
            .overlay(alignment: .bottom){
                HStack(spacing: 0) {
                    Button(show ? "Hide" : "Show", systemImage: show ? "backward.end" : "forward.end"){
                        show.toggle()
                    }
                    .contentTransitionSymbolEffect()
                    
                    Spacer()
                    
                    Button("Clear", systemImage: "trash", role: .destructive){
                        transitions = []
                    }
                }
                .disabled(transitions.isEmpty)
                .symbolVariant(.circle.fill)
                .padding()
                .font(.largeTitle)
            }
            .ignoresSafeArea()
        } parameters: {
            Opacity{ transitions.append($0) }
                .padding()
            
            Divider()
            
            Blur{ transitions.append($0) }
                .padding()
            
            Divider()
            
            Rotation3D{ transitions.append($0) }
                .padding()
            
            Divider()
            
            Rotation2D{ transitions.append($0) }
                .padding()
            
            Divider()
            
            Scale{ transitions.append($0) }
                .padding()
            
            Divider()
            
            Frame{ transitions.append($0) }
                .padding()
            
            Divider()
            
            ClipRoundedRect{ transitions.append($0) }
                .padding()
            
            Divider()
        }
        //.toggleStyle(.swiftUIKitSwitch)
        .buttonStyle(.tintStyle)
        .symbolRenderingMode(.hierarchical)
        .labelStyle(.iconOnly)
        .onChange(of: transitions.count){ _ in
            show = false
        }
    }
    
    
    struct Opacity: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var amount: Double = 0
        
        var body: some View {
            VStack {
                HStack {
                    Text("Opacity").font(.exampleParameterTitle)
                    Text(amount, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.opacity(amount))
                    }
                    .font(.title)
                }
                
                Slider(value: $amount, in : 0...1, step: 0.1)
            }
        }
    }
    
    
    struct Blur: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var amount: Double = 10
        
        var body: some View {
            VStack {
                HStack {
                    Text("Blur").font(.exampleParameterTitle)
                    Text(amount, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.blur(radius: amount))
                    }
                    .font(.title)
                }
                
                Slider(value: $amount, in : 0...50, step: 1)
            }
        }
    }
    
    
    struct Rotation3D: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var amount: Double = 10
        
        @State private var x = false
        @State private var y = false
        @State private var z = false
        
        private var axis: Axis3D {
            Axis3D(
                x: x ? 1 : 0,
                y: y ? 1 : 0,
                z: z ? 1 : 0
            )
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("Rotation 3D").font(.exampleParameterTitle)
                    
                    Text(amount, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.rotation3D(angle: .degrees(amount), axis: axis))
                    }
                    .font(.title)
                    .disabled(!(x || y || z))
                }
                
                HStack(alignment: .bottom) {
                    VStack {
                        HStack {
                            Toggle(isOn: $x){ Text("X") }
                            Divider()
                            Toggle(isOn: $y){ Text("Y") }
                            Divider()
                            Toggle(isOn: $z){ Text("Z") }
                        }
                        
                        Slider(value: $amount, in : -360...360, step: 5)
                            .disabled(!(x || y || z))
                    }
                }
            }
        }
    }
    
    
    struct Rotation2D: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var amount: Double = 10
        @State private var anchor = UnitPoint.center
        
        var body: some View {
            VStack {
                HStack {
                    Text("Rotation 2D").font(.exampleParameterTitle)
                    Text(amount, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.rotation(angle: .degrees(amount), anchor: anchor))
                    }
                    .font(.title)
                }

                HStack(alignment: .bottom) {
                    Slider(value: $amount, in : -360...360, step: 5)
                }
                
                ExampleControl.Anchor(value: $anchor)
                    .frame(width: 100, height: 100)
            }
        }
    }
    
    
    struct Frame: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var width: Double = 10
        @State private var height: Double = 10
        
        var body: some View {
            VStack {
                HStack {
                    Text("Frame").font(.exampleParameterTitle)
                    Group {
                        Text(width, format: .number)
                        Text(height, format: .number)
                    }
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.frame(
                            maxWidth: width,
                            maxHeight: height
                        ))
                    }
                    .font(.title)
                }
                
                HStack(alignment: .center) {
                    Slider(value: $width, in : 0...360, step: 1)
                    Slider(value: $height, in : 0...360, step: 1)
                }
            }
        }
    }
    
    
    struct Scale: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var width: Double = 0
        @State private var height: Double = 0
        @State private var anchor = UnitPoint.center
        
        var body: some View {
            VStack {
                HStack {
                    Text("Scale").font(.exampleParameterTitle)
                    
                    Group {
                        Text(width, format: .number)
                        Text(height, format: .number)
                    }
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(
                            .scale(x: width, y: height, anchor: anchor)
                        )
                    }
                    .font(.title)
                }
                
                HStack(alignment: .center) {
                    Slider(value: $width, in : 0...1, step: 0.1)
                    Slider(value: $height, in : 0...1, step: 0.1)
                }
                
                ExampleControl.Anchor(value: $anchor)
                    .frame(width: 100, height: 100)
            }
        }
    }
    
    
    struct ClipRoundedRect: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var width: Double = 1
        @State private var anchor = UnitPoint.center
        
        var body: some View {
            VStack {
                HStack {
                    Text("Clip Rounded Rect").font(.exampleParameterTitle)
                    Text(width, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.clipRoundedRectangle(
                            RoundedRectangle(cornerRadius: width)
                        ))
                    }
                    .font(.title)
                }
                
                Slider(value: $width, in : 0...100, step: 1)
            }
        }
    }

}


#Preview("Transitions") {
    TransitionExamples()
}
