//
//  API.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-01-18.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct API {
//  private static let baseURL = "https://studs18-overlord.herokuapp.com"
//  private static let baseURL = "http://localhost:5040"
  private static let baseURL = "http://jonathans-mbp-tb.local:5040"
  private static let loginURL = baseURL + "/login"
  private static let logoutURL = baseURL + "/logout"
  private static let graphQLURL = baseURL + "/graphql"

  /// Tries to log in the user using email and password.
  /// Success boolean is available in completion handler.
  static func login(email: String, password: String,
                    completion: @escaping (Result<Void>) -> Void) {
    let parameters = [
      "email": email,
      "password": password,
      ]
    Alamofire.request(loginURL, method: .post, parameters: parameters)
      .validate()
      .response { response in
        if let error = response.error {
          completion(.failure(error))
        } else {
          completion(.success(()))
          UserManager.shared.renewUser()
        }
    }
  }

  /// Logs out by dropping all cookies associated with the base URL and
  /// requesting that the server destroys the session
  static func logout() {
    // Make the server destroy the session
    Alamofire.request(logoutURL)

    // Drop cookies
    let cstorage = HTTPCookieStorage.shared
    if let cookies = cstorage.cookies(for: URL(string: self.baseURL)!) {
      for cookie in cookies {
        cstorage.deleteCookie(cookie)
      }
    }
    UserManager.shared.logout()
  }

  /// Performs a GraphQL query, decodes the response to a model conforming to
  /// the Decodable protocol, and returns it in a Result to the completion handler.
  private static func performGraphQLQuery<T: Decodable>
    (queryName: String, query: String, completion: @escaping (Result<T>) -> Void) {

    let jsonDecoder = JSONDecoder()

    let parameters = ["query": query]
    Alamofire.request(graphQLURL, method: .post,parameters: parameters)
      .responseJSON { response in
        let result = Result<T>() {
          switch response.result {
          case .success(let value):
            let json = JSON(value)
            let queryJson = json["data"][queryName]
            return try jsonDecoder.decode(T.self, from: queryJson.rawData())
          case .failure(let error):
            throw error
          }
        }
        completion(result)
    }
  }

  /// Gets all events as an array
  static func getEvents(completion: @escaping (Result<[Event]>) -> Void) {
    let query = """
    query {
      allEvents {
        id
        companyName
        schedule
        privateDescription
        date
        location
        beforeSurveys
        afterSurveys
      }
    }
    """
    performGraphQLQuery(queryName: "allEvents", query: query,
                        completion: completion)
  }

  private static var userFields =
  """
  id
  profile {
    firstName
    lastName
    phone
  }
  """

  /// Get the currently logged in user
  static func getUser(completion: @escaping (Result<User>) -> Void) {
    let query = """
    query {
      user {
        \(API.userFields)
      }
    }
    """
    performGraphQLQuery(queryName: "user", query: query,
                        completion: completion)
  }

  /// Gets all Studs members as an array
  static func getUsers(completion: @escaping (Result<[User]>) -> Void) {
    let query = """
    query {
      users(memberType: studs_member) {
        \(API.userFields)
      }
    }
    """
    performGraphQLQuery(queryName: "users", query: query,
                        completion: completion)
  }
}
