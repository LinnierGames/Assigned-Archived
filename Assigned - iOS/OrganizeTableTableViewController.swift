//
//  OrganizeTableTableViewController.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/23/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class OrganizeTableTableViewController: FetchedResultsTableViewController {
    
    private var delegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private var container: NSPersistentContainer? {
        return delegate?.persistentContainer
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let editingInvert = editing ? false : true
        buttonAddItem.isEnabled = editingInvert
        self.navigationItem.setHidesBackButton(editing, animated: true)
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Directory>? {
        didSet {
            if let controller = fetchedResultsController {
                do {
                    controller.delegate = self
                    try controller.performFetch()
                    
                } catch let error {
                    print("ERROR: \(error.localizedDescription)")
                }
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    open var currentDirectory: Directory? { didSet { updateUI() } }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentDirectory?.info!.title ?? "root"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let row = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.text = row.info!.title
        
        if row.isDirectory {
            cell.accessoryType = .detailDisclosureButton
        } else {
            cell.accessoryType = .detailButton
        }
        
        switch row.info! {
        case is Folder:
            cell.detailTextLabel!.text = "I am a Folder"
        case is Section:
            cell.detailTextLabel!.text = "I am a Section"
        case is Subject:
            cell.detailTextLabel!.text = "I am a Subject"
        case is Assignment:
            cell.detailTextLabel!.text = "I am an Assignment"
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Directory> = Directory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            if let hierarchy = currentDirectory {
                request.predicate = NSPredicate(format: "parent == %@", hierarchy)
            } else {
                request.predicate = NSPredicate(format: "parent = nil")
            }
            fetchedResultsController = NSFetchedResultsController<Directory>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
        }
        
    }
    
    private func prompt(withTitle promptTitle: String?, message promptMessage: String?, complition: ((UIAlertAction) -> Swift.Void)?) {
        let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .default
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: complition))
        
        self.present( alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "show assignment":
                let assignmentVC = segue.destination as! AssignmentNavigationController
                let directory = sender as! Directory
                assignmentVC.directory = directory
                
            default:
                break
            }
            
        }
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = fetchedResultsController!.object(at: indexPath)
        if tableView.isEditing {
            // navController.selectedItems.append(row)
            
        } else {
            if row.isDirectory {
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "organize table") as! OrganizeTableTableViewController
                vc.currentDirectory = row
                
                self.navigationController?.pushViewController( vc, animated: true)
                
            } else if row.info! is Assignment {
                self.performSegue(withIdentifier: "show assignment", sender: row)
                
            } else {
                assertionFailure("tableView:didSelectRowAt: -- failed to cast the selected object from row")
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowItem = fetchedResultsController!.object(at: indexPath)
        let alert = UIAlertController(title: "Update Title", message: "enter a new title", preferredStyle: .alert
        )
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: rowItem.info!.title)
        }
        alert.addAction( UIAlertAction(title: "Discard", style: .default, handler: nil))
        alert.addAction( UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            rowItem.info!.title = alert.textFields!.first!.text
            
            self!.delegate?.saveContext()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let row = fetchedResultsController!.object(at: indexPath)
            
            if let context = container?.viewContext {
                context.delete(row)
                
                delegate?.saveContext()
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonAddItem: UIBarButtonItem!
    @IBAction func pressAddItem(_ sender: Any) {
        let actionType = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if currentDirectory == nil || currentDirectory?.info! is Folder {
            
            actionType.addAction( UIAlertAction(title: "Folder", style: .default, handler: { (action) in
                let alert = UIAlertController(title: "Add a Folder", message: "enter a title", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
                    if let context = self!.container?.viewContext {
                        let newClass = Folder(context: context)
                        newClass.title = alert.textFields!.first!.text
                        
                        _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: self!.currentDirectory, in: context)
                        
                        self!.delegate?.saveContext()
                        
                        self!.updateUI()
                        
                    }
                }))
                
                self.present( alert, animated: true, completion: nil)
            }))
            
            actionType.addAction( UIAlertAction(title: "Subject", style: .default, handler: { (action) in
                let alert = UIAlertController(title: "Add a Subject", message: "enter a title", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
                    if let context = self!.container?.viewContext {
                        let newClass = Subject(context: context)
                        newClass.title = alert.textFields!.first!.text
                        
                        _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: self!.currentDirectory, in: context)
                        
                        self!.delegate?.saveContext()
                        
                        self!.updateUI()
                        
                    }
                }))
                
                self.present( alert, animated: true, completion: nil)
            }))
            
        }
        
        if currentDirectory?.info! is Subject {
            
            actionType.addAction( UIAlertAction(title: "Section", style: .default, handler: { (action) in
                let alert = UIAlertController(title: "Add a Section", message: "enter a title", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
                    if let context = self!.container?.viewContext {
                        let newClass = Section(context: context)
                        newClass.title = alert.textFields!.first!.text
                        
                        _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: self!.currentDirectory, in: context)
                        
                        self!.delegate?.saveContext()
                        
                        self!.updateUI()
                        
                    }
                }))
                
                self.present( alert, animated: true, completion: nil)
            }))
            
        }
        
        actionType.addAction( UIAlertAction(title: "Assignment", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Add an Assignment", message: "enter a title", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
                if let context = self!.container?.viewContext {
                    let newClass = Assignment(context: context)
                    newClass.dateCreated = NSDate()
                    newClass.title = alert.textFields!.first!.text
                    
                    _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: self!.currentDirectory, in: context)
                    
                    self!.delegate?.saveContext()
                    
                    self!.updateUI()
                    
                }
            }))
            
            self.present( alert, animated: true, completion: nil)
        }))
        
        actionType.addAction( UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionType, animated: true, completion: nil)
        
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: currentDirectory?.info!.title ?? "root", style: .plain, target: self, action: #selector(dismiss(animated:completion:)))
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.clearsSelectionOnViewWillAppear = true
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

}

extension OrganizeTableTableViewController
{
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    //    {   if let sections = fetchedResultsController?.sections, sections.count > 0 {
    //        return sections[section].name
    //    } else {
    //        return nil
    //        }
    //    }
    //
    //    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    //    {
    //        return fetchedResultsController?.sectionIndexTitles
    //    }
    //
    //    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    //    {
    //        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    //    }
    
}
