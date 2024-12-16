//
//  Services.swift
//  Barman
//
//  Created by Carlos Padilla on 06/12/24.
//

import Foundation
import CryptoKit

class Services {
    
    func encryptPassword(_ pass: String) -> String {
        // The password is encrypted using SHA256.
        var newPass = ""
        let salt = ""
        guard let bytes = (pass + salt).data(using: .utf8) else { return "" }
        let hashPass = SHA256.hash(data: bytes)
        newPass = hashPass.compactMap { String(format: "%02x", $0) }.joined()
        return newPass
    }
    
    func loginService(_ username: String, _ password: String, completion: @escaping ([String: Any]?) -> Void) {
        if let theURL = URL(string: baseUrl + "/WS/login.php") {
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: theURL)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let encryptedPass = encryptPassword(password)
            let paramString = "username=\(username)&password=\(encryptedPass)"
            request.httpBody = paramString.data(using: .utf8)
            let task = session.dataTask(with: request) { data, response, error in
                if let bytes = data {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: bytes) as! [String: Any]
                        completion(dictionary)
                    } catch {
                        print("An error occurred in the response: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
            task.resume()
        }
    }
}
