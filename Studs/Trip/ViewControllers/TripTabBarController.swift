//
//  TripTabBarController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  The tab bar that displays the schedule, plans or information views

import UIKit
import Pulley

class TripTabBarController: PulleyCompatibleTabBarController {
  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?
  private var statusBarStyle = UIStatusBarStyle.lightContent

  private var drawerPosition = DrawerPosition.partiallyRevealed {
    didSet {
      guard oldValue != drawerPosition else { return }
      self.pulleyViewController?.setDrawerPosition(
        position: drawerPosition.pulleyPosition,
        animated: true
      )
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTheming()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    applyTheme(themeManager.currentTheme)

    stateSubscription = store.subscribe { [weak self] state in
      self?.drawerPosition = state.drawerPosition
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  @IBAction func gripperLongTapped(_ sender: UILongPressGestureRecognizer) {
    guard sender.state == .began else { return }
    themeManager.nextTheme()
  }
}

extension TripTabBarController: Themable {
  func applyTheme(_ theme: Theme) {
    pulleyViewController?.drawerBackgroundVisualEffectView?.effect = theme.visualEffect
    safeAreaCoveringView.effect = theme.visualEffect
    tabBar.tintColor = theme.tintColor
    statusBarStyle = theme.statusBarStyle
    setNeedsStatusBarAppearanceUpdate()
  }

  override var childViewControllerForStatusBarStyle: UIViewController? {
    return nil
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return statusBarStyle
  }
}

// MARK: - PulleyDrawerViewControllerDelegate
extension TripTabBarController {
  func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
    store.dispatch(action: .changeDrawerPosition(drawer.drawerPosition.drawerPosition))
    store.dispatch(action: .setDrawerBottomSafeArea(Float(bottomSafeArea + 40)))
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
