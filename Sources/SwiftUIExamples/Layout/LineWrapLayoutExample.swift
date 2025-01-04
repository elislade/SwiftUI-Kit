import SwiftUIKit


public struct LineWrapLayoutExample: View {
    
    @State private var phrases: [[IdentifiedChar]]
    
    private let images = ["globe.americas.fill", "tree.fill", "eyes.inverse"]
    
    private var imageName: String {
        let i = index % (images.count - 1)
        return images[i]
    }
    
    @Namespace private var ns
    @State private var spacing: Double = 0
    @State private var alignment: TextAlignment = .leading
    @State private var size: Double = 70
    @State private var groupByWhitespace: Bool = false
    @State private var showBorders: Bool = false
    @State private var index: Int = 0
    
    private var font: Font {
        .system(size: size, design: .serif)
    }
    
    public init(){
        phrases = [
           "Hello, World!",
           "Hollow woods are spooky.",
           "As a condition to exercising the rights granted by a Contributor to such Recipient under this Agreement will bring a legal entity exercising rights under this Agreement must be also Redistributed together with the provisions set forth herein. Relationship of Parties.",
           "This License represents the complete machine-readable source code, object code or executable form only, You must retain the above copyright notice, this list of all necessary servicing, repair, or correction."
        ].map{ $0.identifiedSequence() }
    }
    
    public var body: some View {
        ExampleView(title: "Line Wrap Layout"){
            Group{
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *), true {
                    LineWrapLayout(alignment: alignment, lineSpacing: spacing){
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .drawingGroup()
                            .id(imageName)
                            .mask{
                                LinearGradient(
                                    colors: [.black.opacity(0.6), .black.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .drawingGroup()
                            }
                            .border(showBorders ? Color.blue : .clear, width: 0.333)
                            .matchedGeometryEffect(id: "icon", in: ns)
                            .transition(
                                .merge(.scale, .opacity)
                                .animation(.bouncy(duration: 0.3))
                            )

                        LayoutNewLine()
                        
                        ForEach(phrases[index]){ char in
                            if char.isNewline {
                                LayoutNewLine()
                            } else {
                                Text("\(char)")
                                    .layoutSaparator(groupByWhitespace && (char.isWhitespace || char == "-"))
                                    .border(showBorders ? Color.blue : .clear, width: 0.333)
                                    .transition(
                                        .merge(.scale(0), .opacity)
                                        .animation(.bouncy)
                                    )
                            }
                        }
                    }
                } else {
                    Text(phrases[index].description)
                        .multilineTextAlignment(alignment)
                }
            }
            .font(font)
            .padding()
            .drawingGroup()
            .allowsHitTesting(false)
            .border(showBorders ? Color.red : .clear)
            .animation(.fastSpringInteractive, value: font)
            .animation(.smooth, value: index)
            .animation(.smooth, value: groupByWhitespace)
        } parameters: {
            HStack{
                Text("Content")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Group {
                    Button("Previous", systemImage: "arrow.left"){
                        if index == 0 {
                            index = phrases.count - 1
                        } else {
                            index -= 1
                        }
                    }
                    
                    Button("Next", systemImage: "arrow.right"){
                        if index == phrases.count - 1 {
                            index = 0
                        } else {
                            index += 1
                        }
                    }
                }
                .buttonStyle(.tintStyle)
                .font(.largeTitle)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .symbolVariant(.circle.fill)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $showBorders){
                Text("Show Borders")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
                
            Toggle(isOn: $groupByWhitespace){
                Text("Group By Whitespace")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(size, format: .number.rounded(increment: 1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $size, in: 6...160, step: 4)
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("Alignment")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $alignment, items: TextAlignment.allCases){ a in
                    Group {
                        switch a {
                        case .leading: Image(systemName: "text.alignleft")
                        case .center: Image(systemName: "text.aligncenter")
                        case .trailing: Image(systemName: "text.alignright")
                        }
                    }
                    .font(.body[.heavy])
                    .padding(4)
                }
                .frame(width: 130)
                .controlRoundness(1)
            }
            .padding()
        }
        .animation(.bouncy, value: alignment)
    }
    
}



#Preview("Line Wrap Layout") {
    LineWrapLayoutExample()
        .previewSize()
}



extension String {
    
    func identifiedSequence() -> [IdentifiedChar] {
        reduce(into: [IdentifiedChar]()){ res, char in
            if let last = res.last(where: { $0.char == char }) {
                res.append(.init(char: char, orderCount: last.orderCount + 1))
            } else {
                res.append(.init(char: char, orderCount: 1))
            }
        }
    }
    
}


@dynamicMemberLookup struct IdentifiedChar: Hashable, Identifiable, CustomStringConvertible, Sendable {
    var id: Int { hashValue }
    var description: String { char.description }
    
    let char: Character
    let orderCount: UInt
    
    subscript<V>(dynamicMember key: KeyPath<Character,V>) -> V {
        char[keyPath: key]
    }
    
    static func ==(lhs: IdentifiedChar, rhs: Character) -> Bool {
        lhs.char == rhs
    }
    
    static func ==(lhs: Character, rhs: IdentifiedChar) -> Bool {
        lhs == rhs.char
    }
    
    static func !=(lhs: IdentifiedChar, rhs: Character) -> Bool {
        lhs.char != rhs
    }
    
    static func !=(lhs: Character, rhs: IdentifiedChar) -> Bool {
        lhs != rhs.char
    }
    
}


extension Array<IdentifiedChar> {
    
    var description: String {
        reduce(into: ""){ $0.append($1.char) }
    }
    
}
