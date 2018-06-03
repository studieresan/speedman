//
//  PulleyCompatibleTabBarController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-05-05.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  A UITabBarController meant to be used within a Pulley drawer.
//  When dragging the drawer, the tab bar stays fixed to the bottom.
//  It also sets up a gripper view on top and expands the drawer when pressing a tab.

import UIKit
import Pulley

class PulleyCompatibleTabBarController: UITabBarController {
  // MARK: - Outlets
  @IBOutlet private var gripperContainer: UIView!
  @IBOutlet private weak var gripper: UIView!

  // MARK: - Properties
  var visibleDrawerHeight: CGFloat = 0.0
  // Capture default tab bar height
  private lazy var tabBarHeight: CGFloat = {
    return tabBar.frame.height
  }()
  // A view covering the safe area between the tab bar and the bottom of the screen
  // Since we reposition the tab bar we don't get the extended background of the bar
  // like usual. So we cover it up manually.
  private lazy var safeAreaCoveringView: UIVisualEffectView = {
    let coveringView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    view.addSubview(coveringView)
    coveringView.translatesAutoresizingMaskIntoConstraints = false
    view.addConstraints([
      coveringView.leftAnchor.constraint(equalTo: view.leftAnchor),
      coveringView.rightAnchor.constraint(equalTo: view.rightAnchor),
      coveringView.heightAnchor.constraint(equalToConstant: 80),
    ])
    return coveringView
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupGripper()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // To trigger the drawer delegate methods
    pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: false)
    // Tease dragability
    pulleyViewController?.bounceDrawer()
    // Add additional safe area insets on top to avoid collision with gripper
    additionalSafeAreaInsets = UIEdgeInsets(top: gripperContainer.frame.height,
                                            left: 0,
                                            bottom: 0,
                                            right: 0)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Reposition the tab bar on load or rotation
    repositionTabBar()
    repositionSafeAreaCover()
  }

  // MARK: - View setup
  /// Sets up the gripper view on top of the drawer
  private func setupGripper() {
    gripper.layer.cornerRadius = 2.0
    view.addSubview(gripperContainer)
    gripperContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addConstraints([
      gripperContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
      gripperContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
      gripperContainer.topAnchor.constraint(equalTo: view.topAnchor),
      gripperContainer.heightAnchor.constraint(equalToConstant: 30.0),
    ])
  }

  // MARK: -
  override var selectedViewController: UIViewController? {
    didSet {
      // Make drawer visible when selecting a tab if it's hidden
      if pulleyViewController?.drawerPosition == .collapsed {
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed,
                                                animated: true)
      }
    }
  }

  /// Repositions the tab bar to the bottom of the drawer view
  private func repositionTabBar() {
    var tabFrame = self.tabBar.frame
    let bottomSafeArea = pulleyViewController?.bottomSafeSpace ?? 0.0
    tabFrame.origin.y =
      view.frame.origin.y + visibleDrawerHeight - tabBarHeight - bottomSafeArea
    tabFrame.size.height = tabBarHeight
    tabBar.frame = tabFrame
  }

  /// Repositions the safe area cover the the bottom of the drawer view
  private func repositionSafeAreaCover() {
    var frame = safeAreaCoveringView.frame
    let bottomSafeArea = pulleyViewController?.bottomSafeSpace ?? 0.0
    frame.origin.y =
      view.frame.origin.y + visibleDrawerHeight - bottomSafeArea
    safeAreaCoveringView.frame = frame
  }
}

// MARK: - PulleyDelegate
extension PulleyCompatibleTabBarController: PulleyDelegate {
  // Gets called all the time while dragging
  func drawerChangedDistanceFromBottom(drawer: PulleyViewController,
                                       distance: CGFloat,
                                       bottomSafeArea: CGFloat) {
    visibleDrawerHeight = distance
    // Reposition the tab bar so that it stays at the bottom
    repositionTabBar()
    repositionSafeAreaCover()
 }
}

// MARK: - PulleyDrawerViewControllerDelegate
extension PulleyCompatibleTabBarController: PulleyDrawerViewControllerDelegate {
  func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
    return bottomSafeArea + gripperContainer.frame.height + tabBar.frame.height
  }

  func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
    return 264.0 + bottomSafeArea
  }

  func supportedDrawerPositions() -> [PulleyPosition] {
    return PulleyPosition.all
  }
}
