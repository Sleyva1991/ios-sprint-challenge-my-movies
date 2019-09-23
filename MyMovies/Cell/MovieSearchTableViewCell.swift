//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Steven Leyva on 9/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    @IBAction func addMovieButton(_ sender: Any) {
        delegate?.toggleHasWatched(for: self)
        
    }
}
