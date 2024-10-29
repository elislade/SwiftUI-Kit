import SwiftUIKit


#if canImport(UIKit) && !os(visionOS)

struct SystemUIOverrideExamples: View {
    
    @State private var color: ColorScheme = .dark
    @State private var showAlert = false
    @State private var mask: SystemUIMask = .bars
    
    private func view(_ label: String, for mask: SystemUIMask) -> some View {
         Toggle(isOn: .init(
            get: { self.mask.contains(mask) },
            set: {
                if $0 {
                    self.mask.insert(mask)
                } else {
                    self.mask.remove(mask)
                }
            }
        )){
            Text(label)
                .font(.exampleParameterTitle)
        }
        .padding()
    }
    
    
    var body: some View {
        ExampleView(title: "System Overrides"){
            TabView {
                NavigationView {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                Color.white
                                Color.secondary.id("Target")
                                Color.black
                            }
                            .frame(height: 1200)
                            .onAppear{
                                proxy.scrollTo("Target", anchor: .center)
                            }
                        }
                        .ignoresSafeArea()
                    }
                    .navigationTitle("Test")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar){
                            Button("Show Alert"){ showAlert.toggle() }
                        }
                    }
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("What?!?"))
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
            
            Divider()
            
            view("Status Bar", for: .sceneStatusbar)
            Divider()
            
            view("Tab Bar", for: .tabbar)
            Divider()
            
            view("Tool Bar", for: .bottomToolbar)
            Divider()
            
            view("Navigation Bar", for: .navigationTitlebar)
            Divider()
            
            view("Alert", for: .alert)
        }
    }
    
}


#Preview("SystemUI Override") {
    SystemUIOverrideExamples()
}


#endif
