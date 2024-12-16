//
//  LoginInterface.swift
//  Barman
//
//  Created by Carlos Padilla on 12/12/24.
//

import Foundation
import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginInterface: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    
    // MARK: - Properties
    
    /// Activity Indicator to show loading state for network or login tasks
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic configuration of the Activity Indicator
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the indicator to the view
        self.view.addSubview(activityIndicator)
        
        // Set constraints to center it on the screen
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reuse CustomLoginViewController for backend login
        let loginVC = CustomLoginViewController()
        self.addChild(loginVC)
        loginVC.view.frame = CGRect(x: 0, y: 45, width: self.view.bounds.width, height: self.view.bounds.width)
        self.view.addSubview(loginVC.view)
        
        // Add Apple ID button
        let appleIDButton = ASAuthorizationAppleIDButton()
        self.view.addSubview(appleIDButton)
        appleIDButton.center = self.view.center
        appleIDButton.frame.origin.y = loginVC.view.frame.maxY + 10
        appleIDButton.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
        
        // Add Google sign-in button
        let googleButton = GIDSignInButton(frame: CGRect(x: 0,
                                                         y: appleIDButton.frame.maxY + 10,
                                                         width: appleIDButton.frame.width,
                                                         height: appleIDButton.frame.height))
        googleButton.center.x = self.view.center.x
        self.view.addSubview(googleButton)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // MARK: - Custom Methods
    
    /// Checks if a user session is already active (Apple, Google, or custom)
    func checkLoginState() {
        // Example: if custom login is used, check UserDefaults here.
        
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        // Check if logged in with Google
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            // Stop the activity indicator once the call finishes
            self.activityIndicator.stopAnimating()
            
            guard let profile = user else { return }
            print("User: \(profile.profile?.name ?? ""), email: \(profile.profile?.email ?? "")")
            self.performSegue(withIdentifier: "loginOK", sender: nil)
        }
    }
    
    // MARK: - Google Sign-In
    
    @objc func googleButtonTapped() {
        // Start animating before the network call
        activityIndicator.startAnimating()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            // Stop animating once we have a response
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                Utils.showMessage("We have a problem... \(error.localizedDescription)")
            } else {
                guard let profile = result?.user else { return }
                print("User: \(profile.profile?.name ?? ""), email: \(profile.profile?.email ?? "")")
                self.performSegue(withIdentifier: "loginOK", sender: nil)
            }
        }
    }
    
    // MARK: - Apple Sign-In
    
    @objc func appleButtonTapped() {
        // Checking first for internet connection.
        guard NetworkReachability.shared.isConnected else {
            Utils.showMessage("No internet connection. Please check your Wi-Fi or cellphone data.")
            return
        }
        
        // Start animating before the network call
        activityIndicator.startAnimating()
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Stop the Activity Indicator
        self.activityIndicator.stopAnimating()
        
        // Here you could handle Apple login data if needed.
        self.performSegue(withIdentifier: "loginOK", sender: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Stop the Activity Indicator
        self.activityIndicator.stopAnimating()
        
        Utils.showMessage("Apple Sign-In Error: \(error.localizedDescription)")
    }
}
