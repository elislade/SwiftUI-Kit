import SwiftUIKit


public struct NavViewExamples: View {
   
    public init(){}
    
    public var body: some View {
        Content()
    }
    
    struct Content: View {
        
        @Environment(\.reset) private var reset
        @State private var layout: LayoutDirection = .leftToRight
        @State private var useCustomTransition = false
        @State private var barMode: NavViewBarMode = .container
        
        public var body: some View {
            ExampleView(title: "Nav View"){
                Group {
                    if useCustomTransition {
                        NavView(
                            transition: CustomTransition.self,
                            barMode: barMode
                        ) {
                            Destination(count: 1)
                        }
                    } else {
                        NavView(barMode: barMode) {
                            Destination(count: 1)
                        }
                    }
                }
                .presentationContext()
                .environment(\.layoutDirection, layout)
            } parameters: {
                ExampleSection(isExpanded: true){
                    HStack {
                        Toggle(isOn: $useCustomTransition){
                            Text("Custom Transition")
                        }
                        
                        Button{ reset() } label: {
                            Label("Reset", systemImage: "arrow.clockwise")
                        }
                    }
                    
                    ExampleMenuPicker(
                        data: NavViewBarMode.allCases,
                        selection: $barMode,
                        content: BarModeLabel.init
                    ){
                        Text("Bar Mode")
                    }
                    
                    ExampleCell.LayoutDirection(value: $layout)
                } label: {
                    Text("Parameters")
                }
            }
        }
        
    }
    
    
    struct BarModeLabel: View {
        
        let mode: NavViewBarMode
        
        init(_ mode: NavViewBarMode) {
            self.mode = mode
        }
        
        var body: some View {
            switch mode {
            case .none: Text("None")
            case .container: Text("Container")
            case .element: Text("Element")
            }
        }
    }
    
    
    struct Destination: View {
        
        @State private var showTrailingDetail = false
        
        let count: Int
        
        var body: some View {
            ReadableScrollView {
                LazyVStack(spacing: 0) {
                    Text(count, format: .number)
                        .font(.largeTitle[.heavy])
                        .padding()
                    
                    ForEach(1...10){ s in
                        Section {
                            ScrollView(.horizontal, showsIndicators: false){
                                LazyHStack(alignment: .bottom, spacing: 16){
                                    ForEach(0..<10){ i in
                                        Cell(index: i)
                                            .frame(width: 150)
                                    }
                                }
                                .padding()
                            }
                            .padding(.bottom, 40)
                            .foregroundStyle(.tint.opacity(Double(s) / 11))
                        } header: {
                            Text("Section \(s)")
                                .font(.title2[.bold])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                    }
                    
                    Section {
                        LazyVGrid(
                            columns: [.init(.adaptive(minimum: 150), spacing: 16, alignment: .bottom)],
                            spacing: 16
                        ){
                            ForEach(0...100){ i in
                                Cell(index: i)
                                    .foregroundStyle(.tint.opacity(Double(i) / 101))
                            }
                        }
                        .padding()
                    } header: {
                        Text("Section Header")
                            .font(.title2[.bold])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                .buttonStyle(.plain)
            }
            .background{
                ExampleBackground()
                    .ignoresSafeArea()
            }
            .scrollClipDisabledIfAvailable()
            .navBarTitle(Text(verbatim: "Number \(count)"))
            .navBarTrailing{
                TrailingActions(showB: $showTrailingDetail)
            }
        }
        
        
        struct TrailingActions: View {
            
            @Binding var showB: Bool
            @State private var showA = Bool.random()
            
            var body: some View {
                if showA {
                    Button{ print("A") } label: { Text("A") }
                }
                
                Toggle(isOn: $showB){ Text("B") }
                    .presentation(isPresented: $showB){
                        NavView{
                            Destination(count: 0)
                        }
                        .frame(height: 400)
                        .transition(
                            .moveEdgeIgnoredByLayout(.bottom)
                            .animation(.smooth.speed(1.5))
                        )
                    }
            }
            
        }
        
        
        struct Cell: View {
            
            @State private var useImage: Bool = .random()
            @State private var image: Image?
            @State private var show = false
            
            let index: Int
            
            let url = URL(
                string: "https://puzzlemania-154aa.kxcdn.com/products/2024/puzzle-schmidt-1000-pieces-random-galaxy.webp"
            )!
            
            private var placeholder: some View {
                RoundedRectangle(cornerRadius: 26)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .strokeBorder(.tint.opacity(0.3))
                    }
            }
            
            var body: some View {
                Button{ show = true } label: {
                    VStack(alignment: .leading) {
                        if useImage {
                            placeholder
                                .overlay { image?.resizable() }
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                                .aspectRatio(2, contentMode: .fit)
                                .coordinateTask{
                                    try await URLSession.shared.data(for: .init(url: url))
                                } succeeded: { result in
                                    self.image = Image(osImage: .init(data: result.0)!)
                                }
                        } else {
                            placeholder
                                .aspectRatio(1, contentMode: .fit)
                        }
                        
                        Text("Item \(index)")
                            .padding(.leading)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primary)
                    }
                    .contextMenuX{
                        Button("Test", systemImage: "flask"){
                            print("Test")
                        }
                        
                        ContainerRelativeShape()
                            .aspectRatio(1.5, contentMode: .fit)
                            .padding([.bottom, .horizontal], 10)
                    }
                }
                .navDestination(isPresented: $show){
                    Destination(count: index)
                }
            }
        }
        
    }
    
}


#Preview("NavView") {
    NavViewExamples()
        .previewSize()
}



struct CustomTransition : TransitionModifier {

    let pushAmount: Double
    
    init(pushAmount: Double) {
        self.pushAmount = pushAmount
    }
    
    func body(content: Content) -> some View {
        let scale: Double = 1 - (0.1 * pushAmount)
        content
            .blur(radius: pushAmount * 20)
            .opacity(1 - pushAmount)
            .scaleIgnoredByLayout([scale, scale], anchor: .top)
    }
        
}
