//
//  CustomLoginViewController.swift
//  Barman
//
//  Created by Carlos Padilla on 22/11/23.
//

import UIKit

class CustomLoginViewController: UIViewController, UITextFieldDelegate {

    let label = UILabel()
    let accountField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton()
    
    // An activity indicator is created for local usage (optional).
    let actInd = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        
        // The label is configured.
        label.text = "Enter your credentials:"
        label.font = UIFont(name: "SegoeUI-Semibold", size: 16)
        label.textAlignment = .center
        self.view.addSubview(label)

        // The accountField is set up.
        accountField.placeholder = "Registered Email:"
        accountField.setLeftPaddingPoints(10)
        accountField.customize(false)
        self.view.addSubview(accountField)
        accountField.keyboardType = .emailAddress
        accountField.autocapitalizationType = .none
        accountField.autocorrectionType = .no
        accountField.returnKeyType = .next
        accountField.delegate = self
        
        // The passwordField is set up.
        passwordField.placeholder = "Password:"
        passwordField.setLeftPaddingPoints(10)
        passwordField.customize(false)
        passwordField.isSecureTextEntry = true
        self.view.addSubview(passwordField)
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .next
        passwordField.delegate = self
    
        // The loginButton is configured.
        loginButton.backgroundColor = Utils.UIColorFromRGB(rgbValue: colorPrimaryDark)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        self.view.addSubview(loginButton)
        
        // The activity indicator is configured.
        actInd.color = .darkGray
        actInd.hidesWhenStopped = true
        actInd.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(actInd)
        
        NSLayoutConstraint.activate([
            actInd.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            actInd.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rect = self.view.bounds
        label.frame = CGRect(x: 10, y: 60, width: rect.width - 20, height: 35)
        accountField.frame = CGRect(x: 20, y: label.frame.maxY + 20, width: rect.width - 40, height: 35)
        passwordField.frame = CGRect(x: 20, y: accountField.frame.maxY + 25, width: rect.width - 40, height: 35)
        loginButton.frame = CGRect(x: 40, y: passwordField.frame.maxY + 120, width: rect.width - 80, height: 45)
    }
    
    @objc func loginAction() {
        // The keyboard is dismissed.
        self.view.endEditing(true)
        var message = ""
        
        // The internet connection is checked.
        if !NetworkReachability.shared.isConnected {
            Utils.showMessage("No internet connection. Please check WiFi or cellular data.")
            return
        }
        
        guard let account = self.accountField.text,
              let pass = self.passwordField.text
        else {
            return
        }
        if account.isEmpty {
            message = "Please enter your email"
        } else if pass.isEmpty {
            message = "Please enter your password"
        }
        
        if message.isEmpty {
            // The activity indicator is started.
            actInd.startAnimating()
            
            Services().loginService(account, pass) { dict in
                DispatchQueue.main.async {
                    // The activity indicator is stopped after the request.
                    self.actInd.stopAnimating()
                    
                    guard let code = dict?["code"] as? Int,
                          let msg = dict?["message"] as? String
                    else {
                        Utils.showMessage("An error occurred. Please try again or contact support.")
                        return
                    }
                    if code == 200 {
                        // The session is saved in UserDefaults.
                        UserDefaults.standard.set(true, forKey: "customLogged")
                        UserDefaults.standard.synchronize()
                        
                        // Instead of calling `self.performSegue(...)`, the parent is asked to trigger the segue.
                        if let parentVC = self.parent as? LoginInterface {
                            parentVC.performSegue(withIdentifier: "loginOK", sender: nil)
                        }
                    } else {
                        Utils.showMessage(msg)
                    }
                }
            }
        } else {
            Utils.showMessage(message)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountField {
            passwordField.becomeFirstResponder()
            return false
        }
        if textField == passwordField {
            passwordField.resignFirstResponder()
            return false
        }
        return true
    }
}
