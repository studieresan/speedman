//
//  BarButton.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-04-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

@IBDesignable
class BarButton: CardView {
  // MARK: - Outlets
  @IBOutlet var contentView: CardView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var topPadding: NSLayoutConstraint!
  @IBOutlet weak var bottomPadding: NSLayoutConstraint!

  // MARK: - Properties
  // Make designable from storyboard
  @IBInspectable var title: String? {
    get { return titleLabel?.text }
    set { titleLabel?.text = newValue }
  }
  @IBInspectable var subtitle: String? {
    get { return subtitleLabel?.text }
    set {
      subtitleLabel?.text = newValue
      // Less padding if no subtitle
      topPadding.constant = newValue == nil ? 16 : 10
      bottomPadding.constant = newValue == nil ? 16 : 10
    }
  }
  @IBInspectable var lightContent: Bool {
    get { return titleLabel?.textColor == UIColor.white }
    set {
      titleLabel?.textColor = newValue ? UIColor.white : UIColor.black
      subtitleLabel?.textColor = newValue ? UIColor.white : UIColor.black
    }
  }
  override var backgroundColor: UIColor? {
    didSet {
      contentView?.backgroundColor = backgroundColor
    }
  }

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }

  func xibSetup() {
    contentView = loadViewFromNib()
    subtitle = nil
    contentView.backgroundColor = backgroundColor
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(contentView)
  }

  func loadViewFromNib() -> CardView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as? CardView
  }

  // MARK: - UIResponder
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    contentView.layer.shadowOpacity = 0
    titleLabel.alpha = 0.5
    subtitleLabel.alpha = 0.5
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    contentView.layer.shadowOpacity = 0.2
    titleLabel.alpha = 1.0
    subtitleLabel.alpha = 1.0
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    contentView.layer.shadowOpacity = 0.2
    titleLabel.alpha = 1.0
    subtitleLabel.alpha = 1.0
  }
}
