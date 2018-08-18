//
//  Theming.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-26.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation

protocol Themable {
  associatedtype _ThemeManager: ThemeManager
  var themeManager: _ThemeManager { get }

  /// Implemented by a view to apply a specific theme
  func applyTheme(_ theme: _ThemeManager.Theme)
}

extension Themable where Self: AnyObject {
  var themeManager: AppThemeManager {
    return AppThemeManager.shared
  }

  func setupTheming() {
    applyTheme(themeManager.currentTheme)
    themeManager.subscribeToChanges(self) { [weak self] newTheme in
      self?.applyTheme(newTheme)
    }
  }
}
