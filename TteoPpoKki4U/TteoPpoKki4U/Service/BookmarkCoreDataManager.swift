//
//  BookmarkCoreData.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/12.
//

import Foundation
import CoreData

class BookmarkCoreDataManager {
    static let shared = BookmarkCoreDataManager()
        
        private init() {}
        
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Bookmark")
            container.loadPersistentStores { storeDescription, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        
        var context: NSManagedObjectContext {
            return persistentContainer.viewContext
        }
        
        func saveContext() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        // 추가적으로 Core Data 작업 메서드를 여기에 작성할 수 있습니다.
        func saveItem(isBookmarked: Bool) {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Bookmark", into: context)
            newItem.setValue(isBookmarked, forKey: "isBookmarked")
            
            do {
                try context.save()
                print("Item saved!")
            } catch {
                print("Failed to save item: \(error)")
            }
        }

//        func fetchItems() -> [Bookmarked] {
//            let fetchRequest = NSFetchRequest<Bookmarked>(entityName: "Bookmarked")
//            
//            do {
//                let bookmarked = try context.fetch(fetchRequest)
//                return bookmarked
//            } catch {
//                print("Failed to fetch items: \(error)")
//                return []
//            }
//        }
}
