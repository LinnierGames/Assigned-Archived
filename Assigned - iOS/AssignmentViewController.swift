//
//  AssignmentViewController.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/24/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class AssignmentViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private var delegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private var container: NSPersistentContainer? {
        return delegate?.persistentContainer
    }
    
    private var navController: AssignmentNavigationController {
        return self.navigationController as! AssignmentNavigationController
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Task>? {
        didSet {
            if let controller = fetchedResultsController {
                do {
                    controller.delegate = self
                    try controller.performFetch()
                    
                    tableView.reloadData()
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = navController.directory!.info!.title
        }
    }
    
    @IBOutlet weak var textviewNotes: UITextView! {
        didSet {
            textviewNotes.text = (navController.directory!.info! as! Assignment).notes
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - RETURN VALUES
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let row = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.text = row.title
        cell.accessoryType = .detailButton
        if row.isCompleted {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: row.title!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel!.attributedText = attributeString
            cell.textLabel!.alpha = CTDisabledOpeque
        } else {
            cell.textLabel!.attributedText = NSAttributedString(string: row.title!)
            cell.textLabel!.alpha = 1
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if let context = container?.viewContext {
            let fetch: NSFetchRequest<Task> = Task.fetchRequest()
            fetch.sortDescriptors = [NSSortDescriptor(key: "isCompleted", ascending: true), NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
            fetch.predicate = NSPredicate(format: "assignment == %@", navController.directory!.info! as! Assignment)
            fetchedResultsController = NSFetchedResultsController<Task>(
                fetchRequest: fetch,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
    }
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = fetchedResultsController!.object(at: indexPath)
        
        row.isCompleted = row.isCompleted ? false : true
        
        delegate?.saveContext()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let row = fetchedResultsController!.object(at: indexPath)
            
            if let context = container?.viewContext {
                context.delete(row)
                
                delegate?.saveContext()
            }
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: "Rename Item", message: "enter a title", preferredStyle: .alert)
        alert.addTextField { [weak self] (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: self!.fetchedResultsController?.object(at: indexPath).title)
        }
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] (action) in
            self!.fetchedResultsController?.object(at: indexPath).title = alert.textFields!.first!.text
            
            self!.delegate?.saveContext()
            
        }))
        
        self.present( alert, animated: true, completion: nil)
    }
    
    // MARK: - IBACTIONS
    @IBAction func pressEdit(_ sender: Any) {
        print("edit")
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressAddTask(_ sender: Any) {
        let alert = UIAlertController(title: "New Item", message: "enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
        }
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] (action) in
            if let context = self!.container?.viewContext {
                let newTask = Task(context: context)
                newTask.title = alert.textFields!.first!.text
                
                newTask.assignment = self!.navController.directory!.info! as? Assignment
                
                self!.delegate?.saveContext()
            }
            
        }))
        
        self.present( alert, animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AssignmentViewController
{
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {   if let sections = fetchedResultsController?.sections, sections.count > 0 {
        return sections[section].name
    } else {
        return nil
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return fetchedResultsController?.sectionIndexTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
}
