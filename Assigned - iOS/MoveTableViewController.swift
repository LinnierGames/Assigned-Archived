//
//  MoveTableViewController.swift
//  TEST02.2 - Infinite Folders
//
//  Created by Erick Sanchez on 6/23/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class MoveTableViewController: UITableViewController {
    
    private var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private var container: NSPersistentContainer? {
        return appDelegate.persistentContainer
    }
    
    private var navController: MoveNavigationController {
        return navigationController as! MoveNavigationController
    }
    
    private var arrayM = [Directory]()
    
    var currentDirectory: Directory?
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayM.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let row = arrayM[indexPath.row]
        let rowItem = row.info!

        // Configure the cell...
        cell.textLabel!.text = rowItem.title ?? "Untitled"
        if row.isDirectory {
            cell.accessoryType = .disclosureIndicator
            if let count = row.childrenInfo["Folder"] {
                cell.detailTextLabel!.text = "Sub Folders (\(String(count)))"
            } else {
                cell.detailTextLabel!.text = "No Sub Folders"
            }
            cell.setState(enabled: true)
        } else {
            cell.accessoryType = .none
            cell.detailTextLabel!.text = nil
            cell.setState(enabled: false)
        }
        
        //Avoid moving an item within itself
        if (navController.itemsToBeMoved?.contains(row))! {
            cell.setState(enabled: false)
        }

        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if currentDirectory != nil {
            arrayM = currentDirectory?.children?.allObjects as! [Directory]
            
        } else {
            if let context = container?.viewContext {
                arrayM = Directory.fetchDirectoryWithParentDirectory(currentDirectory, in: context)
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = arrayM[indexPath.row]
        if row.isDirectory {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "moveVC") as! MoveTableViewController
            vc.navigationItem.prompt = self.navigationItem.prompt
            vc.currentDirectory = row
            
            self.navigationController?.pushViewController( vc, animated: true)
            
        }
        
    }
    
    // MARK: - IBACTIONS
    
    @IBAction func pressDone(_ sender: Any) {
        //#warning MISSING VALIDATION of moving items within other limited items
        //e.g. moving a folder inside a subject, etc
        if let items = navController.itemsToBeMoved {
            for item in items {
                item.parent = currentDirectory
            }
            appDelegate.saveContext()
            navController.parentDelegate?.controller(moveTableView: self, didCompleteWithParentDestination: currentDirectory)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
