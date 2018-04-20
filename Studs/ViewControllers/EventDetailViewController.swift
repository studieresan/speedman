//
//  EventDetailViewController.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-30.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class EventDetailViewController: UIViewController, UIScrollViewDelegate,
UITextViewDelegate {

  // MARK: - Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var infoCard: EventInfoCard!
  @IBOutlet weak var beforeSurveyButton: BarButton!
  @IBOutlet weak var afterSurveyButton: BarButton!
  @IBOutlet weak var descriptionCard: CardView!
  @IBOutlet weak var descriptionTextView: UITextView!

  // MARK: - Properties
  var event: Event!
  private let locationManager = CLLocationManager()
  private lazy var navbar = navigationController?.navigationBar as? CustomNavigationBar
  private var navbarStyle: CustomNavigationBar.Style {
    if scrollView.contentOffset.y + scrollView.adjustedContentInset.top > 190 {
      return .translucent
    } else {
      return .faded
    }
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    descriptionTextView.delegate = self

    infoCard.setup(for: event)

    if let description = event.privateDescription, !description.isEmpty {
      descriptionTextView.text = event.privateDescription
      // Remove stupid padding
      descriptionTextView.textContainer.lineFragmentPadding = 0
    } else {
      descriptionCard.isHidden = true
    }

    configureSurveyButtons()
    configureMapView()

    // Try to use location
    if CLLocationManager.locationServicesEnabled() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.distanceFilter = 10
    }

    // Hide button to check-in manager if insufficient permissions
    if let user = UserManager.shared.user,
      !user.permissions.contains(.checkins) {
      // TODO: Separate permission for checkins
      navigationItem.rightBarButtonItem = nil
    }
  }

  /// Hide the event surveys buttons conditionally.
  /// Hides the after survey before the event and hides the before survey
  /// after the event starts.
  private func configureSurveyButtons() {
    beforeSurveyButton.isHidden = event.beforeSurveys?.isEmpty ?? true
    afterSurveyButton.isHidden = event.afterSurveys?.isEmpty ?? true
    if let date = event.date {
      if date.compare(Date()) == .orderedDescending {
        afterSurveyButton.isHidden = true
      } else {
        beforeSurveyButton.isHidden = true
      }
    }
  }

  private func configureMapView() {
    // Lookup coordinates for address and place pin on map
    if let address = event.location {
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address) { placemarks, _ in
        guard let placemarks = placemarks else { return }
        guard let coordinate = placemarks[0].location?.coordinate else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "\(self.event.companyName ?? ""): \(address)"
        self.mapView.addAnnotation(pin)
        self.mapView.showAnnotations([pin], animated: false)
        // Zoom out map a bit
        self.mapView.setRegion({
            var region = self.mapView.region
            var span = region.span
            span.latitudeDelta *= 3
            span.longitudeDelta *= 3
            region.span = span
            return region
          }(),
          animated: false)
      }
    } else {
      mapView.isHidden = true
    }
//    applyMapFadeO ut()
  }

  override func viewWillAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    navbar?.style = navbarStyle
    super.viewDidAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
    super.viewWillDisappear(animated)
  }

  deinit {
    applyMapViewMemoryLeakFix()
  }

  /// Mitigate MKMapView memory leaks
  /// http://www.openradar.me/33400943
  private func applyMapViewMemoryLeakFix() {
    switch mapView.mapType {
    case .standard, .mutedStandard:
      mapView.mapType = .satellite
    default:
      mapView.mapType = .standard
    }
    mapView.showsUserLocation = false
    mapView.delegate = nil
    mapView.removeFromSuperview()
    mapView = nil
  }

  /// Fades out the bottom of the map view by adding a gradient layer mask
  private func applyMapFadeOut() {
    let gradientLayer = CAGradientLayer()
    let mapBounds = mapView.bounds
    // Don't mask horizontally by making the mask as wide as screen max
    let screenMax = max(UIScreen.main.bounds.maxX, UIScreen.main.bounds.maxY)
    gradientLayer.frame = CGRect(x: mapBounds.origin.x, y: mapBounds.origin.y,
                                 width: screenMax, height: mapBounds.height)
    gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
    // Fade out last 10%
    gradientLayer.locations = [0.9, 1.0]
    mapView.layer.mask = gradientLayer
  }

  // MARK: - Actions
  @IBAction func beforeSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.beforeSurveys?.first else { return }
    openURL(url: url)
  }

  @IBAction func afterSurveyTapped(_ sender: UITapGestureRecognizer) {
    guard let url = event.afterSurveys?.first else { return }
    openURL(url: url)
  }

  /// Open the given url in a SFSafariViewController
  private func openURL(url: String) {
    guard let url = URL(string: url) else { return }
    let safariVC = SFSafariViewController(url: url)
    self.present(safariVC, animated: true)
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "checkInSegue":
      if let checkinVC = segue.destination as? CheckInTableViewController {
        checkinVC.event = self.event
      }
    case "checkinButtonSetupSegue":
      if let buttonVC = segue.destination as? CheckinButtonViewController {
        buttonVC.event = self.event
        // Make the container view size itself to the embedded VC
        buttonVC.view.translatesAutoresizingMaskIntoConstraints = false
      }
    default:
      break
    }
  }

  // MARK: - UITextViewDelegate
  func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    // Open URLs from textview in in app browser instead of external
    openURL(url: URL.absoluteString)
    return false
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if navbar?.style != navbarStyle {
      navbar?.style = navbarStyle
    }
  }
}
