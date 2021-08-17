//
//  ViewController.swift
//  StoreSearch
//
//  Created by Ahmed Essmat on 12/06/2021.
//

import UIKit

class StoreSearchVC: UIViewController {

@IBOutlet var searchBar: UISearchBar!
@IBOutlet var tableView: UITableView!
@IBOutlet var segmentedControl: UISegmentedControl!
  
    
    var searchResults = [SearchResult]()
var hasSearched = false
var isLoading = false
var dataTask: URLSessionDataTask?
    
enum TableView {
    enum CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
}



override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
    
    var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    
    searchBar.becomeFirstResponder()
}


@IBAction func segmentChanged(_ sender: UISegmentedControl) {
    print("Segment changed: \(sender.selectedSegmentIndex)")
    peformSearch()
    }
    
//MARK: - Helper Methods
func itunesURL(searchText: String, category: Int) -> URL {
    let kind: String
    switch category {
    case 1: kind = "musicTrack"
    case 2: kind = "software"
    case 3: kind = "ebook"
    default: kind = ""
    }
    let encodingText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let urlString = String(format: "https://itunes.apple.com/search?" + "term=%@&limit=200&entity=\(kind)",encodingText)
    let url = URL(string: urlString)
    return url!
}


func parse(data: Data) -> [SearchResult] {
    do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResultArray.self, from: data)
        return result.results
    }catch {
        print("JSON Error: \(error)")
        return []
    }
}

func showNetworkError(){
    let alert = UIAlertController(title: "Whooops....", message: "There was an error accessing the Itunes Store. Please try again", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
}

}





//MARK: - Search Bar Delegate
extension StoreSearchVC: UISearchBarDelegate {

func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    peformSearch()
}
    
func peformSearch() {
    
    searchBar.resignFirstResponder()
    isLoading = true
    tableView.reloadData()
    
    if !searchBar.text!.isEmpty {
        dataTask?.cancel()
        hasSearched = true
        searchResults = []
        
        let url = itunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let httpsResponse = response as? HTTPURLResponse, httpsResponse.statusCode == 200 {
                if let data = data {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            } else {
                print("Failure!\(response!)")
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.hasSearched = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
        }
        dataTask?.resume()
    }
}

func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
}
}

//MARK: -Table View Delegate
extension StoreSearchVC: UITableViewDelegate, UITableViewDataSource {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if isLoading {
        return 1
    } else if !hasSearched {
        return 0
    } else if searchResults.count == 0 {
        return 1
    } else {
        return searchResults.count
    }
    
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cellIdentifier = TableView.CellIdentifiers.searchResultCell
    
    if isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
        return cell
    } else
    if searchResults.count == 0 {
        return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.name.text = searchResult.name
            if searchResult.artist.isEmpty {
                cell.artistName.text  = "Unknown"
            }else {
                cell.artistName.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }
            return cell
        }
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
}

func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if searchResults.count == 0 || isLoading {
        return nil
    } else {
        return indexPath
    }
}


}

