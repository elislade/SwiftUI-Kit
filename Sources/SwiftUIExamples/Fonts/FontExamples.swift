import SwiftUIKit


public struct FontExamples: View {
    
    enum ResolverType: Hashable, CaseIterable {
        case swiftUI
        case coreText
    }
    
    @State private var resource: FontResource = .system(design: .default)
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
            Preview(
                resource: $resource,
                parameters: $parameters,
                dynamicSize: dynamicSize
            )
        } parameters: {
            ExampleSection("Parameters", isExpanded: true){
                
                HStack {
                    ExampleMenuPicker(
                        data: ResolverType.allCases,
                        selection: $fontResolverType
                    ){ type in
                        switch type {
                        case .coreText: Text("Core Text")
                        case .swiftUI: Text("SwiftUI")
                        }
                    } label: {
                        Text("Font Resolver")
                    }

                    ExampleMenuPicker(
                        data: DynamicTypeSize.allCases,
                        selection: $dynamicSize
                    ){ type in
                        Text("\(type)".splitCamelCaseFormat)
                    } label: {
                        Text("Dynamic Type")
                    }
                }
                
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
        
        @Binding var resource: FontResource
        
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
            Picker(selection: $resource){
                Section("Design"){
                    ForEach(Font.Design.allCases){
                        Text(name(for: $0))
                            .tag(FontResource.system(design: $0))
                    }
                }
                
                Section("Library"){
                    ForEach(AvailableFont.fontFamilies, id: \.self){
                        Text($0)
                            .tag(FontResource.library(familyName: $0))
                    }
                }
            } label: {
                EmptyView()
            }
        }
    }
    
    struct FontParameterSlider: View {
        
        @Environment(\.interactionGranularity) private var interactionGranularity
        
        @Binding var value: Double
        
        private var height: CGFloat {
            50 - (interactionGranularity * 28)
        }
        
        var body: some View {
            SliderView(
                x: .init($value, in: -1...1, step: 0.1),
                hitTestHandle: false
            ){
                SunkenControlMaterial(Capsule(), isTinted: true)
                    .scaleEffect(y: -1)
                    .frame(width: 17)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
            }
            .background {
                HStack(spacing: 2) {
                    ForEach(0...20){ i in
                        RoundedRectangle(cornerRadius: 8)
                            .opacity(i == 10 ? 1 : i.isMultiple(of: 5) ? 0.9 : 0.2)
                    }
                }
                .padding(.vertical, 5)
            }
            .frame(height: height)
            .buttonStyle(.tinted)
            .animation(.bouncy, value: value)
        }
    }
    
    struct ParameterEditor: View {
        
        @Binding var parameters: FontParameters
        
        var body: some View {
            ExampleSlider(
                value: .init($parameters.size, in: 10...120, step: 1)
            ){
                Label("Size", systemImage: "character.cursor.ibeam")
            }
            .symbolRenderingMode(.hierarchical)
          
            VStack(spacing: 5) {
                HStack {
                    Text("Width")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(Font.Width(parameters.width).staticDefinedClosest.description)
                        .opacity(0.6)
                }
                .animation(nil, value: parameters.width)
                
                FontParameterSlider(value: $parameters.width)
            }
            
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

            VStack(spacing: 5) {
                HStack {
                    Text("Weight")
                        .font(.exampleParameterTitle)
                    
                    Text(Font.Weight(closestToValue: parameters.weight).value, format: .number)
                        .font(.exampleParameterValue)
                    
                    Spacer()
                    
                    Text(verbatim: "\(Font.Weight(closestToValue: parameters.weight))")
                        .opacity(0.6)
                }
                .animation(nil, value: parameters.weight)
                
                FontParameterSlider(value: $parameters.weight)
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
        
        @Binding var resource: FontResource
        @Binding var parameters: FontParameters
        let dynamicSize: DynamicTypeSize
        
        var body: some View {
            Color.clear.overlay{
                switch mode {
                case .chars:
                    Chars()
                case .text:
                    SwiftUI.TextField("Example Text", text: $sample)
                        .multilineTextAlignment(.center)
                        .resolveFont()
                        .padding(.horizontal)
                        .textFieldStyle(.plain)
                        .transition(.scale(0.5) + .opacity)
                case .paragraph:
                    Text("The quick brown fox jumps over the lazy dog.")
                        .multilineTextAlignment(.center)
                        .resolveFont()
                        .padding(.horizontal)
                        .transition(.scale(0.5) + .opacity)
                }
            }
            .animation(.smooth, value: parameters)
            .presentationContext()
            .dynamicTypeSize(dynamicSize)
            .safeAreaInset(edge: .bottom, spacing: 0){
                HStack(spacing: 0) {
                    ResourcePicker(resource: $resource)
                    
                    Spacer(minLength: 10)
                    
                    HStack {
                        SegmentedPicker(
                            selection: $mode.animation(.smooth),
                            items: Mode.allCases
                        ){ m in
                            switch m {
                            case .chars: Image(systemName: "abc")
                            case .text: Image(systemName: "character.cursor.ibeam")
                            case .paragraph: Image(systemName: "paragraph")
                            }
                        }
                        .controlRoundness(1)
                        .frame(width: 140)
                        
                        Button{ parameters = .identity } label: {
                            Label("Reset", systemImage: "arrow.clockwise")
                        }
                        .font(.title[.bold])
                        .labelStyle(.iconOnly)
                        .symbolRenderingMode(.hierarchical)
                        .disabled(parameters == .identity)
                    }
                }
                .buttonStyle(.bar)
                .padding()
                .background{
                    Rectangle()
                        .fill(.background)
                        .mask {
                            LinearGradient(
                                colors: [
                                    .white.opacity(0), .white.opacity(0.9), .white
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .ignoresSafeArea()
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
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
                        Text(LocalizedStringKey(key.splitCamelCaseFormat))
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
                            .lineLimit(5)
                            //.fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }

        var body: some View {
            ExampleSection("Info", isExpanded: false) {
                Info(info: resolved.info)
            }
           
            ExampleSection("Metrics", isExpanded: false) {
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
                        }
                        
                        if let url = info.vendorURL {
                            if info.licenseURL != nil {
                                Text("•")
                                    .opacity(0.3)
                            }
                            
                            Button("Vendor"){ openURL(url) }
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
        
        @Environment(\.resolvedFont) private var resolved
        
        private var set: CharacterSet {
            let candidate = resolved.supportedCharacters
            return candidate.isEmpty ? .alphanumerics.union(.punctuationCharacters).union(.symbols) : candidate
        }
        
        @State private var chars: [Character] = []
        @State private var isLoading: Bool = false
        
        private func load() {
            isLoading = true
            let set = set
            Task.detached {
                var result: [Character] = []
                
                for i in 0x00000 ... 0xfffff {
                    if let s = UnicodeScalar(i), set.contains(s) {
                        let ch = Character(s)
                        if !ch.isWhitespace {
                            result.append(Character(s))
                        }
                    }
                }
                
                await MainActor.run {
                    self.chars = result
                    self.isLoading = false
                }
            }
        }
        
        struct Cell: View {
            
            @State private var isPresented = false
            @State private var matching = false
            
            let c: Character
            
            var body: some View {
                Button{ isPresented = true } label: {
                    InnerView(c: c, size: 24)
                        .presentationMatch(c, active: matching)
                }
                .presentation(isPresented: $isPresented){
                    InnerView(c: c, size: 250)
                        .presentationMatch(c)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.background)
                        }
                        .onTapGesture { isPresented = false }
                        .ignoresSafeArea()
                        .transition(.opacity.animation(.easeOut))
                        .presentationBackdrop(.disabled)
                        .onAppear{ matching = true }
                        .onDisappear{ matching = false }
                }
            }
            
            struct InnerView: View {
                
                @Environment(\.fontParameters) private var params
                
                let c: Character
                let size: Double
                
                var body: some View {
                    Text(String(c))
                        .font(params.copy(replacing: \.size, with: size))
                }
            }
        }
        
        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width
                let columns: Double = floor(width < 320 ? 5 : 8)
                let tileSize = width / columns
                let rows = Int(ceil(Double(chars.count) / columns))
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0){
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: 0){
                                ForEach(0..<Int(columns), id: \.self) { col in
                                    let index = row * Int(columns) + col
                                    ZStack {
                                        if chars.indices.contains(index) {
                                            let char = chars[index]
                                            Cell(c: char).id(char)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                    .frame(width: tileSize, height: tileSize)
                                }
                            }
                            .frame(height: tileSize)
                            .transition(.scale.animation(.smooth))
                        }
                    }
                    #if os(macOS)
                    .padding(.bottom, 14) // Removes weird dead zone on macOS. Probably has to do with hidden scroll bar not removing its event tracker.
                    #endif
                }
                .opacity(isLoading ? 0.1 : 1)
                .overlay {
                    if isLoading {
                        LoadingCircle(state: .indefinite)
                            .frame(width: 50, height: 50)
                            .transition((.scale(0.6) + .opacity).animation(.smooth))
                    }
                }
            }
            .buttonStyle(.plain)
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
