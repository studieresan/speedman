//
//  CreateTripActivityTableViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import CoreLocation

class CreateTripActivityTableViewController: UITableViewController {
  // MARK: - Outlets
  @IBOutlet private weak var titleTextView: UITextView!
  @IBOutlet private weak var titlePlaceholderLabel: UILabel!
  @IBOutlet private weak var addressTextField: UITextField!
  @IBOutlet private weak var locationSpinner: UIActivityIndicatorView!
  @IBOutlet private weak var userLocationButton: UIButton!
  @IBOutlet private weak var startDateView: UIView!
  @IBOutlet private weak var startDateButton: UIButton!
  @IBOutlet private weak var endDateView: UIView!
  @IBOutlet private weak var endDateButton: UIButton!
  @IBOutlet private weak var datePickerCell: UITableViewCell!
  @IBOutlet private weak var datePicker: UIDatePicker!

  @IBOutlet private weak var attractionButton: UIButton!
  @IBOutlet private weak var attractionButtonLabel: UILabel!
  @IBOutlet private weak var foodButton: UIButton!
  @IBOutlet private weak var foodButtonLabel: UILabel!
  @IBOutlet private weak var drinkButton: UIButton!
  @IBOutlet private weak var drinkButtonLabel: UILabel!
  @IBOutlet private weak var otherButton: UIButton!
  @IBOutlet private weak var otherButtonLabel: UILabel!

  // MARK: - Properties
  private lazy var tableViewHeight: NSLayoutConstraint =
    NSLayoutConstraint(item: self.tableView,
                       attribute: NSLayoutAttribute.height,
                       relatedBy: .equal,
                       toItem: nil,
                       attribute: .notAnAttribute,
                       multiplier: 1,
                       constant: 0)
  private var contentSizeObservation: NSKeyValueObservation?
  private let locationManager = CLLocationManager()
  private let geocoder = CLGeocoder()

