//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let baseURL2 = URL(string: "https://my-movie-4d418.firebaseio.com/")!
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL2
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Movie Representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie representation: \(error) ")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error PUTing movie: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func fetchTasksFromServer(completion: @escaping () -> Void = { }) {
        
        let requestURL = baseURL2.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion()
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let movieRepresentations = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value})
                
                self.updateMovies(with: movieRepresentations)
                
            } catch {
                NSLog("Error decoding: \(error)")
            }
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var tasksToCreate = representationsByID
        
        do {
            let context = CoreDataStack.shared.mainContext
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "idfentifier IN %@", identifiersToFetch)
            
            let existingMovies = try context.fetch(fetchRequest)
            
            for movie in existingMovies {
                guard let identifier = movie.identifier,
                    let representation = representationsByID[identifier] else { continue }
                
                movie.title = representation.title
                movie.hasWatched = representation.hasWatched ?? false
                
                tasksToCreate.removeValue(forKey: identifier)
            }
            
            for representation in tasksToCreate.values {
                Movie(movieRepresentation: representation, context: context)
            }
            CoreDataStack.shared.saveToPersistentStore()
        } catch {
            NSLog("Error fetching movies from persistent store: \(error)")
        }
    }
    
    @discardableResult func createMovie(with title: String, hasWatched: Bool) -> Movie {
        
        let movie = Movie(title: title, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
        
        CoreDataStack.shared.saveToPersistentStore()
        put(movie:movie)
        
        return movie
    }
    
    func updateMovie(movie: Movie, with title: String, hasWatched: Bool) {
        
        movie.title = title
        movie.hasWatched = hasWatched
        put(movie: movie)
        
        CoreDataStack.shared.saveToPersistentStore()
        
    }
    
    func delete(movie: Movie) {
        
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
