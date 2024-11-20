import SwiftUIKit


struct FontExamples: View {
    
    @State private var resource: FontResource?
    @State private var parameters = FontParameters.identity
    
    var body: some View {
        ExampleView(title: "Font"){
            Preview(resource: $resource, parameters: $parameters)
                .ignoresSafeArea(edges: .bottom)
        } parameters: {
            ExampleSection("Parameters", isExpanded: true){
                ParameterEditor(parameters: $parameters)
            }
            
            Divider()
            
            Inspector()
        }
        .fontResource(resource)
        .fontParameters(parameters)
    }
    
    
    struct AssetPicker : View {
        
        @Binding var resource: FontResource?
        
        private func name(for design: Font.Design) -> String {
            switch design {
            case .default: "Sans"
            case .serif: "Serif"
            case .rounded: "Rounded"
            case .monospaced: "Monospaced"
            @unknown default: "Unknown"
            }
        }
        
        var body: some View {
            Picker("Font Asset", selection: $resource){
                Section("Design"){
                    ForEach(Font.Design.allCases){
                        Text(name(for: $0))
                            .tag(Optional(FontResource.system(design: $0)))
                    }
                }
                
                Section("Library"){
                    ForEach(AvailableFont.fontFamilies, id: \.self){
                        Text($0)
                            .tag(Optional(FontResource.library(familyName: $0)))
                    }
                }
            }
        }
    }
    
    
    struct ParameterEditor: View {
        
        @Binding var parameters: FontParameters
        
        private func slider(for value: Binding<Double>) -> some View {
            VStack {
                Slider(value: value, in: -1...1, step: 0.01)
                
                HStack(spacing: 0) {
                    Button(action: { value.wrappedValue = -1}){
                        Text("-1")
                            .fontWeight(.semibold)
                            .frame(width: 24, alignment: .leading)
                    }
                    .disabled(value.wrappedValue == -1)
                    
                    ForEach(1...19){ i in
                        if i == 10 {
                            Button(action: { value.wrappedValue = 0 }) {
                                Capsule()
                                    .frame(width: 6)
                            }
                            .disabled(value.wrappedValue == 0)
                            .frame(maxWidth: .infinity)
                        } else {
                            Capsule()
                                .frame(width: i.isMultiple(of: 5) ? 2 : 1)
                                .frame(maxWidth: .infinity)
                                .opacity(i.isMultiple(of: 5) ? 1 : 0.3)
                        }
                    }
                    
                    Button(action: { value.wrappedValue = 1 }){
                        Text("+1")
                            .fontWeight(.semibold)
                            .frame(width: 24, alignment: .trailing)
                    }
                    .disabled(value.wrappedValue == 1)
                }
                .frame(height: 14)
                .buttonStyle(.tintStyle)
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Size")
                            .font(.exampleParameterTitle)
                        
                        Text("\(Int(parameters.size))")
                            .font(.exampleParameterValue)
                        
                        Spacer()
                        
                        Text("\(Font.TextStyle(closestToStaticSize: parameters.size))".splitCamelCaseFormat)
                            .font(.exampleParameterValue)
                            .opacity(0.6)
                    }
                    
                    Slider(value: $parameters.size, in: 10...120, step: 1)
                }
                .padding()
                
