//
//  RepoListController.swift
//  RepoList_TestApp
//
//  Created by apple on 07.12.2020.
//

import UIKit

class RepoListController: UIViewController {
    
    // MARK:- Outlets and properties
    @IBOutlet weak var repoListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var repositories = [String]()
    var searchedArray = [String]()
    var searchedPartArray = [String]()
    var isSearching = false
    
    var searchString: String? = nil {
        didSet {
            print(searchString ?? "")
            self.repoListTableView.reloadData()
        }
    }
    
    // MARK:- Viewcontroller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        searchBar.delegate = self
        fetchData()
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 40, width: screenSize.width, height: 60))
        let navItem = UINavigationItem(title: "List of repositories")
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    //MARK:- Fetch Data
    func fetchData(){
        let url = URL(string :"https://api.github.com/search/repositories?q=learn+swift+language:swift&sort=stars&order=desc")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print("Error found like \(String(describing: error))")
            }
            if data != nil{
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any]
                    
                    if ((jsonData?.count)! >= 1) {
                        
                        if let reposArray = jsonData?["items"] as? [NSDictionary] {
                            
                            for item in reposArray {
                                
                                // let valueURLs = item["html_url"]
                                let valueURLs = item["name"]
                                self.repositories.append(valueURLs as! String)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.repoListTableView.reloadData()
                        }
                    }
                    
                } catch  {
                    print("catch an exception \(error)")
                }
            }
        }
        task.resume()
    }
}


// MARK: - Extension
extension RepoListController : UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table view DataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedArray.count
        }
        
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if isSearching {
            cell.textLabel?.text = searchedArray[indexPath.row]
        }
        else{
            cell.textLabel?.text = repositories[indexPath.row]
        }
        
        return cell
    }
    
    // Mark: - Table view Delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension RepoListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchBar.text
        self.searchedArray.removeAll()
        
        let queue = DispatchQueue(label: "MyArrayQueue", attributes: .concurrent)
        
        queue.async(flags: .barrier) {
            self.searchedArray =  self.repositories.chunked(into: 15)[0].filter ({ $0.prefix(searchText.count) == searchText})
        }
        
        queue.sync() {
            self.searchedPartArray =   self.repositories.chunked(into: 15)[1].filter ({ $0.prefix(searchText.count) == searchText})
        }
        
        self.searchedArray.append(contentsOf:  self.searchedPartArray)
        
        if(searchedArray.count == 0){
            isSearching = false
        } else {
            isSearching = true
        }
        repoListTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        isSearching = false
        searchBar.text = ""
        searchBar.endEditing(true)
        repoListTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
}
