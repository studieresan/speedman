//
//  NotificationManager.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-02-23.
//  Copyright © 2018 Studieresan. All rights reserved.
//
//  Singleton for handle scheduling of local notifications
//  TODO: Get rid of singleton?

import Foundation
import UserNotifications

class NotificationsManager {
  static let shared = NotificationsManager()

  private let center: UNUserNotificationCenter

  func scheduleNotifications(for event: Event) {
    scheduleBeforeReminder(for: event)
    scheduleAfterReminder(for: event)
  }

  private func scheduleBeforeReminder(for event: Event) {
    guard let date = event.date, date > Date() else { return }
    let time = DateFormatter.timeFormatter.string(from: date)
    let content = UNMutableNotificationContent()
    content.title = "Event reminder"
    content.subtitle = event.companyName ?? "Company"
    content.body = "Tomorrow, \(time) at \(event.location ?? "_"). " +
    "Remember to fill in the pre-survey and bring your name tag."
    content.sound = UNNotificationSound.default()

    var dateInfo = Calendar.current.dateComponents([.month, .day, .hour, .minute],
                                                   from: date)
    // The day before at 21:30
    dateInfo.day? -= 1; dateInfo.hour = 21; dateInfo.minute = 30
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
    let id = "\(event.id)-before"
    let notification = UNNotificationRequest(identifier: id, content: content,
                                             trigger: trigger)
    center.add(notification) { error in
      if let error = error {
        print("Error scheduling local before event notification: \(error)")
      }
    }
  }

  private func scheduleAfterReminder(for event: Event) {
    guard
      let endDate = event.date?.addingTimeInterval(4 * 60 * 60), // +4 hours
      endDate > Date()
    else { return }
    let content = UNMutableNotificationContent()
    content.title = "Survey reminder"
    content.subtitle = event.companyName ?? "Company"
    content.body = "Have you filled in the post-survey yet? " +
      "If not, do it now while you remember the event!"
    content.sound = UNNotificationSound.default()

    let dateInfo = Calendar.current.dateComponents([.month, .day, .hour, .minute],
                                                   from: endDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
    let id = "\(event.id)-after"
    let notification = UNNotificationRequest(identifier: id, content: content,
                                             trigger: trigger)
    center.add(notification) { error in
      if let error = error {
        print("Error scheduling local after event notification: \(error)")
      }
    }
  }

  private init() {
    center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { _, _ in
      // TODO: Do something if not granted?
    }
  }
}