                Divider()
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Width")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                            Text(Font.Width(parameters.width).staticDefinedClosest.description)
                                .opacity(0.6)
                            //Text(Font.Width.compressed.value, format: .number)
                        } else {
                            Text(parameters.width, format: .number)
                                .font(.exampleParameterValue)
                                .opacity(0.6)
                        }
                    }
                    
                    slider(for: $parameters.width)
                }
                .padding()
                
                Divider()
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Slant")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(parameters.slant, format: .number.rounded(increment: 0.01))
                            .opacity(0.6)
                            .font(.exampleParameterValue)
                    }
                    
                    slider(for: $parameters.slant)
                }
                .padding()
                
                Divider()
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Weight")
                            .font(.exampleParameterTitle)
                        
                        Text(Font.Weight(closestToValue: parameters.weight).value, format: .number)
                            .font(.exampleParameterValue)
                        
                        Spacer()
                        
                        Text("\(Font.Weight(closestToValue: parameters.weight))")
                            .opacity(0.6)
                    }
                    
                    slider(for: $parameters.weight)
                }
                .padding()
            }
        }
    }

    
    struct Preview: View {
        
        enum Mode: UInt8, Hashable, CaseIterable {
            case text
            case paragraph
            case chars
        }
        
        @State private var mode: Mode = .paragraph
        @State private var sample = "Hello, World!"
        
        @Binding var resource: FontResource?
        @Binding var parameters: FontParameters
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    switch mode {
                    case .chars:
                        Chars()
                    case .text:
                        SwiftUI.TextField("Example Text", text: $sample)
                            .multilineTextAlignment(.center)
                            .resolveFont()
                            .padding(.horizontal)
                            .textFieldStyle(.plain)
                    case .paragraph:
                        Text("The quick brown fox jumps over the lazy dog, scaring the Cup to run away with the Spoon and get Hepatitis TEA.")
                            .multilineTextAlignment(.center)
                            .resolveFont()
                            .padding(.horizontal)
                    }
                }
                .animation(.smooth, value: parameters)
                
                HStack(spacing: 0) {
                    AssetPicker(resource: $resource)
                    
                    Spacer(minLength: 10)
                    
                    HStack {
                        SegmentedPicker(selection: $mode.animation(.smooth), items: Mode.allCases){ m in
                            switch m {
                            case .chars: Image(systemName: "abc")
                            case .text: Image(systemName: "character.cursor.ibeam")
                            case .paragraph: Image(systemName: "paragraph")
                            }
                        }
                        .controlRoundness(1)
                        .frame(width: 140)
                        
                        Button("Reset", systemImage: "arrow.clockwise.circle.fill"){ parameters = .identity }
                            .font(.title)
                            .labelStyle(.iconOnly)
                            .symbolRenderingMode(.hierarchical)
                            .disabled(parameters == .identity)
                            .buttonStyle(.tintStyle)
                    }
                }
                .padding([.vertical, .trailing])
                .padding(.leading, 8)
                .ignoresSafeArea()
            }
        }
    }
    

    struct Inspector: View  {
        
        @Environment(\.fontResolved) private var resolved
        
        struct Cell: View {
            let key: String
            let value: String
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(key.splitCamelCaseFormat)
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                       
                        if value.count <= 60 {
                            Text(value)
                                .opacity(0.5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if value.count > 60 {
                        Text(value)
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }

        var body: some View {
            ExampleSection("Info", isExpanded: true) {
                Info(info: resolved.info)
            }
           
            Divider()
            
            ExampleSection("Metrics", isExpanded: true) {
                Metrics(metrics: resolved.metrics)
            }
        }
        
        struct Info: View {
            
            let info: SwiftUIFont.FontInfo
            
            @ViewBuilder private func InfoCell(_ path: KeyPath<SwiftUIFont.FontInfo, String>) -> some View {
                if !info[keyPath: path].isEmpty {
                    Cell(
                        key: "\(path)".replacingOccurrences(of: "\\FontInfo.", with: ""),
                        value: info[keyPath: path]
                    )
                }
            }
            
            var body: some View {
                Group {
                    InfoCell(\.familyName)
                    InfoCell(\.subFamilyName)
                    InfoCell(\.styleName)
                    InfoCell(\.fullName)
                    InfoCell(\.uniqueName)
                }
                
                Divider().padding(.vertical, 8)
                
                Group {
                    InfoCell(\.manufacturer)
                    InfoCell(\.designer)
                    InfoCell(\.description)
                    InfoCell(\.version)
                    InfoCell(\.trademark)
                }
                
                Divider().padding(.vertical, 8)
                
                InfoCell(\.copyright)
                
                Divider().padding(.vertical, 8)
                
                Cell(
                    key: "languages",
                    value: info.supportedLanguages
                        .joined(separator: ", ") + "."
                )
            }
        }
        
        
        struct Metrics: View {
            
            let metrics: FontMetrics
            
            private func MetricCell(_ path: KeyPath<FontMetrics, Double>) -> some View {
                Cell(
                    key: "\(path)".replacingOccurrences(of: "\\FontMetrics.", with: ""),
                    value: metrics[keyPath: path].formatted(.number.rounded(increment: 0.001))
                )
            }
            
            var body: some View {
                Group {
                    MetricCell(\.size)
                    MetricCell(\.leading)
                }
                
                Divider().padding(.vertical, 8)
                
                Group {
                    MetricCell(\.ascent)
                    MetricCell(\.descent)
                    MetricCell(\.xHeight)
                    MetricCell(\.capHeight)
                }
                
                Divider().padding(.vertical, 8)
                
                MetricCell(\.slantAngle)
                
                Divider().padding(.vertical, 8)
                
                Group {
                    MetricCell(\.underlineThickness)
                    MetricCell(\.underlinePosition)
                }
                
                Divider().padding(.vertical, 8)
                
                Group {
                    Cell(key: "No. Glyphs", value: metrics.numberOfGlyphs.formatted())
                    Cell(key: "Units Per Em", value: metrics.unitsPerEm.formatted())
                }
            }
        }
        
    }
        
    
    
    struct Chars: View {
        
        @Environment(\.fontResource) private var fa
        @Environment(\.fontResolved) private var resolved
        @Namespace private var ns
        
        private var set: CharacterSet { resolved.supportedCharacters }
        
        @State private var chars: [Character] = []
        @State private var selected: Character?
        @State private var isLoading: Bool = true
        
        private func process(only includeSet: CharacterSet) -> [Character] {
            var nc: [Character] = []
            
            for i in 0x00000 ... 0xfffff {
                if let s = UnicodeScalar(i), includeSet.contains(s) {
                    let ch = Character(s)
                    if !ch.isWhitespace {
                        nc.append(Character(s))
                    }
                }
            }
            
            return nc
        }
        
        
        private func load() {
            Task {
                self.isLoading = true
                self.chars = self.process(only: set)
                self.isLoading = false
            }
        }
        
        var body: some View {
            GeometryReader { proxy in
                let rows: Double = proxy.size.height < 320 ? 5 : 8
                let tileSize = proxy.size.height / rows
                ZStack {
                    ScrollView(.horizontal) {
                        LazyHGrid(
                            rows: Array(repeating: .init(.fixed(tileSize), spacing: 0), count: Int(rows)),
                            spacing: 0
                        ) {
                            ForEach(chars, id: \.self){ c in
                                if selected != c {
                                    Button(action: { selected = c }){
                                        ZStack {
                                            Color.clear
                                            Text(String(c))
                                                .padding(5)
                                        }
                                    }
                                    .matchedGeometryEffect(id: c, in: ns)
                                    .frame(width: tileSize, height: tileSize)
                                } else {
                                    Color.clear.frame(width: tileSize, height: tileSize)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .opacity(selected == nil ? 1 : 0)
                    .opacity(isLoading ? 0.1 : 1)
                    .allowsHitTesting(selected == nil)
                    
                    if let selected {
                        Button(action: { self.selected = nil }){
                            ZStack {
                                Color.clear
                                Text(String(selected))
                            }
                            .contentShape(Rectangle())
                        }
                        .matchedGeometryEffect(id: selected, in: ns)
                        
                        Button(action: { self.selected = nil }){
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding()
                                .opacity(0.2)
                        }
                        .transition(
                            .move(edge: .leading).animation(.easeInOut.delay(0.5))
                        )
                    }
                    
                    if isLoading && selected == nil {
                        LoadingCircle(state: .indefinite)
                            .frame(width: proxy.size.height / 5, height: proxy.size.height / 5)
                    }
                }
                .resolveFont(overriding: \.size, value: proxy.size.height)
                .minimumScaleFactor(0.05)
            }
            .buttonStyle(.plain)
            .animation(.smooth, value: chars)
            .animation(.fastSpringInterpolating, value: selected)
            .onChangePolyfill(of: set, initial: true){
                load()
            }
        }
    }
    
    
}


#Preview("Font") {
    FontExamples()
}
