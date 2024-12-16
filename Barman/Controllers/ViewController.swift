//
//  ViewController.swift
//  Barman
//
//  Created by Carlos Padilla on 2024 December 13.
//

import UIKit
import GoogleSignIn

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
        
        let logoutBtn = UIBarButtonItem(
            image: UIImage(systemName:"rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        self.navigationItem.leftBarButtonItem = logoutBtn
    }

    @objc func logout() {
        // A confirmation alert is shown before logging out.
        let alert = UIAlertController(
            title: "Logout",
            message: "Do you really want to log out?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            // If it is customLogin, the key is removed from UserDefaults.
            if UserDefaults.standard.bool(forKey: "customLogged") == true {
                UserDefaults.standard.removeObject(forKey: "customLogged")
                UserDefaults.standard.synchronize()
            }
            
            // If an AppleId was used (not shown here).
            
            // Google session is signed out.
            GIDSignIn.sharedInstance.signOut()
            
            // This screen is dismissed to return to login.
            self.dismiss(animated: true)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func newDrinkNotification() {
        // The external drink object is picked up from AppDelegate if available.
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
        // Any selected row is deselected here for neatness.
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
