//
//  Directory.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/23/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Directory {
    
    static func createDirectory( forDirectoryInfo info: DirectoryInfo, withParent parent: Directory?, `in` context: NSManagedObjectContext) -> Directory {
        let newHierarchy = Directory(context: context)
        newHierarchy.parent = parent
        
        newHierarchy.info = info
        
        return newHierarchy
        
    }
    
    static func fetchDirectoryWithParentDirectory(_ directory: Directory?, `in` context: NSManagedObjectContext) -> [Directory] {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if directory == nil {
            fetch.predicate = NSPredicate(format: "parent == nil")
        } else {
            fetch.predicate = NSPredicate(format: "parent == %@", directory!)
        }
        
        var result = [Directory]()
        
        if let newResult = try? context.fetch(fetch) {
            for hierarchy in newResult {
                result.append( hierarchy)
                
            }
            
        }
        
        return result
        
    }
    
    var isDirectory: Bool {
        return (self.info! is Folder || self.info! is Subject)
    }
    
}
