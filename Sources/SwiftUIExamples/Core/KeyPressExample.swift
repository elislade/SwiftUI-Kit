import SwiftUIKit

public struct KeyPressExample: View {
    
    public init(){}
    
    enum MaskType: Hashable {
        case none
        case chars
        case equivalence
    }
    
    @State private var presses: [KeyPress] = []
    @State private var keys: Set<KeyEquivalent> = [.return, .space]
    @State private var characters: CharacterSet = .alphanumerics
    @State private var phase: KeyPress.Phases = [.down]
    @State private var mask: MaskType = .none
    
    @State private var string = ""
    @FocusState private var focus: Bool
    
    private func handlePress(_ press: KeyPress) -> KeyPress.Result {
        presses.append(press)
        
        if press.key == .delete {
            if self.string.isEmpty {
                return .ignored
            }
            self.string.removeLast()
        } else if press.key.character.isASCII {
            self.string.append(press.key.character)
        }
        
        return .handled
    }
    
    public var body: some View {
        ExampleView(title: "KeyPress"){
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack {
                            Text(string)
                                .font(.largeTitle[.bold])
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Color.clear.frame(width: 1, height: 60)
                                .id("end")
                        }
                        .padding()
                    }
                    .onChangePolyfill(of: string){
                        proxy.scrollTo("end")
                    }
                }
                .background{
                    switch mask {
                    case .none:
                        Color.clear
                            .onKeyPressPolyfill(
                                phases: phase,
                                action: handlePress(_:)
                            )
                    case .chars:
                        Color.clear
                            .onKeyPressPolyfill(
                                characters: characters,
                                phases: phase,
                                action: handlePress(_:)
                            )
                    case .equivalence:
                        Color.clear
                            .onKeyPressPolyfill(
                                keys: keys,
                                phases: phase,
                                action: handlePress(_:)
                            )
                    }
                }
                
