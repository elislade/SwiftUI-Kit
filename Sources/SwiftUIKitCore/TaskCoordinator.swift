import SwiftUI


struct TaskCoordinator<Value: Sendable, ID: Equatable> {
    
    @Environment(\.tasksShouldWait) private var shouldWait
    @State private var task: Task<Value, Error>?
    @State private var innerID = UniqueID()
    
    let id: ID
    let operation: @Sendable () async throws -> Value
    let done: @MainActor (Result<Value, Error>) -> Void
    
}


extension TaskCoordinator: ViewModifier {
    
    func body(content: Content) -> some View {
        content.background {
            Color.clear
                .onDisappear{
                    task?.cancel()
                    task = nil
                }
                .onAppear{
                    task = Task(priority: .low, operation: operation)
                }
                .onChangePolyfill(of: shouldWait, initial: true){
                    guard !shouldWait, let task else { return }
                    self.task = nil
                    Task(priority: .low) { @MainActor in
                        done(await task.result)
                    }
                }
                .id(innerID)
        }
        .onChangePolyfill(of: id){
            innerID = UniqueID()
        }
    }
    
}

extension EnvironmentValues {
    
    @Entry var tasksShouldWait: Bool = false
    
}


extension View {
    
    nonisolated public func tasksShouldWait(_ wait: Bool) -> some View {
        transformEnvironment(\.tasksShouldWait){ value in
            if wait {
                value = true
            }
        }
    }
    
}

extension View {
    
    /// Starts a task but only returns a value when not waiting on some container blocking it.
    /// - Parameters:
    ///   - operation: An async function.
    ///   - succeeded: A closure with successful result.
    ///   - failed: A  closure with failure error. Defaults to empty closure.
    /// - Returns: A modified view.
    nonisolated public func coordinateTask<Success: Sendable>(
        id: some Equatable = Int.zero,
        operation: /*sending @escaping @isolated(any)*/ @Sendable @escaping () async throws -> Success,
        succeeded: @MainActor @escaping (Success) -> Void,
        failed: @MainActor @escaping (Error) -> Void = { _ in }
    ) -> some View {
        modifier(TaskCoordinator(
            id: id,
            operation: operation,
            done: {
                switch $0 {
                    case let .success(value): succeeded(value)
                    case let .failure(error): failed(error)
                }
            }
        ))
    }
    
}
