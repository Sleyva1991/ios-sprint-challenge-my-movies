//
//  MovieSearchTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Steven Leyva on 9/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchTableViewCellDelegate: class {
    func toggleHasWatched(for cell: MovieSearchTableViewCell)
}
