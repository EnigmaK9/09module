//
//  ViewController.swift
//  Barman
//
//  Created by Carlos Padilla on december 13, 2024.
//

import UIKit
import GoogleSignIn
import AuthenticationServices // to handle apple id signout

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var drinks = [Drink]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedDrinks = DrinkDataManager.loadDrinks() {
            self.drinks = loadedDrinks
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newDrinkNotification),
            name: NSNotification.Name("NUEVO_DRINK"),
            object: nil
        )
        
        // Logout button on the navigation bar
        let logoutBtn = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        self.navigationItem.leftBarButtonItem = logoutBtn
    }

    @objc func logout() {
        // (4) Show a logout confirmation alert with "Yes" and "No" buttons
        let alert = UIAlertController(
            title: "Log Out",
            message: "Do you really want to log out?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            // (5) if custom login was used, remove the "customLogged" key from UserDefaults
            if UserDefaults.standard.bool(forKey: "customLogged") == true {
                // remove custom login flag from UserDefaults
                UserDefaults.standard.removeObject(forKey: "customLogged")
                UserDefaults.standard.synchronize()
            }

            // Handle Apple sign-out by removing any related flags from UserDefaults
            if UserDefaults.standard.bool(forKey: "appleLogged") == true {
                UserDefaults.standard.removeObject(forKey: "appleLogged")
                UserDefaults.standard.removeObject(forKey: "appleUserID")
                UserDefaults.standard.synchronize()
            }
            
            // Sign out from Google
            GIDSignIn.sharedInstance.signOut()
            
            // Dismiss this screen to return to the Login screen (if presented modally)
            self.dismiss(animated: true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func newDrinkNotification() {
        // the external drink object is picked up from AppDelegate if available.
        let ad = UIApplication.shared.delegate as! AppDelegate
        if let unDrink = ad.drinkExterno {
            performSegue(withIdentifier: SegueID.detail, sender: unDrink)
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID.drinkID) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = drinks[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.detail {
            let detailVC = segue.destination as! DetailViewController
            if let drink = sender as? Drink {
                detailVC.drink = drink
            } else {
                guard let indexPath = tableView.indexPathForSelectedRow else { return }
                let drink = drinks[indexPath.row]
                detailVC.drink = drink
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Deselect any row that was previously selected, for neatness
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    @IBAction func unwindToDrinkList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! DetailViewController
        
        if let drink = sourceViewController.drink {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                drinks[selectedIndexPath.row] = drink
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: drinks.count, section: 0)
                drinks.append(drink)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        DrinkDataManager.update(drinks: drinks)
    }
}
