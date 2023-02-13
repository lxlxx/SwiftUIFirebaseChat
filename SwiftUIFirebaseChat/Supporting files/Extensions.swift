//
//  Extensions.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 9/2/2023.
//

import SwiftUI


struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
}

extension Image {
    func resize_Fit_Clipped() -> some View {
        self
            .resizable()
            .scaledToFit()
            .clipped()
        
    }
}

extension Color {
    static let alpha0_05 = Color(.init(white:0, alpha: 0.05))
    static let alpha0_5 = Color(.init(white:0, alpha: 0.5))
}


// https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


extension View {
    func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}
