import UIKit

class CustomLoginViewController: UIViewController, UITextFieldDelegate {

    // UI elements
    let bannerLabel = UILabel()         // banner label: Barman
    let titleLabel = UILabel()
    let accountField = UITextField()
    let passwordField = UITextField()
    
    // "Remember me" checkbox (use .custom to avoid system tint overriding images)
    let rememberMeCheckbox = UIButton(type: .custom)
    
    // Login button (we’ll use a config in iOS 15+)
    let loginButton = UIButton()
    
    // Activity Indicator
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Main stack view for easy layout
    let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        self.view.backgroundColor = .systemGroupedBackground
        
        // -- Banner Label --
        bannerLabel.text = "Barman"
        bannerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        bannerLabel.textAlignment = .center
        bannerLabel.textColor = .systemBlue
        
        // -- Title Label --
        titleLabel.text = "Enter Your Credentials"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        // -- Account Field --
        accountField.placeholder = "Registered Email"
        accountField.borderStyle = .roundedRect
        accountField.keyboardType = .emailAddress
        accountField.autocapitalizationType = .none
        accountField.autocorrectionType = .no
        accountField.returnKeyType = .next
        accountField.delegate = self
        
        // -- Password Field --
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.delegate = self
        
        // -- Remember Me Checkbox (type: .custom) --
        rememberMeCheckbox.setTitle("Remember me", for: .normal)
        rememberMeCheckbox.setTitleColor(.label, for: .normal)
        rememberMeCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        rememberMeCheckbox.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        rememberMeCheckbox.contentHorizontalAlignment = .left
        rememberMeCheckbox.addTarget(self, action: #selector(toggleRememberMe), for: .touchUpInside)
        
        // -- Login Button (iOS 15+ config, fallback for older iOS) --
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Log In"
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .systemBlue
            config.cornerStyle = .fixed
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            loginButton.configuration = config
            loginButton.layer.cornerRadius = 8 // optional if needed
        } else {
            // Fallback for iOS < 15
            loginButton.setTitle("Log In", for: .normal)
            loginButton.backgroundColor = .systemBlue
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            loginButton.layer.cornerRadius = 8
        }
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        
        // -- Activity Indicator --
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // -- Stack View --
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Add subviews to stackView
        stackView.addArrangedSubview(bannerLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(accountField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(rememberMeCheckbox)
        stackView.addArrangedSubview(loginButton)
        
        // Add stackView & activityIndicator to the main view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        self.view.addSubview(activityIndicator)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Remember Me Toggle
    @objc func toggleRememberMe() {
        rememberMeCheckbox.isSelected.toggle()
        // If you'd like, store this in UserDefaults:
        // UserDefaults.standard.set(rememberMeCheckbox.isSelected, forKey: "rememberMe")
        // UserDefaults.standard.synchronize()
    }
    
    // MARK: - Login Action
    @objc func loginAction() {
        // Dismiss the keyboard
        self.view.endEditing(true)
        
        activityIndicator.startAnimating()
        
        // Check network connectivity
        if !NetworkReachability.shared.isConnected {
            activityIndicator.stopAnimating()
            Utils.showMessage("No internet connection. Please check Wi-Fi or cellular data.")
            return
        }
        
        // Validate fields
        guard let account = accountField.text, !account.isEmpty,
              let pass = passwordField.text, !pass.isEmpty else {
            activityIndicator.stopAnimating()
            Utils.showMessage("Please fill both email and password.")
            return
        }
        
        // Call your login service
        Services().loginService(account, pass) { dict in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                guard let code = dict?["code"] as? Int,
                      let msg = dict?["message"] as? String else {
                    Utils.showMessage("An error occurred. Please try again or contact support.")
                    return
                }
                if code == 200 {
                    // Save session in UserDefaults
                    UserDefaults.standard.set(true, forKey: "customLogged")
                    UserDefaults.standard.synchronize()
                    
                    // Ask the parent view controller to segue
                    if let parentVC = self.parent as? LoginInterface {
                        parentVC.performSegue(withIdentifier: "loginOK", sender: nil)
                    }
                } else {
                    Utils.showMessage(msg)
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
        }
        return false
    }
}
