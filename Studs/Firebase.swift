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

  private enum Collections: String {
    case activities
    case checkins
  }

  static var db: Firestore? {
    // TODO: Look into a way to do this better
    return (UIApplication.shared.delegate as? AppDelegate)?.firestoreDB
  }

  // MARK: - Event checkins
  /// Add a check-in for a user at a specific event.
  /// The current timestamp is used as checkin time.
  /// `byUserId` is the acting user checking in someone.
  static func addCheckin(userId: String, byUserId: String, eventId: String) {
    db?.collection(Collections.checkins.rawValue)
      .addDocument(data: [
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
    db?.collection(Collections.checkins.rawValue)
      .document(checkinId).delete { err in
        if let err = err {
          print("Error removing checkin: \(err)")
        }
    }
  }

  /// Stream updates for a specific checkin
  static func streamCheckin(eventId: String, userId: String,
                            handler: @escaping (EventCheckin?) -> Void) {
    db?.collection(Collections.checkins.rawValue)
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
    db?.collection(Collections.checkins.rawValue)
      .whereField("eventId", isEqualTo: eventId)
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
  /// Streams updates for all trip activities not having passed
  static func streamActivities(handler: @escaping ([TripActivity]) -> Void)
    -> Subscription<[TripActivity]> {
      let listener = db?.collection(Collections.activities.rawValue)
        .whereField("endDate", isGreaterThanOrEqualTo: Date())
        .addSnapshotListener { querySnapshot, error in
          guard let documents = querySnapshot?.documents else {
            print("Error fetching activities: \(error!)")
            return
          }
          let activities = documents.compactMap(TripActivity.init)
          handler(activities)
      }
      return Subscription { listener?.remove() }
  }

  /// Adds or updates a specific trip activity
  static func addOrUpdateActivity(_ activity: TripActivity,
                                  completion: ((Error?) -> Void)? = nil) {
    db?.collection(Collections.activities.rawValue)
      .document(activity.id)
      .setData(activity.data) { error in
        if let error = error { print(error) }
        completion?(error)
    }
  }

  /// Deletes a specific trip activity
  static func deleteActivity(_ activity: TripActivity,
                             completion: ((Error?) -> Void)? = nil) {
    db?.collection(Collections.activities.rawValue)
      .document(activity.id)
      .delete { error in
        if let error = error { print(error) }
        completion?(error)
    }
  }

  static func streamActivityRegistrations(
    activityId: String,
    handler: @escaping ([TripActivityRegistration]) -> Void
  ) -> Subscription<[TripActivityRegistration]> {
    let listener = db?
      .collection(Collections.activities.rawValue)
      .document(activityId)
      .collection("people")
      .addSnapshotListener { querySnapshot, error in
        guard let documents = querySnapshot?.documents else {
          print("Error fetching registrations: \(error!)")
          return
        }
        let registrations = documents.compactMap(TripActivityRegistration.init)
        handler(registrations)
    }
    return Subscription { listener?.remove() }
  }

  static func addActivityRegistration(userId: String,
                                      byUserId: String,
                                      activityId: String) {
    db?.collection(Collections.activities.rawValue)
      .document(activityId)
      .collection("people")
      .document(userId)
      .setData([
        "registeredAt": Date(),
        "userId": userId,
        "registeredById": byUserId,
        ]) { err in
          if let err = err {
            print("Error adding registration: \(err)")
          }
    }
  }

  static func removeActivityRegistration(registrationId: String, activityId: String) {
    db?.collection(Collections.activities.rawValue)
      .document(activityId)
      .collection("people")
      .document(registrationId).delete { err in
        if let err = err {
          print("Error removing registration: \(err)")
        }
    }
  }
}

extension TripActivity {
  // Creates a TripActivity from a firebase document
  init?(from document: QueryDocumentSnapshot) {
    guard
      let category = Category(rawValue: document["category"] as? String ?? ""),
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
    self.city = City(rawValue: document["city"] as? String ?? "")
    self.category = category
    self.title = document["title"] as? String
    self.description = document["description"] as? String ?? "No description"
    self.price = document["price"] as? String
    self.location = location
    self.createdDate = createdDate
    self.startDate = startDate
    self.endDate = endDate
    self.peopleCount = document["peopleCount"] as? Int ?? 0
    self.isUserActivity = document["isUserActivity"] as? Bool ?? false
    self.author = document["author"] as? String
  }

  // A firebase data represenation of the activity
  var data: [String: Any] {
    return [
      "title": self.title ?? "",
      "category": self.category.rawValue,
      "city": self.city?.rawValue ?? "",
      "description": self.description,
      "price": self.price ?? "",
      "location": [
        "address": self.location.address,
        "coordinate": GeoPoint(latitude: self.location.coordinate.latitude,
                               longitude: self.location.coordinate.longitude),
      ],
      "createdDate": self.createdDate,
      "startDate": self.startDate,
      "endDate": self.endDate,
      "isUserActivity": self.isUserActivity,
      "author": self.author ?? "",
    ]
  }
}

extension TripActivityRegistration {
  init?(from document: QueryDocumentSnapshot) {
    guard
      let registeredAt = document["registeredAt"] as? Date,
      let registeredById = document["registeredById"] as? String,
      let userId = document["userId"] as? String
    else { return nil }
    self.id = document.documentID
    self.registeredAt = registeredAt
    self.registeredById = registeredById
    self.userId = userId
  }
}
