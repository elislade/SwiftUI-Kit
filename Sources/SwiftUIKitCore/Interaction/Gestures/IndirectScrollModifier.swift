import SwiftUI


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

final class IndirectScrollView<Source: View> : NSHostingView<Source> {
    
    var gesture: IndirectScrollGesture?
    
    required init(rootView: Source) {
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let gesture, event.type == .scrollWheel else { return }
        
        if gesture.useMomentum {
            if event.phase == .began || event.phase == .changed || event.momentumPhase == .changed {
                gesture.callChanged(with: .init(event))
            } else if (event.phase == .ended && event.momentumPhase.rawValue == 0) || event.momentumPhase == .ended {
                gesture.callEnded(with: .init(event))
            }
        } else {
            if event.phase == .began || event.phase == .changed {
                gesture.callChanged(with: .init(event))
            } else if event.phase == .ended {
                gesture.callEnded(with: .init(event))
            }
        }
    }
    
}


extension IndirectScrollGesture.Value {
    
    init(_ event: NSEvent) {
        self.time = event.timestamp
        self.deltaX = event.scrollingDeltaX
        self.deltaY = event.scrollingDeltaY
    }
    
}

struct IndirectScrollRepresentation<Source: View>: NSViewRepresentable {
    
    let gesture: IndirectScrollGesture
    let content: () -> Source
    
    func makeNSView(context: Context) -> IndirectScrollView<Source> {
        let view = IndirectScrollView(rootView: content())
        view.gesture = gesture
        return view
    }
    
    func updateNSView(_ nsView: IndirectScrollView<Source>, context: Context) {
        nsView.gesture = gesture
    }
    
}

#elseif canImport(UIKit)

import UIKit
    
final class IndirectScrollView: UIView {
    
    var gesture: IndirectScrollGesture?
    
    init(gesture: IndirectScrollGesture? = nil) {
        self.gesture = gesture
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("B", event)
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("C", event)
//    }
//    
//    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        print("P", event)
//    }
//    
//    override func remoteControlReceived(with event: UIEvent?) {
//        print("Remote", event)
//    }
    
}

struct IndirectScrollRepresentation: UIViewRepresentable {
    
    let gesture: IndirectScrollGesture
    
    func makeUIView(context: Context) -> IndirectScrollView {
        let panelView = IndirectScrollView()
        panelView.gesture = gesture
        return panelView
    }
    
    func updateUIView(_ uiView: IndirectScrollView, context: Context) {
        uiView.gesture = gesture
    }
    
}
#endif


public protocol IndirectGesture {
    associatedtype Value
    
    func onChanged(_ action: @escaping (Value) -> Void) -> Self
    func onEnded(_ action: @escaping (Value) -> Void) -> Self
}

public struct IndirectScrollGesture: IndirectGesture {
    
    public let useMomentum: Bool
    private var onChanges: [(Value) -> Void]
    private var onEnds: [(Value) -> Void]
    
    public init(useMomentum: Bool = true){
        self.useMomentum = useMomentum
        self.onChanges = []
        self.onEnds = []
    }
    
    public struct Value: Hashable {
        public let time: Double
        public let deltaX: Double
        public let deltaY: Double
    }
    
    public func onChanged(_ action: @escaping (Value) -> Void) -> IndirectScrollGesture {
        var copy = self
        copy.onChanges.append(action)
        return copy
    }
    
    public func onEnded(_ action: @escaping (Value) -> Void) -> IndirectScrollGesture {
        var copy = self
        copy.onEnds.append(action)
        return copy
    }
    
    internal func callChanged(with value: Value){
        for call in onChanges {
            call(value)
        }
    }
    
    internal func callEnded(with value: Value){
        for call in onEnds {
            call(value)
        }
    }
    
}

struct IndirectScrollModifier: ViewModifier {
    
    var gesture: IndirectScrollGesture
    
    func body(content: Content) -> some View {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        IndirectScrollRepresentation(gesture: gesture){
            content
        }
        #else
        content
            //.overlay{ IndirectScrollRepresentation(gesture: gesture) }
        #endif
    }
    
}


public extension View {
    
    /// A gesture that is not directly inputed on the users screen. Eg. trackpad or mouse scroll.
    
    @ViewBuilder func indirectGesture<Gesture: IndirectGesture>(_ gesture: Gesture) -> some View {
        if let gesture = gesture as? IndirectScrollGesture {
            modifier(IndirectScrollModifier(gesture: gesture))
        } else {
            self
        }
    }
    
}


#Preview {
    InlineBinding(CGPoint.zero){ value in
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            
            RoundedRectangle(cornerRadius: 30)
                .fill(.gray)
                .offset(x: value.wrappedValue.x, y: value.wrappedValue.y)
                .padding()
        }
        .indirectGesture(
            IndirectScrollGesture(useMomentum: false)
                .onChanged { g in
                    value.x.wrappedValue += g.deltaX
                    value.y.wrappedValue += g.deltaY
                }
                .onEnded { g in
                    withAnimation(.snappy){
                        value.wrappedValue = .zero
                    }
                }
        )
    }
}
