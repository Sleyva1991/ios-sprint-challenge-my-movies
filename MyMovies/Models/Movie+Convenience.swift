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
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let hasWatched = hasWatched,
            let identifier = identrifier?.uuidString else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier , hasWatched: hasWatched)
    }
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        
    }
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier) else { return nil }
        
        self.init(context: context,
                  identifier: identifier,
                  hasWatched: hasWatched,
                  title: movieRepresentation.title
                  
                  )
    }

}
