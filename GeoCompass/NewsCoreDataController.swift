//
//  NewsCoreDataController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/19.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewsCoreDataController:NSObject {
    
    let store: CoreDataStore!
    let cdh: CoreDataHelper!
    
    override init() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.store = appDelegate.cdstore
        self.cdh = appDelegate.cdh
    }
    
    func fetchNewestNews(entityname:String,keyname:String)->NSFetchedResultsController {
        let fReq:NSFetchRequest = NSFetchRequest(entityName: entityname)
        let sorter:NSSortDescriptor = NSSortDescriptor(key: keyname, ascending: false)
        fReq.sortDescriptors = [sorter]
        fReq.fetchBatchSize = 20
        fReq.fetchLimit = 20
        return NSFetchedResultsController(fetchRequest: fReq, managedObjectContext: self.cdh.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //按条件检查entity是否有符合条件数据
    func fetchOneWithConditionForCheckIfExist(entityName:String,condition:NSPredicate)->[AnyObject]! {
        let fetchReq = NSFetchRequest(entityName: entityName)
        fetchReq.predicate = condition
        fetchReq.fetchLimit = 1
        var _:NSError? = nil
        do {
            return try self.cdh.managedObjectContext.executeFetchRequest(fetchReq)
        } catch _ {
            return nil
        }
    }
    
    //检查entity里是否有数据
    func fetchOneForCheckIfExist(entityName:String)->[AnyObject]! {
        let fetchReq = NSFetchRequest(entityName: entityName)
        fetchReq.fetchLimit = 1
        var _:NSError? = nil
        do {
            return try self.cdh.managedObjectContext.executeFetchRequest(fetchReq)
        } catch _ {
            return nil
        }
    }
    
    func insertForEntityWithName(entityName:String)->AnyObject! {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.cdh.managedObjectContext)
    }
    
    func EntityDescription(entityName:String)->NSEntityDescription?{
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.cdh.managedObjectContext)
    }
    
    func NSManagedObjectIt(entity:NSEntityDescription)->NSManagedObject?{
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: self.cdh.managedObjectContext)
    }
    
    func FetchedResultsController(entityname:String)->NSFetchedResultsController?{
        let fReq:NSFetchRequest = NSFetchRequest(entityName: entityname)
        return NSFetchedResultsController(fetchRequest: fReq, managedObjectContext: self.cdh.managedObjectContext, sectionNameKeyPath: entityname, cacheName: "Root")
    }
    
    //删除一个entity里的所有数据
    func deleteOneEntityAllData(entityName:String) {
        let fReq:NSFetchRequest = NSFetchRequest(entityName: entityName)
        var result: [AnyObject]?
        do {
            result = try self.cdh.backgroundContext.executeFetchRequest(fReq)
        } catch let error as NSError {
            if error != 0 {
             result = nil
            }
        }
        for resultItem:AnyObject in result! {
            self.cdh.backgroundContext.deleteObject(resultItem as! NSManagedObject)
        }
        self.save()
    }
    
    func save() {
        self.cdh.saveContext(self.cdh.managedObjectContext)
    }
}