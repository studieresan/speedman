//
//  TripTabBarController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import Pulley

class TripTabBarController: PulleyCompatibleTabBarController {
  // MARK: - Properties
  private lazy var store: Store! = (UIApplication.shared.delegate as? AppDelegate)?.store
  private var unsubsribeFromStore: Disposable?

  private var drawerPosition: DrawerPosition = .partiallyRevealed {
    didSet {
      if drawerPosition != oldValue {
        pulleyViewController?.setDrawerPosition(
          position: drawerPosition.pulleyPosition,
          animated: true
        )
      }
    }
  }

  // MARK: - Lifecycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    unsubsribeFromStore = store?.subscribe { [weak self] state in
      self?.drawerPosition = state.drawerPosition
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    unsubsribeFromStore?()
  }
}

// MARK: - PulleyDrawerViewControllerDelegate
extension TripTabBarController {
  func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
    store.setDrawerPosition(drawer.drawerPosition.drawerPosition)
  }
}

// MARK: - Convenience Extensions
extension DrawerPosition {
  var pulleyPosition: PulleyPosition {
    return PulleyPosition.positionFor(string: self.rawValue)
  }
}

extension PulleyPosition {
  var drawerPosition: DrawerPosition {
    switch self {
    case .open:
      return .open
    case .collapsed:
      return .collapsed
    case .partiallyRevealed:
      return .partiallyRevealed
    default:
      return .collapsed
    }
  }
}
