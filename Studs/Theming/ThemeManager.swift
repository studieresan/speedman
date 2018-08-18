//
//  ThemeManager.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-28.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import UIKit

protocol ThemeManager {
  associatedtype Theme
  var currentTheme: Theme { get }
  func subscribeToChanges(_ object: AnyObject, handler: @escaping (Theme) -> Void)
}

final class AppThemeManager: ThemeManager {
  static let shared: AppThemeManager = .init()
  private var theme: SubscribableValue<Theme>
  private var availableThemes: [Theme] = [.light, .dark]

  var currentTheme: Theme {
    // TODO: Protect from concurrent access
    get { return theme.value }
    set { setNewTheme(newValue) }
  }

  func nextTheme() {
    guard let nextTheme = availableThemes.rotate() else { return }
    currentTheme = nextTheme
  }

  private func setNewTheme(_ theme: Theme) {
    let window = UIApplication.shared.delegate!.window!!
    UIView.transition(
      with: window,
      duration: 0.3,
      options: [.transitionCrossDissolve],
      animations: {
        self.theme.value = theme
      },
      completion: nil
    )
    UserDefaults.standard.setValue(theme.name, forKey: "theme")
  }

  private init() {
    // Read theme from userdefaults
    let theme = UserDefaults.standard.string(forKey: "theme") ?? ""
    switch theme {
    case "dark":
      self.theme = SubscribableValue<Theme>(value: .dark)
    case "light":
      self.theme = SubscribableValue<Theme>(value: .light)
    default:
      self.theme = SubscribableValue<Theme>(value: .light)
    }
  }

  func subscribeToChanges(_ object: AnyObject, handler: @escaping (Theme) -> Void) {
    theme.subscribe(object, using: handler)
  }
}
