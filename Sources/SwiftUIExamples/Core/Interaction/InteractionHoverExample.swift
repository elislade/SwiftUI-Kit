import SwiftUIKit


public struct InteractionHoverExample: View  {

    @State private var priority: InteractionPriority = .normal
    @State private var groupEvents: [InteractionHoverGroupEvent] = []
    @State private var delayInMilliseconds: Double = 0
    @State private var showContent: Bool = false
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Interaction Hover"){
            VStack(spacing: 0) {
                GroupEventLog(events: groupEvents)
                    .padding(.top)
                
                if showContent || priority != .window {
                    Content()
                        .padding()
                        .interactionHoverGroup(
                            priority: priority,
                            delay: .milliseconds(delayInMilliseconds)
                        ){
                            groupEvents.append($0)
                            
                            if $0.hasEnded {
                                showContent = false
                            }
                        }
                        .geometryGroupPolyfill()
                        .transition(.move(edge: .bottom) + .opacity)
                } else {
                    Text("Press down then drag to select content.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged{ _ in showContent = true }
                        )
                        .transition(.scale + .opacity)
                }
            }
            .animation(.bouncy, value: showContent)
            .animation(.bouncy, value: priority)
        } parameters: {
            HStack{
                Text("Priority")
                    .font(.exampleParameterTitle)

                Picker(selection: $priority){
                    ForEach(InteractionPriority.allCases){ priority in
                        PriorityLabel(priority)
                            .tag(priority)
                    }
                } label: {
                    EmptyView()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .exampleParameterCell()
            
            VStack {
                HStack{
                    Text("Delay")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(
                        Measurement<UnitDuration>(value: delayInMilliseconds, unit: .milliseconds),
                        format: .measurement(width: .narrow)
                    )
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $delayInMilliseconds, in: 0...500, step: 5)
            }
            .exampleParameterCell()
        }
    }
    
    
    struct Content: View {
        
        var spacing: Double = 10
        var columns: Int = 3
        var rows: Int = 3
        
        var body: some View {
            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { _ in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { _ in
                            Element()
                        }
                    }
                    
                    PercentageRoundedRectangle(.vertical, percentage: 1)
                        .opacity(0.1)
                }
            }
        }
        
    }
    
    
    struct Element: View {
        
        @State private var phase: InteractionHoverPhase?
        
        var body: some View {
            Button{ print("press") } label: {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.tint)
                    .opacity(phase == .entered || phase == .ended ? 1 : 0.2)
                    .onInteractionHover{ phase = $0 }
                    .overlay {
                        if let phase {
                            ElementPhaseLabel(phase)
                                .foregroundStyle(.background)
                                .font(.largeTitle.weight(.bold))
                                .minimumScaleFactor(0.5)
                                .labelStyle(.iconOnly)
                                .id(phase)
                                .transition(.blur(radius: 5) + .scale(0.6) + .opacity)
                        }
                    }
                    .animation(.bouncy, value: phase)
            }
            .buttonStyle(.plain)
        }
    }
    
    
    struct PriorityLabel: View {
        
        let priority: InteractionPriority
        
        init(_ priority: InteractionPriority) {
            self.priority = priority
        }
        
        var body: some View {
            switch priority {
            case .normal:
                Label("Normal", systemImage: "pointer.arrow.click")
            case .high:
                Label("High", systemImage: "pointer.arrow.click.2")
            case .simultaneous:
                Label("Simultaneous", systemImage: "pointer.arrow.motionlines.click")
            case .window:
                Label("Window", systemImage: "macwindow.and.pointer.arrow")
            }
        }
    }
    
    
    struct ElementPhaseLabel: View {
        
        let phase: InteractionHoverPhase
        
        init(_ phase: InteractionHoverPhase) {
            self.phase = phase
        }
        
        var body: some View {
            switch phase {
            case .entered:
                Label("Entered", systemImage: "square.and.arrow.down")
            case .left:
                Label("Left", systemImage: "square.and.arrow.up")
            case .ended:
                Label("Ended", systemImage: "checkmark")
            }
        }
    }
    
    
    struct GroupEventPhaseLabel: View {
        
        let state: InteractionHoverGroupEvent.Phase
        
        init(_ state: InteractionHoverGroupEvent.Phase) {
            self.state = state
        }
        
        var body: some View {
            switch state {
            case .started: Text("Started")
            case .entered: Text("Entered")
            case .exited: Text("Exited")
            case .ended: Text("Ended")
            }
        }
    }
    
    
    struct GroupEventLog: View {
        
        let events: [InteractionHoverGroupEvent]
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("Event Log")
                    Spacer()
                    
                    if events.endedOnElement {
                        Text("Selected")
                            .foregroundStyle(.tint)
                            .font(.body)
                    }
                }
                .font(.title[.bold])
                .padding(.horizontal)
                    
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 14) {
                            ForEach(events, id: \.date){ event in
                                GroupEventPhaseLabel(event.phase)
                                    .padding()
                                    .padding(.horizontal, 10)
                                    .id(event.date)
                                    .background(.background, in: .capsule)
                                    .overlay{
                                        Capsule()
                                            .strokeBorder()
                                            .opacity(0.1)
                                    }
                                    .shadow(color: .init(.sRGBLinear, white: 0, opacity: 0.08), radius: 5, y: 2)
                                    .transition((.scale(0.8) + .opacity))
                            }
                        }
                        .padding()
                        .animation(.bouncy, value: events)
                        .onChangePolyfill(of: events.last){
                            withAnimation(.smooth){
                                proxy.scrollTo(events.last?.date, anchor: .center)
                            }
                        }
                    }
                }
                .scrollClipDisabledPolyfill()
                .frame(height: 70)
                .overlay {
                    if events.isEmpty {
                        Text("No Events.")
                            .font(.caption)
                            .opacity(0.5)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal)
                    }
                }
            }
        }
            
    }
}


#Preview("Interaction Group") {
    InteractionHoverExample()
        .previewSize()
}
