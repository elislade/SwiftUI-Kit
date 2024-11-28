import SwiftUIKit


struct MenuExamples: View {
    
    @State private var selection = "Option B"
    
    @ViewBuilder private var menuContent: some View {
        Menu(
            label: { Text("Item 1").applyMenuItemInsets() },
            content: {
                Button(action: { print("A") }){
                    Text("A Item")
                        .applyMenuItemInsets()
                }
            }
        )
        
        MenuDivider()
        
        Menu(label: { Text("Options").applyMenuItemInsets() }){
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
    
    
    var body: some View {
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
        .menuBackground{
            VisualEffectView(blurRadius: 15)
            LinearGradient(colors: [.white, .white, .clear], startPoint: .top, endPoint: .bottom)
        }
        .anchorPresentationContext()
        .coordinatedWindowEvents()
    }
    
}


#Preview("Menu") {
    MenuExamples()
        //.environment(\.layoutDirection, .rightToLeft)
}
