import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation
import Combine


struct InteractionLeader {
    
    @Environment(\.dismissPresentation) private var dismiss
    @Environment(\.layoutDirection) private var direction
    @Environment(\.interactiveProgress) private var interactiveProgress
    @GestureState private var isActive = false
    
    @State private var hasLoaded = false
    @State private var phase: PresentationPhase = .appearing
    @State private var progress: Double = 1
    
    enum Phase {
        case interacting
        case willComplete(Destination)
        case didComplete(Destination)
    }
    
    enum Destination {
        case appear
        case disappear
    }
    
    let enabled: Bool
    let source: CGRect
    let width: Double
    let wantsRemoval: Bool
    let wantsCancellationIfActive: Bool
    let phaseChange: (Phase) -> Void
    
}

extension InteractionLeader: ViewModifier {
    
    func body(content: Content) -> some View {
        let scale = 1.0 - (0.2 * progress)
        //let scaleFromSource = source.width / width
        let shouldMatch = false//source.width < width && !isActive
        content
            .presentationPhase(phase)
            .allowsHitTesting(phase == .presented)
            .mask{
                ContainerRelativeShape()
                    .inset(by: -0.5)
                    .frame(
                        height: progress == 1 && shouldMatch ? source.height * (width / source.width) : nil,
                        alignment: .top
                    )
                    .offset(y: progress == 1 && shouldMatch ? -source.height * (width / source.width) : 0)
                    .ignoresSafeArea()
            }
            .scaleIgnoredByLayout(1.0 * scale)
            .offsetIgnoredByLayout([progress * width, 0])
            //.scaleIgnoredByLayout(shouldMatch ? (1.0 - progress) + (progress * scaleFromSource) : 1.0 * scale)
            //.offsetIgnoredByLayout(shouldMatch ? [source.midX - (width / 2) , source.midY - source.height - 50.0] * progress : [progress * width, 0])
            .tasksShouldWait(phase != .presented)
            //.background(alignment: .topLeading){
            //    Color.red
            //        .frame(width: source.width, height: source.height)
            //        .offset(x: source.origin.x, y: source.origin.y)
            //}
            //.animation(.bouncy, value: shouldMatch)
            .onAnimationComplete(of: progress == 0){
                guard phase == .appearing else { return }
                phase = .presented
                phaseChange(.didComplete(.appear))
            }
            .onAnimationComplete(of: progress == 1){
                guard phase == .disappearing else { return }
                phaseChange(.didComplete(.disappear))
            }
            .animation(isActive ? .interactiveSpring(response: 0.1) : .smooth.speed(1.7), value: progress)
            .onDisappear{
                // if this view gets removed outside of its expected lifecycle set progress to 1 just to make sure its in sync
                interactiveProgress.send(1)
            }
            .onAppear {
                phaseChange(.willComplete(.appear))
                interactiveProgress.send(0)
                progress = 0
            }
            .overlay(alignment: .leading) {
                if enabled {
                    Color.clear
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .map{ ($0.translation.width / width) * direction.scaleFactor }
                                .onChanged{
                                    progress = $0
                                    interactiveProgress.send($0)
                                }
                                .updating($isActive){ _, state, _ in state = true }
                        )
                        .ignoresSafeArea()
                        .frame(width: 20)
                        .onChangePolyfill(of: isActive){
                            if !isActive {
                                if progress > 0.3 {
                                    // This will force a loop caught by the NavView which then processes disposal then passes a wantsRemoval back down, causing the animation to then complete.
                                    // this is required for proper disposal ordering.
                                    // don't think about it too hard.
                                    dismiss()
                                } else {
                                    phase = .appearing
                                    interactiveProgress.send(0)
                                    progress = 0
                                }
                            } else {
                                phaseChange(.interacting)
                            }
                        }
                }
            }
            //.overlay {
            //    Color.red.opacity(0.4).indirectScrollGesture(
            //        IndirectScrollGesture(axes: .horizontal).onChanged{ value in
            //            progress = (value.translation.x / width)
            //        }.onEnded{ value in
            //        }
            //    )
            //}
            .onChangePolyfill(of: wantsRemoval){
                guard wantsRemoval else { return }
                phase = .disappearing
                phaseChange(.willComplete(.disappear))
                interactiveProgress.send(1)
                progress = 1
            }
            .onChangePolyfill(of: wantsCancellationIfActive){
                guard wantsCancellationIfActive, phase != .presented else { return }
                if progress > 0.3 {
                    dismiss()
                } else {
                    phase = .appearing
                    interactiveProgress.send(0)
                    progress = 0
                }
            }
            .transition(.identity)
    }
    
}


@dynamicMemberLookup struct ExplicitlyPresentable<Element> {
    
    let element: Element
    private var phase: InteractionLeader.Phase?
    
    init(_ element: Element, initialPhase: InteractionLeader.Phase? = nil) {
        self.element = element
        self.phase = initialPhase
    }
    
    func new(replacing element: Element) -> Self {
        .init(element, initialPhase: phase)
    }
    
    func cancel() {
        // if appearing it will go back to removed
        // if disappearing it will go back to identity
        // if identity it will do nothing
    }
    
    func willAppear(){ }
    func didAppear(){ }
    
    func willDisappear(){ }
    func didDisappear(){ }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<Element, Subject>) -> Subject {
        element[keyPath: keyPath]
    }
    
}

extension ExplicitlyPresentable: Identifiable where Element : Identifiable {
    
    var id: Element.ID { element.id }
    
}


extension EnvironmentValues {
    
    @Entry var interactiveProgress: CurrentValueSubject<Double?, Never> = .init(nil)
    
}


struct InteractionFollower<Transition: TransitionModifier> {
    
    let enabled: Bool
    
    @Environment(\.interactiveProgress) var interactiveProgressPub
    @State private var progress: Double? = nil
    
}


extension InteractionFollower: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .modifier(
                Transition(pushAmount:  1 - (progress ?? 1))
                    .animation(.smooth.speed(1.5))
            )
            .background{
                if enabled {
                    Color.clear.onReceive(interactiveProgressPub){ value in
                        progress = value
                    }
                }
            }
    }
    
}


extension View {
    
    nonisolated func interactionContext() -> some View {
        InlineState(CurrentValueSubject<Double?, Never>(nil)){ state in
            self.environment(\.interactiveProgress, state)
        }
    }
    
    nonisolated func interactionFollower<Transition: TransitionModifier>(_ transition: Transition.Type, enabled: Bool) -> some View {
        modifier(InteractionFollower<Transition>(enabled: enabled))
    }
    
    nonisolated func interactionLeader(
        enabled: Bool = true,
        source: CGRect = .zero,
        width: Double,
        wantsRemoval: Bool,
        wantsCancellationIfActive: Bool = false,
        stateChange: @escaping (InteractionLeader.Phase) -> Void
    ) -> some View {
        modifier(InteractionLeader(
            enabled: enabled,
            source: source,
            width: width,
            wantsRemoval: wantsRemoval,
            wantsCancellationIfActive: wantsCancellationIfActive,
            phaseChange: stateChange
        ))
    }
    
}
