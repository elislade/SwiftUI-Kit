import SwiftUIKit


#if canImport(UIKit) && !os(visionOS) && !os(tvOS)

//TODO: Depricate BarMasks as iOS 15 is no longer suported so `toolbarColorScheme` can be used.
struct SystemUIOverrideExamples: View {
    
    @State private var color: ColorScheme = .dark
    @State private var showAlert = false
    @State private var mask: SystemUIMask = .bars
    
    private func view(_ label: LocalizedStringKey, for mask: SystemUIMask) -> some View {
        Toggle(isOn: Binding($mask, contains: mask)){
            Text(label)
        }
    }
    
    
    var body: some View {
        ExampleView(title: "System Overrides"){
            TabView {
                NavigationView {
                    ScrollView {
                        LinearGradient(
                            colors: [.red, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 1200)
                    }
                    .ignoresSafeArea()
                    .navigationTitle("Title")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .automatic){
                            Button("Show Alert"){ showAlert.toggle() }
                        }
                    }
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Alert Title"))
                    }
                    
                }
                .tabItem {
                    Text("TabBar Item")
                    Image(systemName: "a.circle")
                }
            }
            .overrideColorScheme(color, uiMask: mask)
        } parameters: {
            ExampleCell.ColorScheme(value: $color)

            ExampleSection(isExpanded: true){
                view("Status Bar", for: .sceneStatusbar)
                view("Tab Bar", for: .tabbar)
                view("Tool Bar", for: .bottomToolbar)
                view("Navigation Bar", for: .navigationTitlebar)
                view("Alert", for: .alert)
            } label: {
                Text("UI Mask")
            }
        }
    }
    
}


#Preview("SystemUI Override") {
    SystemUIOverrideExamples()
}


#endif
