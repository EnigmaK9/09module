//
//  DetailViewController.swift
//  Barman
//
//  Created by Carlos Padilla on December 13, 2024
//

import UIKit
import AVFoundation
import MessageUI

class DetailViewController: UIViewController,
    UITextFieldDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextField!
    @IBOutlet weak var directionsTextField: UITextField!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var stackViewContainerBottomConstraint: NSLayoutConstraint!
    
    var drink: Drink?
    // The UIImagePickerController must be a property to maintain reference.
    var ipc: UIImagePickerController!
    
    @IBAction func btnCamaraTouch(_ sender: Any) {
        // Permissions for the camera are validated here.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.showPicker(type: .camera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.showPicker(type: .camera)
                }
            }
        default:
            let ac = UIAlertController(
                title: "Error",
                message: "Camera permission is required. Do you want to set permissions in Settings?",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Ok", style: .default) { _ in
                let configURL = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(configURL!)
            }
            let action2 = UIAlertAction(title: "Not now", style: .default)
            ac.addAction(action)
            ac.addAction(action2)
            self.present(ac, animated: true)
        }
    }
    
    func showPicker(type: UIImagePickerController.SourceType) {
        // The image picker is presented here.
        ipc = UIImagePickerController()
        ipc.delegate = self
        ipc.sourceType = type
        ipc.allowsEditing = true
        self.present(ipc, animated: true)
    }
    
    // The picked image is handled here.
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let imagen = info[.editedImage] as? UIImage {
            imageView.image = imagen
            print("The image was updated.")
            saveImageDocumentDirectory(filename: "new_photo.png", image: imagen)
        }
        picker.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let drink = drink {
            // If a drink is passed, the UI is set to a read-only mode and an action button is shown for sharing.
            let shareBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(share)
            )
            self.navigationItem.rightBarButtonItem = shareBarButtonItem
            self.title = drink.name
            self.nameTextField.text = drink.name
            self.nameTextField.isEnabled = false
            self.ingredientsTextField.text = drink.ingredients
            self.ingredientsTextField.isEnabled = false
            self.directionsTextField.text = drink.directions
            self.directionsTextField.isEnabled = false
            self.addPhotoButton.isHidden = true
            self.navigationItem.leftBarButtonItem = nil
        } else {
            // If no drink is passed, text fields are enabled and the save/cancel bar buttons are shown.
            self.addPhotoButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            initializeTextFields()
            updateSaveBarButtonItemState()
            registerForKeyNotification()
            self.nameTextField.delegate = self
            self.ingredientsTextField.delegate = self
            self.directionsTextField.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var imgUrl: URL?
        
        // The image is loaded from documents if found, otherwise it is downloaded.
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let drink = drink {
            imgUrl = documentsURL.appendingPathComponent(drink.img)
        }
        
        if let imgUrl = imgUrl, FileManager.default.fileExists(atPath: imgUrl.path) {
            print("File is available")
            self.imageView.image = UIImage(contentsOfFile: imgUrl.path)
        } else {
            if NetworkReachability.shared.isConnected {
                self.imageView.image = UIImage(named: "empty_drink.png")
                guard var url = URL(string: Sites.baseURL), let stringImg = drink?.img else { return }
                url.appendPathComponent(stringImg)
                let configuration = URLSessionConfiguration.ephemeral
                let session = URLSession(configuration: configuration)
                let request = URLRequest(url: url)
                let task = session.dataTask(with: request) { [self] data, response, error in
                    if error == nil {
                        guard let data = data, let uiImage = UIImage(data: data) else { return }
                        DispatchQueue.main.sync {
                            self.imageView.image = uiImage
                        }
                        saveImageDocumentDirectory(filename: stringImg, image: uiImage)
                    }
                }
                task.resume()
            } else {
                showNoWifiAlert()
            }
        }
    }
    
    func saveImageDocumentDirectory(filename: String, image: UIImage) {
        // The image is written to Documents Directory here.
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = documents.appendingPathComponent(filename)
        if let data = image.pngData() {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to write image data to disk.")
            }
        }
    }
    
    func showNoWifiAlert() {
        // An alert is shown if there is no Wi-Fi connection.
        let alertController = UIAlertController(
            title: "Connection error",
            message: "Go to Settings?",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: "App-Prefs:root=WIFI") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func share() {
        // A share sheet is presented with the image.
        let elements = ["I created a new drink!", imageView.image as Any] as [Any]
        let avc = UIActivityViewController(activityItems: elements, applicationActivities: nil)
        avc.excludedActivityTypes = [.postToFacebook, .postToWeibo]
        self.present(avc, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        if result == .sent {
            // Something can be done here if needed.
        }
        controller.dismiss(animated: true)
    }
    
    @objc func save() {
        // This function can be used to handle additional logic if needed.
    }
    
    func updateSaveBarButtonItemState() {
        let name = nameTextField.text ?? ""
        let ingredients = ingredientsTextField.text ?? ""
        let directions = directionsTextField.text ?? ""
        saveBarButtonItem.isEnabled = !name.isEmpty && !ingredients.isEmpty && !directions.isEmpty
    }
    
    func initializeTextFields() {
        // Text fields are initialized to empty.
        nameTextField.text = ""
        ingredientsTextField.text = ""
        directionsTextField.text = ""
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if nameTextField.isEditing || ingredientsTextField.isEditing || directionsTextField.isEditing {
            moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.stackViewContainerBottomConstraint, keyboardWillShow: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.stackViewContainerBottomConstraint, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification,
                              viewBottomConstraint: NSLayoutConstraint,
                              keyboardWillShow: Bool) {
        // The view is shifted up or down based on keyboard status.
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 20
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func registerForKeyNotification() {
        // Observers are registered for keyboard show/hide notifications.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveBarButtonItemState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // The new drink data is passed to the next controller.
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "saveUnwind" else { return }
        let name = nameTextField.text!
        let ingredients = ingredientsTextField.text!
        let directions = directionsTextField.text!
        
        drink = Drink(name: name, img: "", ingredients: ingredients, directions: directions)
    }
}
