import SwiftUIKit


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
            .exampleParameterCell()
            
            ExampleCell.ColorScheme(value: $colorScheme)
            
            Toggle(isOn: $reduceMotion) {
                Text("Reduce Motion")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirection(value: $layout)
        }
    }
    
}


#Preview("Environment On Change") {
    EnvironmentOnChangeExample()
        .previewSize()
}
