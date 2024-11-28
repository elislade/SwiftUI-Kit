import SwiftUIKit

public struct KeyPressExample: View {
    
    public init(){}
    
    enum MaskType: Hashable {
        case none
        case chars
        case equivalance
    }
    
    @State private var presses: [KeyPress] = []
    @State private var keys: Set<KeyEquivalent> = [.clear]
    @State private var characters: CharacterSet = .alphanumerics
    @State private var phase: KeyPress.Phases = [.down]
    @State private var mask: MaskType = .none
    
    @State private var string = ""
    @FocusState private var focus: Bool
    
    private func binding(for phases: KeyPress.Phases) -> Binding<Bool> {
        .init(
            get: { self.phase.contains(phases) },
            set: {
                if $0 {
                    self.phase.formUnion(phases)
                } else {
                    self.phase.remove(phases)
                }
            }
        )
    }
    
    private func binding(for key: KeyEquivalent) -> Binding<Bool> {
        .init(
            get: { self.keys.contains(key) },
            set: {
                if $0 {
                    self.keys.insert(key)
                } else {
                    self.keys.remove(key)
                }
            }
        )
    }
    
    private func handlePress(_ press: KeyPress) -> KeyPress.Result {
        presses.append(press)
        
        if press.key == .delete {
            if self.string.isEmpty {
                return .ignored
            }
            self.string.removeLast()
        } else {
            if press.modifiers.contains(.shift) || press.modifiers.contains(.capsLock) {
                self.string.append(press.characters.uppercased())
            } else {
                self.string.append(press.characters)
            }
        }
        
        return .handled
    }
    
    public var body: some View {
        ExampleView(title: "KeyPress"){
            VStack(spacing: 0) {
                Group {
                    switch mask {
                    case .none:
                        Text(string)
                            .onKeyPressPolyfill(
                                phases: phase,
                                action: handlePress(_:)
                            )
                    case .chars:
                        Text(string)
                            .onKeyPressPolyfill(
                                characters: characters,
                                phases: phase,
                                action: handlePress(_:)
                            )
                    case .equivalance:
                        Text(string)
                            .onKeyPressPolyfill(
                                keys: keys,
                                phases: phase,
                                action: handlePress(_:)
                            )
                    }
                }
                .padding()
                .font(.largeTitle[.bold])
                
                Divider().ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 1)
                            
                            ForEach(presses.indices, id: \.self){ i in
                                PressView(press: presses[i])
                                    .padding()
                                    .id(i)
                                    .transitions(.move(edge: .bottom))
                                
                                Divider().ignoresSafeArea()
                            }
                        }
                    }
                    .onChangePolyfill(of: presses.indices){
                        withAnimation(.fastSpringInteractive){
                            proxy.scrollTo(presses.indices.last)
                        }
                    }
                }
            }
            .animation(.interactiveSpring(blendDuration: 0.1), value: presses.indices)
        } parameters: {
            ExampleSection("Phases", isExpanded: true){
                Toggle(isOn: binding(for: .up)) {
                    Text("Up").font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
                
                Toggle(isOn: binding(for: .down)) {
                    Text("Down").font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
                
                Toggle(isOn: binding(for: .repeat)) {
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
                        Text("Key Equivilence").tag(MaskType.equivalance)
                    }
                }
                .padding()
                
                Divider()
                
                switch mask {
                case .none:
                    EmptyView()
                case .chars:
                    HStack {
                        Text("Character Set").font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Picker("", selection: $characters){
                            Text("Alpha Numerics").tag(CharacterSet.alphanumerics)
                            Text("Symbols").tag(CharacterSet.symbols)
                            Text("Decimal Digits").tag(CharacterSet.decimalDigits)
                        }
                    }
                    .padding()
                case .equivalance:
                    Toggle(isOn: binding(for: .clear)) {
                        Text("Clear").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .delete)) {
                        Text("Delete").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .deleteForward)) {
                        Text("Delete Forward").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .escape)) {
                        Text("Escape").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .end)) {
                        Text("End").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .pageUp)) {
                        Text("Page Up").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .pageDown)) {
                        Text("Page Down").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .upArrow)) {
                        Text("Up Arrow").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .downArrow)) {
                        Text("Dow Arrow").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .leftArrow)) {
                        Text("Left Arrow").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: binding(for: .rightArrow)) {
                        Text("Right Arrow").font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                }
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
            .lineLimit(1)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.hierarchical)
        }
        
        
        struct KeyEquivalentView : View {
            let key: KeyEquivalent
            
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
                    Label("Clear", systemImage: "clear")
                } else if key == .space {
                    Label("Space", systemImage: "space")
                } else if key == .leftArrow {
                    Label("Left Arrow", systemImage: "arrowtriangle.left")
                } else if key == .upArrow {
                    Label("Up Arrow", systemImage: "arrowtriangle.up")
                } else if key == .rightArrow {
                    Label("Right Arrow", systemImage: "arrowtriangle.right")
                } else if key == .downArrow {
                    Label("Down Arrow", systemImage: "arrowtriangle.down")
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
}


#Preview("Key Press") {
    KeyPressExample()
}
