//
//  LoginInterface.swift
//  Barman
//
//  Created by Ángel González on 07/12/24.
//

import Foundation
import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginInterface: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    // TODO: Detectar la conexión a Internet
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    let actInd = UIActivityIndicatorView(style: .large)
    // TODO: implementar cuando debe aparecer y desaparecer el activity indicator
    
    func detectaEstado () { // revisa si el usuario ya inició sesión
        // TODO: si es customLogin, hay que revisar en UserDefaults
        
        // si esta loggeado con AppleId
        
        
        // si esta loggeado con Google
        GIDSignIn.sharedInstance.restorePreviousSignIn { usuario, error in
            guard let perfil = usuario else { return }
            print ("usuario: \(perfil.profile?.name ?? ""), correo: \(perfil.profile?.email ?? "")")
            self.performSegue(withIdentifier:"loginOK", sender:nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detectaEstado()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reutilizar custom login para que el usuario acceda por mi backend
        let loginVC = CustomLoginViewController()
        // agregar la lógica de ejecución del controller:
        self.addChild(loginVC)
        loginVC.view.frame = CGRect(x:0, y:45, width:self.view.bounds.width, height:self.view.bounds.width)
        // agregamos la vista de customlogin como subvista
        self.view.addSubview(loginVC.view)
        // agregar boton para login con appleID
        let appleIDBtn = ASAuthorizationAppleIDButton()
        self.view.addSubview(appleIDBtn)
        appleIDBtn.center = self.view.center
        appleIDBtn.frame.origin.y = loginVC.view.frame.maxY + 10
        appleIDBtn.addTarget(self, action:#selector(appleBtnTouch), for:.touchUpInside)
        let googleBtn = GIDSignInButton(frame:CGRect(x:0, y:appleIDBtn.frame.maxY + 10, width: appleIDBtn.frame.width, height:appleIDBtn.frame.height) )
        googleBtn.center.x = self.view.center.x
        self.view.addSubview(googleBtn)
        googleBtn.addTarget(self, action:#selector(googleBtnTouch), for:.touchUpInside)
    }
    
    @objc func googleBtnTouch () {
        GIDSignIn.sharedInstance.signIn(withPresenting:self){ resultado, error in
            if error != nil {
                Utils.showMessage("jiuston... \(error?.localizedDescription)")
            }
            else {
                guard let perfil = resultado?.user else { return }
                print ("usuario: \(perfil.profile?.name), correo: \(perfil.profile?.email)")
                self.performSegue(withIdentifier: "loginOK", sender: nil)
            }
        }
    }
    
    @objc func appleBtnTouch () {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests:[request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
}
