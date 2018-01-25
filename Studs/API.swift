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
  private static let baseURL = "https://studs18-overlord.herokuapp.com"
//  private static let baseURL = "http://localhost:5040"
  private static let loginURL = baseURL + "/login"
  private static let graphQLURL = baseURL + "/graphql"

  /// Tries to log in the user using email and password.
  /// Success boolean is available in completion handler.
  static func login(email: String, password: String,
                    completion: @escaping (Bool) -> Void) {
    let parameters = [
      "email": email,
      "password": password,
      ]
    Alamofire.request(loginURL, method: .post, parameters: parameters,
                      encoding: JSONEncoding.default).response { response in
                        if let status = response.response?.statusCode {
                          completion(status == 200)
                        } else {
                          completion(false)
                        }
    }
  }

  /// Logs out by dropping all cookies associated with the base URL.
  static func logout(completion: (() -> Void)? = nil) {
    let cstorage = HTTPCookieStorage.shared
    if let cookies = cstorage.cookies(for: URL(string: self.baseURL)!) {
      for cookie in cookies {
        cstorage.deleteCookie(cookie)
      }
    }
    completion?()
  }

  /// Performs a GraphQL query, decodes the response to a model conforming to
  /// the Decodable protocol, and returns it in a Result to the completion handler.
  private static func performGraphQLQuery<T: Decodable>(queryName: String,
                                                        query: String,
                                                        completion: @escaping (Result<T>) -> Void) {
    let jsonDecoder = JSONDecoder()
    // TODO: Add date decoding strategy

    let parameters = ["query": query]
    Alamofire.request(graphQLURL, method: .post, parameters: parameters).responseJSON { response in
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
}
