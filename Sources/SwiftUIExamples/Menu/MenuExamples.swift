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
        ZStack {
            Color.clear
            
            VStack {
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
                    Menu(label: { Text("Menu") }){
                        menuContent
                        
                        MenuGroupDivider()
                        
                        MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
                            Text($0)
                        }
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
