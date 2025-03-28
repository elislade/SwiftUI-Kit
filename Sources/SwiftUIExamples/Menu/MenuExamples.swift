import SwiftUIKit


public struct MenuExamples: View {
    
    @State private var selection = "Option B"
    
    public init() {}
    
    @ViewBuilder private var menuContent: some View {
        Menu(
            label: { Text("Item 1") },
            content: {
                Button(action: { print("A") }){
                    Text("A Item")
                        .equalInsetItem()
                }
            }
        )
        
        MenuDivider()
        
        Menu(label: { Text("Options") }){
            MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
                Text($0)
            }
        }
        
        MenuDivider()
        
        Label("Item 3", systemImage: "3.circle.fill")
        
        MenuDivider()
        
        Button(action: { print("Four") }){
            Label("Item 4", systemImage: "4.circle.fill")
        }
        
        MenuGroupDivider()

        MenuPicker(selection: $selection, data: ["Option A", "Option B", "Option C"]){
            Text($0)
        }
    }
    
    public var body: some View {
        VStack(spacing: 0){
            ScrollView{
                VStack {
                    ForEach(0..<20){ i in
                        HStack {
                            Spacer()
                            
                            #if !os(tvOS) && !os(watchOS)
                            ExampleCard(title: "SwiftUI"){
                                SwiftUI.Menu{
                                    menuContent
                                } label: {
                                    Text("Menu")
                                }
                            }
                            #endif
                            
                            ExampleCard(title: "SwiftUI Kit"){
                                Menu {
                                    menuContent
                                } label: {
                                    Text("Menu")
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Menu")
                .padding()
        }
        .anchorPresentationContext()
    }
    
}


#Preview("Menu") {
    MenuExamples()
        .previewSize()
}
