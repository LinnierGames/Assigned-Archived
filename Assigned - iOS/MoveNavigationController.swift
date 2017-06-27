//
//  MoveNavigationController.swift
//  TEST02.2 - Infinite Folders
//
//  Created by Erick Sanchez on 6/23/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

protocol MoveTableViewControllerDelegate {
    func controller(moveTableView: MoveTableViewController, didCompleteWithParentDestination: Directory?)
}

class MoveNavigationController: UINavigationController {
    
    var parentDelegate: MoveTableViewControllerDelegate?
    
    var itemsToBeMoved: [Directory]? {
        didSet {
            if let items = itemsToBeMoved {
                navigationItem.prompt = "Select a destination for (\(items.count)) items"
            }
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
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
