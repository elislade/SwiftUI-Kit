import SwiftUI


public struct InlineAppStorage<Value : Codable & Equatable, Content: View>  {
    
    let value: State<Value>
    let storage: AppStorage<Data?>
    let content: (Binding<Value>) -> Content
    
    public nonisolated init(
        _ key: String,
        initial: Value,
        store: UserDefaults? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        let sotrageData = AppStorage<Data?>(key, store: store)
        if let data = sotrageData.wrappedValue, let decoded = try? JSONDecoder().decode(Value.self, from: data) {
            self.value = .init(initialValue: decoded)
        } else {
            self.value = .init(initialValue: initial)
        }
        self.storage = sotrageData
        self.content = content
    }
    
}


extension InlineAppStorage: View {
    
    public var body: some View {
        content(value.projectedValue)
            .onChangePolyfill(of: value.wrappedValue){
                storage.wrappedValue = try? JSONEncoder().encode(value.wrappedValue)
            }
    }
    
}
