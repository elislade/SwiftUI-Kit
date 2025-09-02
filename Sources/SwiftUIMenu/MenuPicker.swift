import SwiftUI
import SwiftUIKitCore


public struct MenuPicker<V: Hashable, Data: RandomAccessCollection, Label: View>: View where Data.Element == V {
    
    @Environment(\.menuStyle) private var style
    @Environment(\.isInMenu) private var isInMenu
    
    @Binding private var selection: V
    let data: Data
    @ViewBuilder private let label: @MainActor (Data.Element) -> Label
    
    public init(
        selection: Binding<V>,
        data: Data,
        @ViewBuilder label: @MainActor @escaping (Data.Element) -> Label
    ) {
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
            ForEach(data, id: \.self){ i in
                Toggle(isOn: binding(for: i)){
                    label(i)
                }
                
                if i != data.last {
                    MenuDivider()
                }
            }
            .toggleStyle(MenuToggleStyle(exclusivity: .exclusive))
            .actionTriggerBehaviour(.immediate)
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
            VStack(spacing: nil) {
                Image(systemName: "xbox.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 40)
                    .opacity(0.1)
                
                Text("Is this an XBox?")
                    .font(.system(.title2, design: .serif)[.bold])
                
                Text("Pick it now!!!")
                    .font(.system(.body, design: .serif).italic())
                    .opacity(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            
            MenuGroupDivider()
            
            MenuPicker(selection: binding, data: ["No", "Yes", "Everything is an xbox."]){ ele in
                Text(ele)
                    .font(.headline)
            }
        }
        .padding()
        .tint(.pink)
    }
}
