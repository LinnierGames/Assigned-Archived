//
//  AssignmentViewController.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/24/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class AssignmentViewController: UIViewController {
    
    private var delegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private var container: NSPersistentContainer? {
        return delegate?.persistentContainer
    }
    
    private var navController: AssignmentNavigationController {
        return self.navigationController as! AssignmentNavigationController
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
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - IBACTIONS
    @IBAction func pressEdit(_ sender: Any) {
        print("edit")
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
