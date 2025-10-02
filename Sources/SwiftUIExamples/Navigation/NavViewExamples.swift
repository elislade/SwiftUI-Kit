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
                .background{
                    ZStack {
                        Rectangle()
                            .fill(.background)
                        
                        Rectangle()
                            .fill(.tint)
                            .opacity(0.1)
                    }
                    .ignoresSafeArea()
                }
                .fontResource(.system(design: .serif))
                .environment(\.layoutDirection, layout)
            } parameters: {
                Toggle(isOn: $useCustomTransition){
                    Text("Use Custom Transition")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                HStack {
                    Text("Bar Mode")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker(selection: $barMode){
                        ForEach(NavViewBarMode.allCases, id: \.self){ mode in
                           BarModeLabel(mode)
                                .tag(mode)
                        }
                    } label: {
                        EmptyView()
                    }
                    
                }
                .exampleParameterCell()
                
                HStack {
                    Text("Reset Action")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Button("Trigger"){ reset() }
                }
                .exampleParameterCell()
                
                ExampleCell.LayoutDirection(value: $layout)
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
        
        @State private var showDetail = false
        
        let count: Int
        
        var body: some View {
            ReadableScrollView {
                VStack(spacing: 0) {
                    Text(count, format: .number)
                        .font(.largeTitle[.heavy])
                        .padding()
                    
                    Button("Next"){
                        showDetail = true
                    }
                    .buttonStyle(.bar)
                    .padding()
                    
                    ForEach(1...10){ s in
                        Section {
                            ScrollView(.horizontal, showsIndicators: false){
                                LazyHStack(spacing: 16){
                                    ForEach(0..<10){ i in
                                        Button{ showDetail = true } label: {
                                            Cell(index: i)
                                        }
                                        .frame(width: 150)
                                    }
                                }
                                .padding()
                            }
                            .padding(.bottom, 40)
                        } header: {
                            Text("Section \(s)")
                                .font(.title2[.bold])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                    }
                    
                    Section {
                        LazyVGrid(
                            columns: [.init(.adaptive(minimum: 150), spacing: 16)],
                            spacing: 16
                        ){
                            ForEach(0...180){ i in
                                Button{ showDetail = true } label: {
                                    Cell(index: i)
                                }
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
                ZStack {
                    Rectangle()
                        .fill(.background)
                    
                    Rectangle()
                        .fill(.tint)
                        .opacity(0.1)
                }
                .ignoresSafeArea()
            }
            .navDestination(isPresented: $showDetail){
                Destination(count: count + 1)
            }
            .navBarTitle(Text(verbatim: "Number \(count)"))
            .navBarTrailing{
                TrailingActions()
            }
        }
        
        
        struct TrailingActions: View {
            
            @State private var test = false
            
            var body: some View {
                if Bool.random() {
                    Button{ print("A") } label: { Text("A") }
                }
                
                Toggle(isOn: $test){ Text("B") }
                    .navDestination(isPresented: $test){
                        Destination(count: 69)
                    }
                
                if Bool.random() {
                    Button{ print("C") } label: { Text("C") }
                }
            }
        }
        
        
        struct Cell: View {
            
            @State private var useImage: Bool = .random()
            @Environment(\.fontParameters) private var fontParameters
            
            let index: Int
            
            let url = URL(
                string: "https://puzzlemania-154aa.kxcdn.com/products/2024/puzzle-schmidt-1000-pieces-random-galaxy.webp"
            )
            
            private var placeholder: some View {
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        Color(
                            hue: Double(index * 2) / 360,
                            saturation: 0.7,
                            brightness: 1
                        )
                    )
                    .opacity(0.5)
            }
            
            var body: some View {
                VStack(alignment: .leading) {
                    if useImage {
                        AsyncImage(url: url){ image in
                            image.resizable()
                        } placeholder: {
                            placeholder
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .aspectRatio(1, contentMode: .fit)
                    } else {
                        placeholder
                            .aspectRatio(1, contentMode: .fit)
                    }
                    
                    Text("Item \(index)")
                        .padding(.leading)
                        .font(fontParameters[.italic])
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
        content
            .blur(radius: pushAmount * 20)
            .opacity(1 - pushAmount)
            .scaleEffect(1 - (0.1 * pushAmount), anchor: .top)
    }
        
}
