import SwiftUI
import SwiftUICore


public struct MenuPicker<V: Hashable, Data: RandomAccessCollection, Label: View>: View where Data.Element == V {
    
    @Environment(\.isInMenu) private var isInMenu
    
    @Binding var selection: V
    let data: Data
    @ViewBuilder let label: (Data.Element) -> Label
    
    public init(selection: Binding<V>, data: Data, @ViewBuilder label: @escaping (Data.Element) -> Label) {
        self._selection = selection
        self.data = data
        self.label = label
    }
    
    private func binding(for element: Data.Element) -> Binding<Bool> {
        .init(
            get: { selection == element },
            set: { _ in
                selection = element
            }
        )
    }
    
    public var body: some View {
        if isInMenu {
            VStack(spacing: 0){
                ForEach(data, id: \.self){ i in
                    Toggle(isOn: binding(for: i)){
                        label(i)
                    }
                    
                    if i != data.last {
                        Divider()
                    }
                }
                
            }
            .toggleStyle(MenuToggleStyle())
        } else {
            Picker("", selection: $selection){
                ForEach(data, id: \.self){
                    label($0).tag($0)
                }
            }
        }
    }
    
}


#Preview {
    InlineBinding("A"){ binding in
        MenuContainer{
            MenuPicker(selection: binding, data: ["A", "B", "C"]){ ele in
                Text(ele)
            }
        }
        .padding()
    }
    .coordinatedWindowEvents()
}
