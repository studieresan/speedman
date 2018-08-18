//
//  TripInformationViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-15.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripInformationViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentStackView: UIStackView!

  // MARK: - Properties
  private lazy var store = (UIApplication.shared.delegate as? AppDelegate)!.tripStore
  private var stateSubscription: Subscription<TripState>?
  var informationJson: Any? {
    didSet {
      guard let json = informationJson else { return }
      if let array = json as? [[String: Any]] {
        array.forEach { self.addEntry($0) }
      }
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTheming() // Themable
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if informationJson == nil {
      API.getTravelInformation { [weak self] in
        switch $0 {
        case .success(let json):
          self?.informationJson = json
        case .failure(let error):
          print(error)
        }
      }
    }
    stateSubscription = store.subscribe { [weak self] state in
      self?.scrollView.isScrollEnabled = state.drawerPosition == .open
      self?.scrollView.contentInset =
        UIEdgeInsets(top: 0.0, left: 0.0,
                     bottom: CGFloat(state.drawerBottomSafeArea), right: 0.0)
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stateSubscription?.unsubscribe()
  }

  // MARK: - UI updates
  func addEntry(_ entry: [String: Any]) {
    guard let type = entry["type"] as? String else { return }
    if type == "header", let text = entry["text"] as? String {
      addHeader(text)
    } else if type == "list", let items = entry["items"] as? [String] {
      addList(items)
    }
  }

  func addHeader(_ text: String) {
    let headerLabel = UILabel()
    headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
    headerLabel.text = text
    headerLabel.translatesAutoresizingMaskIntoConstraints = false
    contentStackView.addArrangedSubview(headerLabel)
    applyThemeToLabel(headerLabel, theme: themeManager.currentTheme)
  }

  func addList(_ items: [String]) {
    let textView = UITextView()
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.dataDetectorTypes = [.link, .phoneNumber]
    textView.isSelectable = true
    textView.isEditable = false
    textView.isUserInteractionEnabled = true
    textView.textContainer.lineFragmentPadding = 0
    var content = ""
    items.forEach { content.append("∙ \($0)<br/>") }
    textView.attributedText = NSAttributedString(html: content)
    textView.translatesAutoresizingMaskIntoConstraints = false
    contentStackView.addArrangedSubview(textView)
    contentStackView.addConstraints([
      contentStackView.leftAnchor.constraint(equalTo: textView.leftAnchor),
      contentStackView.rightAnchor.constraint(equalTo: textView.rightAnchor),
    ])
    applyThemeToTextView(textView, theme: themeManager.currentTheme)
  }
}

// MARK: - Themable
extension TripInformationViewController: Themable {
  func applyThemeToTextView(_ textView: UITextView, theme: Theme) {
    textView.textColor = theme.primaryTextColor
    textView.tintColor = theme.tintColor
  }

  func applyThemeToLabel(_ label: UILabel, theme: Theme) {
    label.textColor = theme.primaryTextColor
  }

  func applyTheme(_ theme: Theme) {
    titleLabel.textColor = theme.primaryTextColor
    contentStackView.arrangedSubviews.forEach {
      if let textView = $0 as? UITextView {
        applyThemeToTextView(textView, theme: theme)
      } else if let label = $0 as? UILabel {
        applyThemeToLabel(label, theme: theme)
      }
    }
  }
}