  var activityTitle = "" {
    didSet {
      titleTextView.text = activityTitle
    }
  }
  var location: CLLocation? {
    didSet {
      guard let location = location else { return }
      if address == nil {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
          self?.locationSpinner.isHidden = true
          if let placemark = placemarks?.first {
            var str = placemark.name ?? ""
            if let thoroughfare = placemark.thoroughfare {
              str.append(", \(thoroughfare)")
              if let subThoroughfare = placemark.subThoroughfare {
                str.append(" \(subThoroughfare)")
              }
            }
            if let locality = placemark.locality {
              str.append(", \(locality)")
            }
            self?.address = str
          }
        }
      }
    }
  }
  var address: String? {
    didSet {
      addressTextField.text = address
      guard let address = address else { return }
      if location == nil {
        self.locationSpinner.isHidden = false
        geocoder.geocodeAddressString(address) { [weak self] placemarks, _ in
          self?.locationSpinner.isHidden = true
          if let placemark = placemarks?.first {
            self?.location = placemark.location
          }
        }
      }
    }
  }
  var startDate = Date() {
    didSet {
      startDateButton.setTitle(DateFormatter.dateAndTimeFormatter.string(from: startDate),
                               for: .normal)
    }
  }
  var endDate = Date() {
    didSet {
      endDateButton.setTitle(DateFormatter.dateAndTimeFormatter.string(from: endDate),
                             for: .normal)
    }
  }
  var activityCategory: TripActivity.Category = .attraction {
    didSet {
      let attractionColor = TripActivity.Category.attraction.color
      let foodColor = TripActivity.Category.food.color
      let drinkColor = TripActivity.Category.drink.color
      let otherColor = TripActivity.Category.other.color
      let gray = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
      attractionButton.tintColor =
        activityCategory == .attraction ? attractionColor : gray
      attractionButtonLabel.textColor =
        activityCategory == .attraction ? attractionColor : gray
      foodButton.tintColor = activityCategory == .food ? foodColor : gray
      foodButtonLabel.textColor = activityCategory == .food ? foodColor : gray
      drinkButton.tintColor = activityCategory == .drink ? drinkColor : gray
      drinkButtonLabel.textColor = activityCategory == .drink ? drinkColor : gray
      otherButton.tintColor = activityCategory == .other ? otherColor : gray
      otherButtonLabel.textColor = activityCategory == .other ? otherColor : gray
    }
  }

  enum DateEditingMode {
    case startDate
    case endDate
    case none
  }

  private var dateEditingMode = DateEditingMode.none {
    didSet {
      if dateEditingMode == .startDate {
        datePicker.setDate(startDate, animated: true)
      } else if dateEditingMode == .endDate {
        datePicker.setDate(endDate, animated: true)
      }
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.startDateView.backgroundColor =
          self?.dateEditingMode == .startDate ? #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 0.1) : .clear
        self?.endDateView.backgroundColor =
          self?.dateEditingMode == .endDate ? #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 0.1) : .clear
      }
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    titleTextView.delegate = self
    addressTextField.delegate = self

    datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)),
                         for: .valueChanged)

    view.translatesAutoresizingMaskIntoConstraints = false
    tableView.addConstraint(tableViewHeight)

    // Observe the actual needed size of the table and update a constrain to that value
    // when it changes. This is to make the container view size itself correctly.
    contentSizeObservation =
      observe(\.tableView.contentSize, options: [.new]) { [weak self] _, change in
      if let newHeight = change.newValue?.height {
        self?.tableViewHeight.constant = newHeight
      }
    }

    startDate = Date()
    endDate = Date().addingTimeInterval(60 * 60)
  }

  // MARK: - Actions
  @IBAction func startDateTapped(_ sender: Any) {
    dateEditingMode = dateEditingMode == .startDate ? .none : .startDate
    // Reload table with animations:
    tableView.beginUpdates()
    tableView.endUpdates()
  }

  @IBAction func endDateTapped(_ sender: Any) {
    dateEditingMode = dateEditingMode == .endDate ? .none : .endDate
    // Reload table with animations:
    tableView.beginUpdates()
    tableView.endUpdates()
  }

  @IBAction func userLocationButtonTapped(_ sender: Any) {
    address = nil
    // Reqest access to location services
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
      locationManager.delegate = self
      locationManager.requestLocation()
      locationSpinner.isHidden = false
    }
  }

  @objc func datePickerValueChanged(sender: UIDatePicker) {
    switch dateEditingMode {
    case .startDate:
      startDate = sender.date
    case .endDate:
      endDate = sender.date
    case .none:
      break
    }
  }

  @IBAction func categoryButtonTapped(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view?.subviews.first else { return }
    if view == attractionButton || view == attractionButtonLabel {
      activityCategory = .attraction
    } else if view == foodButton || view == foodButtonLabel {
      activityCategory = .food
    } else if view == drinkButton || view == drinkButtonLabel {
      activityCategory = .drink
    } else if view == otherButton || view == otherButtonLabel {
      activityCategory = .other
    }
  }
}

// MARK: - UITableViewDelegate
extension CreateTripActivityTableViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
    -> CGFloat {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    // Toggle visibility of the datepicker row
    if (cell == datePickerCell && dateEditingMode == .none) || cell.isHidden {
      return 0
    } else {
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }
}

// MARK: - UITextViewDelegate
extension CreateTripActivityTableViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    titlePlaceholderLabel.isHidden = !textView.text.isEmpty
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    // Disallow multiline
    if text == "\n" {
      addressTextField.becomeFirstResponder()
      return false
    }
    // Limit to 140 characters
    return textView.text.count + (text.count - range.length) <= 140
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    activityTitle = textView.text
  }
}

// MARK: - UITextFieldDelegate
extension CreateTripActivityTableViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    location = nil
    address = textField.text
  }
}

// MARK: - CLLocationManagerDelegate
extension CreateTripActivityTableViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    self.location = locations.last
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
