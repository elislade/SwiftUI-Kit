import SwiftUIKit


public struct FontExamples: View {
    
    enum ResolverType: Hashable, CaseIterable {
        case swiftUI
        case coreText
    }
    
    @State private var resource: FontResource?
    @State private var parameters = FontParameters.identity
    @State private var ctResolver = FontCacheResolver(CTFontResolver())
    @State private var swiftResolver = FontCacheResolver(SwiftUIFontResolver())
    
    @State private var fontResolverType: ResolverType = .coreText
    @State private var dynamicSize: DynamicTypeSize = .medium
    
    private var fontResolver: FontResolver {
        switch fontResolverType {
        case .coreText: ctResolver
        case .swiftUI: swiftResolver
        }
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Font"){
            Preview(resource: $resource, parameters: $parameters)
                .ignoresSafeArea(edges: .bottom)
                .dynamicTypeSize(dynamicSize)
        } parameters: {
            ExampleSection("Parameters", isExpanded: true){
                HStack {
                    Text("Font Resolver")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $fontResolverType){
                        Text("Core Text").tag(ResolverType.coreText)
                        Text("SwiftUI").tag(ResolverType.swiftUI)
                    }
                }
                .exampleParameterCell()
                
                HStack {
                    Text("Dynamic Type")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $dynamicSize){
                        ForEach(DynamicTypeSize.allCases, id: \.hashValue){ size in
                            Text("\(size)".splitCamelCaseFormat)
                                .tag(size)
                        }
                    }
                }
                .exampleParameterCell()
                
                ParameterEditor(parameters: $parameters)
            }
            
            if fontResolverType == .coreText {
                Inspector()
            }
        }
        .fontResource(resource)
        .fontParameters(parameters)
        .fontResolver(fontResolver)
    }
    
    
    struct ResourcePicker : View {
        
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
            Picker("", selection: $resource){
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
    
    struct FontParameterSlider: View {
        
        @Environment(\.interactionGranularity) private var interactionGranularity
        
        @Binding var value: Double
        @State private var clamped = Clamped(0, in: -1...1, step: 0.1)
        
        private var height: CGFloat {
            50 - (interactionGranularity * 28)
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Button(action: { value = -1 }){
                    Text("-1")
                        .fontWeight(.semibold)
                        .frame(width: 24, alignment: .leading)
                }
                .disabled(value == -1)
                
                SliderView(x: $clamped, hitTestHandle: false){
                    SunkenControlMaterial(Capsule(), isTinted: true)
                        .frame(width: 8)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                }
                .background {
                    HStack(spacing: 0) {
                        ForEach(0...20){ i in
                            if i == 10 {
                                Capsule()
                                    .frame(width: 4)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Capsule()
                                    .frame(width: i.isMultiple(of: 5) ? 2 : 1)
                                    .frame(maxWidth: .infinity)
                                    .opacity(i.isMultiple(of: 5) ? 1 : 0.3)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, -4)
                }
                .frame(height: height)
                .buttonStyle(.tinted)
                
                Button(action: { value = 1 }){
                    Text("+1")
                        .fontWeight(.semibold)
                        .frame(width: 24, alignment: .trailing)
                }
                .disabled(value == 1)
            }
            .syncValue(_value.animation(.interactiveSpring), _clamped)
            .buttonStyle(.tinted)
        }
    }
    
    struct ParameterEditor: View {
        
        @Binding var parameters: FontParameters
        
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
                    .animation(nil, value: parameters.size)
                    
                    Slider(value: $parameters.size, in: 10...120, step: 1)
                }
                .exampleParameterCell()
              
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
                    .animation(nil, value: parameters.width)
                    
                    FontParameterSlider(value: $parameters.width)
                }
                .exampleParameterCell()
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Slant")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(parameters.slant, format: .number.rounded(increment: 0.01))
                            .opacity(0.6)
                            .font(.exampleParameterValue)
                    }
                    .animation(nil, value: parameters.slant)
                    
                    FontParameterSlider(value: $parameters.slant)
                }
                .exampleParameterCell()

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
                    .animation(nil, value: parameters.weight)
                    
                    FontParameterSlider(value: $parameters.weight)
                }
                .exampleParameterCell()
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
                    ResourcePicker(resource: $resource)
                    
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
                        
                        Button("Reset", systemImage: "arrow.clockwise.circle.fill"){
                            parameters = .identity
                        }
                        .font(.title)
                        .labelStyle(.iconOnly)
                        .symbolRenderingMode(.hierarchical)
                        .disabled(parameters == .identity)
                        .buttonStyle(.tinted)
                    }
                }
                .padding([.vertical, .trailing])
                .padding(.leading, 8)
                .ignoresSafeArea()
            }
        }
    }
    

    struct Inspector: View  {
        
        @Environment(\.resolvedFont) private var resolved
        
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
            
            @Environment(\.openURL) private var openURL
            
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
                
                if info.licenseURL != nil || info.vendorURL != nil {
                    HStack {
                        Spacer()
                        
                        if let url = info.licenseURL {
                            Button("License"){ openURL(url) }
                                .toolTip(edge: .top){
                                    Text(url.absoluteString)
                                }
                        }
                        
                        if let url = info.vendorURL {
                            if info.licenseURL != nil {
                                Text("•")
                                    .opacity(0.3)
                            }
                            
                            Button("Vendor"){ openURL(url) }
                                .toolTip(edge: .top){
                                    Text(url.absoluteString)
                                }
                        }
                    }
                    .buttonStyle(.tinted)
                    .padding(.horizontal)
                    .lineLimit(1)
                }
                
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
        @Environment(\.resolvedFont) private var resolved
        @Namespace private var ns
        
        private var set: CharacterSet {
            let candidate = resolved.supportedCharacters
            return candidate.isEmpty ? .alphanumerics.union(.punctuationCharacters).union(.symbols) : candidate
        }
        
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: Array(repeating: .init(.fixed(tileSize), spacing: 1), count: Int(rows)),
                            spacing: 1
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
                        #if os(macOS)
                        .padding(.bottom, 14) // Removes weird dead zone on macOS. Probably has to do with hidden scroll bar not removing its event tracker.
                        #endif
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
                        .keyboardShortcut(KeyEquivalent.escape, modifiers: [])
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
        .previewSize()
}
