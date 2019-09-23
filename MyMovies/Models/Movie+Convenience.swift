//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Steven Leyva on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
        
    }
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier , hasWatched: hasWatched)
    }
}
