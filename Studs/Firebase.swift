//
//  Firebase.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-08.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  This handles all communication with the Firebase "Cloud Firestore" DB.
//  In order to connect to the db, the API keys .plist will have to be included
//  in the project: https://support.google.com/firebase/answer/7015592
//

import Foundation
import UIKit
import CoreLocation
import FirebaseFirestore

struct Firebase {

  // MARK: - Event checkins
  /// Add a check-in for a user at a specific event.
  /// The current timestamp is used as checkin time.
  /// `byUserId` is the acting user checking in someone.
  static func addCheckin(userId: String, byUserId: String, eventId: String) {
    // TODO: Look into a way to do this better
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let db = appDelegate.firestoreDB
    else { return }

    db.collection("checkins").addDocument(data: [
      "eventId": eventId,
      "userId": userId,
      "checkedInById": byUserId,
      "checkedInAt": DateFormatter.iso8601Fractional.string(from: Date()),
      ]) { err in
        if let err = err {
          print("Error adding document: \(err)")
        }
    }
  }

  /// Remove the check-in with a specific id from an event
  static func removeCheckin(checkinId: String) {
    // TODO: Look into a way to do this better
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let db = appDelegate.firestoreDB
    else { return }

    db.collection("checkins").document(checkinId).delete { err in
      if let err = err {
        print("Error removing checkin: \(err)")
      }
    }
  }

  /// Stream updates for a specific checkin
  static func streamCheckin(eventId: String, userId: String,
                            handler: @escaping (EventCheckin?) -> Void) {
    // TODO: Look into a way to do this better
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let db = appDelegate.firestoreDB
    else { return }

    db.collection("checkins")
      .whereField("eventId", isEqualTo: eventId)
      .whereField("userId", isEqualTo: userId)
      .limit(to: 1)
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          print("Error fetching checkin: \(error)")
        }
        guard let document = querySnapshot?.documents.first else {
          return handler(nil)
        }
        let checkin = createCheckin(from: document)
        handler(checkin)
    }
  }

  /// Stream updates to checkins for a specific event
  static func streamCheckins(eventId: String,
                             handler: @escaping ([EventCheckin]) -> Void) {
    // TODO: Look into a way to do this better
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let db = appDelegate.firestoreDB
    else { return }

    db.collection("checkins").whereField("eventId", isEqualTo: eventId)
      .addSnapshotListener { querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
          print("Error fetching checkins: \(error!)")
          return
        }
        let checkins = documents.compactMap(createCheckin)
        handler(checkins)
    }
  }

  /// Helper to convert a firebase document to our EventCheckin model
  private static func createCheckin(from document: QueryDocumentSnapshot)
    -> EventCheckin? {
      guard
        let eventId = document["eventId"] as? String,
        let userId = document["userId"] as? String,
        let checkedInById = document["checkedInById"] as? String,
        let dateString = document["checkedInAt"] as? String
      else { return nil }

      let date = DateFormatter.iso8601Fractional.date(from: dateString)
      return EventCheckin(
        id: document.documentID,
        eventId: eventId,
        userId: userId,
        checkedInById: checkedInById,
        checkedInAt: date ?? Date()
      )
  }

  // MARK: - Trip
  static func streamActivities(handler: @escaping ([TripActivity]) -> Void) {
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let db = appDelegate.firestoreDB
      else { return }

    db.collection("activities")
      .whereField("endDate", isGreaterThanOrEqualTo: Date())
      .addSnapshotListener { querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
          print("Error fetching activities: \(error!)")
          return
        }
        let activities = documents.compactMap(TripActivity.init)
        handler(activities)
    }
  }
}

extension TripActivity {
  // Creates a TripActivity from a firebase document
  init?(from document: QueryDocumentSnapshot) {
    guard
      let title = document["title"] as? String,
      let category = Category(rawValue: document["category"] as? String ?? ""),
      let city = City(rawValue: document["city"] as? String ?? ""),
      let createdDate = document["createdDate"] as? Date,
      let startDate = document["startDate"] as? Date,
      let endDate = document["endDate"] as? Date,
      let locationObj = document["location"] as? [String: Any],
      let coordinate = locationObj["coordinate"] as? GeoPoint
    else { return nil }
    let location = Location(
      address: locationObj["address"] as? String ?? "",
      coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                         longitude: coordinate.longitude)
    )

    self.id = document.documentID
    self.city = city
    self.category = category
    self.title = title
    self.description = document["desription"] as? String ?? "No description"
    self.price = document["price"] as? String ?? "?"
    self.location = location
    self.createdDate = createdDate
    self.startDate = startDate
    self.endDate = endDate
  }
}
