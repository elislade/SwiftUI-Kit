import SwiftUI
import SwiftUICore


/// A replica of SwiftUI Picker view with segmented style. The benifit of this is properly animated values and visibility when in drawing group. The base UIKit Representation does not participate in the Animation transaction properly.
/// Also adds support for more freedom on the type of segmented content.
public struct SegmentedPicker<Data: RandomAccessCollection, Label: View>: View where Data.Element: Hashable, Data.Index == Int {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.controlSize) private var controlSize
    @Environment(\.controlRoundness) private var controlRoundness
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.layoutDirectionSuggestion) private var layoutDirectionSuggestion
    @Environment(\.isEnabled) private var isEnabled
    
    @Namespace private var ns
    @Binding private var selection: Data.Element
    
    private var selectionIndex: Data.Index {
        items.firstIndex(where: { $0 == selection })!
    }
    
    @State private var pendingStartIndex: Data.Index?
    @State private var pendingIndex: Data.Index?
    
    private var pendingStartIsSelection: Bool { selectionIndex == pendingStartIndex }
    private var layoutVertical: Bool { layoutDirectionSuggestion.useVertical }
    private var rightToLeft: Bool { layoutDirection == .rightToLeft }
    
    private let items: Data
    @ViewBuilder private let content: (Data.Element) -> Label
    
    
    private var controlFactor: Double {
        switch controlSize {
        case .mini: 0.7
        case .small: 0.85
        case .regular: 1
        case .large: 1.2
        case .extraLarge: 1.4
        @unknown default: 1
        }
    }
    
    private var dimension: Double {
        (40 - (16 * interactionGranularity)) * controlFactor
    }
    
    
    /// Initializes instance
    /// - Parameters:
    ///   - selection: A binding to the selection.
    ///   - items: RandomAccessCollection of items to pick from.
    ///   - content: View builder that takes a single item as an argument.
    public init(
        selection: Binding<Data.Element>,
        items: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Label
    ) {
        self._selection = selection
        self.items = items
        self.content = content
    }
    
    private func gesture(viewSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .named("Control"))
            .onChanged{ g in
                let xLocation = layoutDirection == .rightToLeft ? viewSize.width - g.location.x : g.location.x
                let step = layoutVertical ? g.location.y / viewSize.height : (xLocation / viewSize.width)
                let offset = max(min(Int(step * Double(items.count)), items.count - 1), 0)
                let pending = items.index(items.startIndex, offsetBy: offset)
                self.pendingIndex = pending
                if pendingStartIndex == nil {
                    pendingStartIndex = pending
                }
            }
            .onEnded { _ in
                if let pendingIndex {
                    selection = items[pendingIndex]
                    self.pendingIndex = nil
                    self.pendingStartIndex = nil
                }
            }
    }
    
    private func opacity(for idx: Data.Index) -> Double {
        guard pendingIndex != nil, !pendingStartIsSelection else { return 1 }
        return idx == pendingIndex && pendingIndex != selectionIndex ? 0.4 : 1
    }
    
    private var spacerTicks: some View {
        let index = pendingIndex ?? selectionIndex
        return ForEach(items.indices, id: \.self){ idx in
            Spacer()
            
            if idx != items.indices.last && index != idx && index != (idx + 1) {
                Divider()
            }
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            AxisStack(layoutVertical ? .vertical : .horizontal, spacing: 0){
                ForEach(items.indices, id: \.self){ idx in
                    let item = items[idx]
                    Color.clear
                        .overlay{
                            content(item)
                                .padding(dimension / 8)
                        }
                        .minimumScaleFactor(0.1)
                        .opacity(opacity(for: idx))
                        .foregroundStyle(pendingIndex ?? selectionIndex == idx ? .black : .primary)
                        .scaleEffect(pendingStartIsSelection && pendingIndex == idx ? 0.95 : 1)
                        .padding(layoutVertical ? dimension / 8 : 0)
                        .contentShape(ContainerRelativeShape())
                        .accessibilityAddTraits(selectionIndex == idx ? .isSelected : [])
                        .accessibilityAction { selection = item }
                        .hoverEffectPolyfill()
                        .accessibilityAddTraits(.isButton)
                        .gesture(
                            TapGesture()
                                .onEnded{ selection = item }
                                .exclusively(before: gesture(viewSize: proxy.size))
                        )
                }
            }
            .coordinateSpace(name: "Control")
            .background{
                let shape = RoundedRectangle(cornerRadius: (dimension / 2) * (controlRoundness ?? 0.4))
                let width = proxy.size.width / Double(items.count)
                let height = proxy.size.height / Double(items.count)
                let idx = pendingIndex ?? selectionIndex
                ZStack(alignment: .topLeading){
                    SunkenControlMaterial(shape)
                    
                    if layoutVertical {
                        VStack(spacing: 0) { spacerTicks }.padding(.horizontal, dimension / 8)
                    } else {
                        HStack(spacing: 0) { spacerTicks }.padding(.vertical, dimension / 8)
                    }
                    
                    RaisedControlMaterial(shape.inset(by: pendingStartIsSelection ? dimension / 8 : dimension / 12))
                        .offset(
                            x: layoutVertical ? 0 : width * Double(idx),
                            y: layoutVertical ? height * Double(idx) : 0
                        )
                        .frame(
                            width: layoutVertical ? nil : width,
                            height: layoutVertical ? height : nil
                        )
                }
            }
        }
        .frame(
            width: layoutVertical ? dimension : nil,
            height: layoutVertical ? nil : dimension
        )
        .lineLimit(1)
        .animation(.smooth, value: pendingIndex)
        .opacity(isEnabled ? 1 : 0.5)
    }
    
}
