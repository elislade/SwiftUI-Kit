import SwiftUI

#if canImport(UIKit) && !os(visionOS)

struct SystemUIOverrideModifier: ViewModifier {
    
    let mask: SystemUIMask
    let scheme: ColorScheme
    
    @State private var viewIdentity = false
    
    private func update() {
        
        // If false it means that the bundle has declared to use legacy UIApplication based status bar styling.
        if Bundle.main.usesViewControllerStatusBarStyle == false {
            if mask.contains(.sceneStatusbar) {
                switch scheme {
                case .light: UIApplication.shared.statusBarStyle = .lightContent
                case .dark: UIApplication.shared.statusBarStyle = .darkContent
                @unknown default: print("NAN")
                }
            } else {
                UIApplication.shared.statusBarStyle = .default
            }
        }
        
        let interfaceStyle = UIUserInterfaceStyle(scheme)
        var affectedContainers: [UIAppearanceContainer.Type] = []
        var unaffectedContainers: [UIAppearanceContainer.Type] = []
        
        if mask.contains(.navigationTitlebar) {
            affectedContainers.append(UINavigationBar.self)
        } else {
            unaffectedContainers.append(UINavigationBar.self)
        }
        
        if mask.contains(.bottomToolbar) {
            affectedContainers.append(UIToolbar.self)
        } else {
            unaffectedContainers.append(UIToolbar.self)
        }
        
        if mask.contains(.alert) {
            affectedContainers.append(UIAlertController.self)
        } else {
            unaffectedContainers.append(UIAlertController.self)
        }
        
        if mask.contains(.tabbar) {
            affectedContainers.append(UITabBar.self)
            //UITabBar.appearance().overrideUserInterfaceStyle = interfaceStyle
        } else {
            unaffectedContainers.append(UITabBar.self)
        }
        
        UIVisualEffectView.appearance().overrideUserInterfaceStyle = mask.contains(.visualEffect) ? interfaceStyle : .unspecified
        
        for container in affectedContainers {
            UIView.appearance(whenContainedInInstancesOf: [container]).overrideUserInterfaceStyle = interfaceStyle
        }
        
        for container in unaffectedContainers {
            UIView.appearance(whenContainedInInstancesOf: [container]).overrideUserInterfaceStyle = .unspecified
        }
        
        viewIdentity.toggle()
    }
    
    
    func body(content: Content) -> some View {
        content
            .id(viewIdentity)
            .onChangePolyfill(of: (scheme.hashValue + Int(mask.rawValue)), initial: true){
                update()
            }
            .background {
                if Bundle.main.usesViewControllerStatusBarStyle {
                    StatusBarRepresentable(scheme: mask.contains(.sceneStatusbar) ? scheme : nil) {
                        Color.clear
                    }
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }
            }
            
    }
    
}


#endif
