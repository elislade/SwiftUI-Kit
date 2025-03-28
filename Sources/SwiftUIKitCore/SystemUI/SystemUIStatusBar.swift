import SwiftUI


#if canImport(UIKit) && !os(visionOS) && !os(watchOS) && !os(tvOS)


struct StatusBarRepresentable<Source: View>: UIViewControllerRepresentable {
    
    let scheme: ColorScheme?
    @ViewBuilder let source: Source
    
    func sync(ctrl: CustomHostingController<Source>) {
        if let scheme {
            switch scheme {
            case .light: ctrl.wantsStatusBarStyle = .lightContent
            case .dark: ctrl.wantsStatusBarStyle = .darkContent
            @unknown default:
                return
            }
        } else {
            ctrl.wantsStatusBarStyle = .default
        }
    }
    
    func makeUIViewController(context: Context) -> CustomHostingController<Source> {
        let c = CustomHostingController(rootView: source)
        c.view.backgroundColor = .clear
        sync(ctrl: c)
        return c
    }
    
    func updateUIViewController(_ uiViewController: CustomHostingController<Source>, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}

class CustomHostingController<Source: View> : UIHostingController<Source> {
    
    override var childForStatusBarStyle: UIViewController? { nil }
    
    var wantsStatusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        wantsStatusBarStyle
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
    }
    
}


extension Bundle {
    
    var usesViewControllerStatusBarStyle: Bool {
        guard let uses = infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool
        else {
            return true
        }
        
        return uses
    }
    
}

extension UIView {
    
    func getAppearancePath() -> [UIAppearanceContainer.Type] {
        var result = [UIAppearanceContainer.Type]()
        var parent: UIView? = superview
        while let p = parent {
            result.append(type(of: p))
            parent = p.superview
        }
        return result
    }
    
}

#endif
