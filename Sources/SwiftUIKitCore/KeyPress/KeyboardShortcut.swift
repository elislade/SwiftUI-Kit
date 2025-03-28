import SwiftUI


#if os(watchOS) || os(tvOS)

public struct KeyboardShortcut : Hashable, Sendable {

    public struct Localization : Hashable, Sendable {

        /// Remap shortcuts to their international counterparts, mirrored for
        /// right-to-left usage if appropriate.
        ///
        /// This is the default configuration.
        public static let automatic: KeyboardShortcut.Localization = .init()

        /// Don't mirror shortcuts.
        ///
        /// Use this for shortcuts that always have a specific directionality, like
        /// aligning something on the right.
        ///
        /// Don't use this option for navigational shortcuts like "Go Back" because navigation
        /// is flipped in right-to-left contexts.
        public static let withoutMirroring: KeyboardShortcut.Localization = .init()

        /// Don't use automatic shortcut remapping.
        ///
        /// When you use this mode, you have to take care of international use-cases separately.
        public static let custom: KeyboardShortcut.Localization = .init()
    }

    /// The standard keyboard shortcut for the default button, consisting of
    /// the Return (↩) key and no modifiers.
    ///
    /// On macOS, the default button is designated with special coloration. If
    /// more than one control is assigned this shortcut, only the first one is
    /// emphasized.
    public static let defaultAction = KeyboardShortcut(.escape, modifiers: [])

    /// The standard keyboard shortcut for cancelling the in-progress action
    /// or dismissing a prompt, consisting of the Escape (⎋) key and no
    /// modifiers.
    public static let cancelAction = KeyboardShortcut(.escape, modifiers: [])

    /// The key equivalent that the user presses in conjunction with any
    /// specified modifier keys to activate the shortcut.
    public var key: KeyEquivalent

    /// The modifier keys that the user presses in conjunction with a key
    /// equivalent to activate the shortcut.
    public var modifiers: EventModifiers

    /// The localization strategy to apply to this shortcut.
    public var localization: KeyboardShortcut.Localization

    /// Creates a new keyboard shortcut with the given key equivalent and set of
    /// modifier keys.
    ///
    /// The localization configuration defaults to ``KeyboardShortcut/Localization-swift.struct/automatic``.
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command){
        self.key = key
        self.modifiers = modifiers
        self.localization = .automatic
    }

    /// Creates a new keyboard shortcut with the given key equivalent and set of
    /// modifier keys.
    ///
    /// Use the `localization` parameter to specify a localization strategy
    /// for this shortcut.
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command, localization: KeyboardShortcut.Localization){
        self.key = key
        self.modifiers = modifiers
        self.localization = localization
    }
    
}

extension EventModifiers: @retroactive Hashable { }

extension View {
    
    public func keyboardShortcut(_ shortcut: KeyboardShortcut) -> Self {
        self
    }
    
    public func keyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> Self {
        self
    }
    
}

#else

extension View {
    
    public func keyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        keyboardShortcut(SwiftUI.KeyEquivalent(key.character), modifiers: modifiers)
    }
    
}

#endif