                Divider().ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 1)
                            
                            ForEach(presses.indices, id: \.self){ i in
                                PressView(press: presses[i])
                                    .padding()
                                    .id(i)
                                    .minimumScaleFactor(0.5)
                                    .transitions(.move(edge: .bottom))
                                
                                Divider().ignoresSafeArea()
                            }
                        }
                    }
                    .onChangePolyfill(of: presses.indices){
                        proxy.scrollTo(presses.indices.last)
                    }
                }
            }
        } parameters: {
            ExampleSection("Phases", isExpanded: true){
                Toggle(isOn: Binding($phase, contains: .up)) {
                    Text("Up").font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
                
                Toggle(isOn: Binding($phase, contains: .down)) {
                    Text("Down").font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
                
                Toggle(isOn: Binding($phase, contains: .repeat)) {
                    Text("Repeat").font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
            }
            
            ExampleSection("Input Mask", isExpanded: true){
                HStack {
                    Text("Type").font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $mask){
                        Text("None").tag(MaskType.none)
                        Text("Character Set").tag(MaskType.chars)
                        Text("Key Equivalence").tag(MaskType.equivalence)
                    }
                }
                .padding()
                
                Divider()
                
                switch mask {
                case .none:
                    EmptyView()
                case .chars:
                    CharacterSetMaskView(set: $characters)
                case .equivalence:
                    KeyEquivalentMaskView(keys: $keys)
                }
            }
            .symbolRenderingMode(.hierarchical)
        }
    }
    
    
    struct KeyEquivalentMaskView: View {
        
        @Binding var keys: Set<KeyEquivalent>
        
        private let keyOrder: [KeyEquivalent] = [
            .space, .return, .clear, .delete, .deleteForward, .tab,
            .escape, .leftArrow, .rightArrow, .upArrow, .downArrow,
            .home, .pageUp, .pageDown, .end
        ]
        
        var body: some View {
            ForEach(keyOrder, id: \.self){ key in
                Toggle(isOn: Binding($keys, contains: key)) {
                    KeyEquivalentView(key: key)
                        .font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
            }
        }
    }
    
    
    struct CharacterSetMaskView: View {
        
        @Binding var set: CharacterSet
        
        private let setOrder: [(name: String, set: CharacterSet)] = [
            ("Letters", .letters), ("Digits", .decimalDigits),
            ("Newlines", .newlines), ("Whitespace", .whitespaces),
            ("Punctuation", .punctuationCharacters)
        ]
        
        var body: some View {
            ForEach(setOrder, id: \.name){ item in
                Toggle(isOn: Binding($set, subset: item.set)) {
                    Text(item.name)
                        .font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
            }
        }
        
    }
    
    
    struct PressView: View {
        let press: KeyPress
        
        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text("Phase")
                        .font(.caption[.semibold])
                        .opacity(0.7)
                    
                    KeyPhaseView(phase: press.phase)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Key")
                        .font(.caption[.semibold])
                        .opacity(0.7)
                    
                    KeyEquivalentView(key: press.key)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !press.characters.isEmpty, CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: press.characters)) {
                    VStack(alignment: .leading) {
                        Text("Characters")
                            .font(.caption[.semibold])
                            .opacity(0.7)

                        Text(press.characters)
                            .font(.exampleParameterTitle)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !press.modifiers.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Modifiers")
                            .font(.caption[.semibold])
                            .opacity(0.7)
                        
                        KeyModifiersView(modifiers: press.modifiers)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .lineLimit(1)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.hierarchical)
        }
        
    }
    
    struct KeyEquivalentView : View {
        let key: KeyEquivalent
        
        private func arrow(_ direction: String) -> String {
            if #available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, watchOS 10, *) {
                "arrowkeys.\(direction).filled"
            } else {
                "arrowtriangle.\(direction).square.fill"
            }
        }
        
        var body: some View {
            if key == .delete {
                Label("Delete", systemImage: "delete.left.fill")
            } else if key == .deleteForward {
                Label("Delete(forward)", systemImage: "delete.right.fill")
            } else if key == .escape {
                Label("Escape", systemImage: "escape")
            } else if key == .return {
                Label("Return", systemImage: "return")
            } else if key == .clear {
                Label("Clear", systemImage: "clear.fill")
            } else if key == .space {
                Label("Space", systemImage: "space")
            } else if key == .leftArrow {
                Label("Left Arrow", systemImage: arrow("left"))
            } else if key == .upArrow {
                Label("Up Arrow", systemImage: arrow("up"))
            } else if key == .rightArrow {
                Label("Right Arrow", systemImage: arrow("right"))
            } else if key == .downArrow {
                Label("Down Arrow", systemImage: arrow("down"))
            } else if key == .pageUp {
                Label("Page Up", systemImage: "arrow.up.document.fill")
            } else if key == .pageDown {
                Label("Page Down", systemImage: "arrow.down.document.fill")
            } else if key == .end {
                Label("End", systemImage: "circle")
            } else if key == .home {
                Label("Home", systemImage: "house.fill")
            } else if key == .tab {
                Label("Tab", systemImage: "arrow.forward.to.line")
            } else {
                Text("\(key.character)")
            }
        }
        
    }
    
    
    struct KeyModifiersView : View {
        
        let modifiers: EventModifiers
        
        var body: some View {
            if modifiers.contains(.capsLock) {
                Label("Caps Lock", systemImage: "capslock.fill")
            }
            
            if modifiers.contains(.shift) {
                Label("Shift", systemImage: "shift.fill")
            }
            
            if modifiers.contains(.control) {
                Label("Control", systemImage: "control")
            }
            
            if modifiers.contains(.command) {
                Label("Command", systemImage: "command")
            }
            
            if modifiers.contains(.option) {
                Label("Option", systemImage: "option")
            }
            
            if modifiers.contains(.numericPad) {
                Label("Number Pad", systemImage: "number")
            }
            
            if modifiers.contains(.function) {
                Label("Function", systemImage: "f.cursive")
            }
        }
        
    }
    
    
    struct KeyPhaseView : View {
        
        let phase: KeyPress.Phases
        
        var body: some View {
            if phase.contains(.down) {
                Label("Down", systemImage: "arrow.down")
            }
            
            if phase.contains(.up) {
                Label("Up", systemImage: "arrow.up")
            }
            
            if phase.contains(.repeat) {
                Label("Repeat", systemImage: "repeat")
            }
        }
        
    }
}


#Preview("Key Press") {
    KeyPressExample()
        .previewSize()
}
