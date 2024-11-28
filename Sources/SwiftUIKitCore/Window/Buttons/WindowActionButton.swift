import SwiftUI


public struct WindowActionButton: View {
    
    public let action: WindowAction
    
    public init(_ action: WindowAction) {
        self.action = action
    }
    
    public var body: some View {
        switch action {
        case .close(let shouldQuit): WindowButtonClose(shouldQuit: shouldQuit)
        case .minimize: WindowButtonMinimize()
        case .fullscreen: WindowButtonZoom()
        case .zoom: WindowButtonZoom()
        case .translate: EmptyView()
        }
    }
    
}
