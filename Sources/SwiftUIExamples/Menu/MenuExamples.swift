import SwiftUIKit


public struct MenuExamples: View {
    
    @State private var selection = "Option B"
    
    public init() {}
    
    @ViewBuilder private var menuContent: some View {
        Menu(
            label: { Text("Item 1").paddingAddingMenuItemInsets() },
            content: {
                Button(action: { print("A") }){
                    Text("A Item")
                        .paddingAddingMenuItemInsets()
                }
            }
        )
        
        MenuDivider()
        
        Menu(label: { Text("Options").paddingAddingMenuItemInsets() }){
            MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
                Text($0)
            }
        }
        
        MenuDivider()
        
        Label("Item 3", systemImage: "3.circle.fill")
        
        MenuDivider()
        
        Button(action: {}){
            Label("Item 4", systemImage: "4.circle.fill")
        }
    }
    
    public var body: some View {
        VStack(spacing: 0){
            ScrollView{
                VStack {
                    ForEach(0..<30){ i in
                        HStack {
                            Spacer()
                            
                            ExampleCard(title: "SwiftUI"){
                                SwiftUI.Menu{
                                    menuContent
                                    
                                    MenuGroupDivider()
                                    
                                    MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
                                        Text($0)
                                    }
                                } label: {
                                    Text("Menu")
                                }
                            }
                            
                            ExampleCard(title: "SwiftUI Kit"){
                                Menu{
                                    menuContent
                                    
                                    MenuGroupDivider()
                                    
                                    MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
                                        Text($0)
                                    }
                                } label: {
                                    Text("Menu")
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Menu")
                .padding()
        }
        .menuBackground{
            VisualEffectView(blurRadius: 15)
            LinearGradient(colors: [.white, .white, .clear], startPoint: .top, endPoint: .bottom)
        }
        .anchorPresentationContext()
    }
    
}


#Preview("Menu") {
    MenuExamples()
        //.environment(\.layoutDirection, .rightToLeft)
}
