import SwiftUIKit


public struct InlineEnvironmentValuesReaderExample: View {
    
    @State private var colorScheme: ColorScheme = .light
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            InlineEnvironmentValuesReader { values in
                Rectangle()
                    .fill(.background)
                    .ignoresSafeArea()
                    .overlay{
                        Text("\(values.colorScheme)")
                            .font(.largeTitle.bold())
                    }
            }
            .environment(\.colorScheme, colorScheme)
            
            Divider()
            
            ExampleTitle("Environment Values")
                .padding(.vertical)
            
            ExampleCell.ColorScheme(value: $colorScheme)
        }
    }
}


#Preview("Environment Values Reader") {
    InlineEnvironmentValuesReaderExample()
        .previewSize()
}

public struct InlineEnvironmentReaderExample: View {
    
    public init() {}
    
    public var body: some View {
        InlineEnvironmentReader(\.displayScale){ scale in
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    
                    Text("Display Scale ").foregroundColor(.gray) + Text(scale, format: .number)
                }
                .font(.title.bold())
                .background(.bar)
                
                Divider().ignoresSafeArea()
                
                ExampleTitle("Inline Environment Reader")
                    .padding(.vertical)
            }
        }
    }
    
}


#Preview("Inline Environment Reader") {
    InlineEnvironmentReaderExample()
        .previewSize()
}



public struct EnvironmentOnChangeExample : View {
    
    struct Pair: Identifiable {
        public var id: String { key + value }
        
        let key: String
        let value: String
    }
    
    @State private var parsed = [Pair]()
    @State private var filter: String = ""
    
    @State private var colorScheme: ColorScheme = .light
    @State private var reduceMotion = false
    @State private var layout: LayoutDirection = .leftToRight
    
    private var filterdValues:  [Pair] {
        guard filter.isEmpty == false else { return parsed }
        return parsed.filter({ $0.key.lowercased().contains(filter.lowercased())})
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Environment On Change"){
            ScrollView {
                VStack(spacing: 0){
                    ForEach(filterdValues) { pair in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(pair.key)
                                .font(.body.weight(.semibold)).opacity(0.5)
                            
                            Text(pair.value)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .transitions(.scale(0.8), .opacity)
                        
                        Divider()
                    }
                }
                .animation(.smooth, value: filterdValues.indices)
            }
            .onEnvironmentValuesChanged {
                let items = $0.description.dropFirst().dropLast()
                let pairs = items.split(separator: ",")
                parsed = []
                for pair in pairs {
                    let keyValue = pair.split(separator: "=", maxSplits: 1)
                    if keyValue.count == 2 {
                        let key = String(keyValue[0])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "EnvironmentPropertyKey", with: "")
                        
                        let value = String(keyValue[1]).trimmingCharacters(in: .whitespaces)
                        parsed.append(Pair(key: key, value: value))
                    }
                }
            }
            .environment(\.colorScheme, colorScheme)
            .preferredColorScheme(colorScheme)
            .environment(\.layoutDirection, layout)
            .environment(\.reduceMotion, reduceMotion)
        } parameters: {
            TextField("Filter Keys", text: $filter){
                Image(systemName: "magnifyingglass")
                    .allowsHitTesting(false)
                    .font(.exampleParameterValue)
            }
            .textFieldStyle(.plain)
            .font(.exampleParameterTitle)
            .padding()
            
            Divider()
            
            ExampleCell.ColorScheme(value: $colorScheme)
            
            Divider()
            
            Toggle(isOn: $reduceMotion) {
                Text("Reduce Motion")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $layout)
            
            Divider()
        }
    }
    
}


#Preview("Environment On Change") {
    EnvironmentOnChangeExample()
        .previewSize()
}
