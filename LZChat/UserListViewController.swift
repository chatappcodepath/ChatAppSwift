//
//  UserListViewController.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/23/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
//
// 1) Get the data
// 2) Bind the table
// 3) Make the cell
// 4) populate the cells

import UIKit

protocol UserListViewControllerDelegate {
    func didSelectUser(_ selectedUser: LZUser)
}

class UserListViewController: UIViewController {

    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var userList:[LZUser]? {
        didSet {
            filteredUsers = userList
        }
    }
    var filteredUsers:[LZUser]? {
        didSet {
            if let old = oldValue,
                let filtered = filteredUsers {
                if (old == filtered) {
                    return
                }
            }
            userListTableView.reloadData()
        }
    }
    var delegate:UserListViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Back"
        bindViews()
        fetchDataSource()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func bindViews() {
        self.userListTableView.register(UINib(nibName: UserTableViewCell.nibName, bundle: Bundle.main), forCellReuseIdentifier: UserTableViewCell.reuseID)
        self.userListTableView.dataSource = self
        self.userListTableView.delegate = self
        self.searchBar.delegate = self
    }

    func fetchDataSource() {
        FirebaseUtils.sharedInstance.listAllUsers{ [weak self] (users) in
            guard let strongSelf = self else {return}
            strongSelf.userList = users
        }
    }
}

extension UserListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            filteredUsers = userList
            return
        }
        
        let newfilteredUsers = userList?.filter({ (user) -> Bool in
            if let userName = user.name?.lowercased(),
                let userEmail = user.email?.lowercased() {
                let lowerCaseSearchTerm = searchText.lowercased()
                let retVal = userName.contains(lowerCaseSearchTerm) || userEmail.contains(lowerCaseSearchTerm)
                return retVal
            }
            return false
        })
        
        filteredUsers = newfilteredUsers
    }
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filteredUsers = filteredUsers else {
            return 0
        }
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseID) as! UserTableViewCell
        userCell.displayUser = filteredUsers![indexPath.row]
        return userCell
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // willDisplayCell
        guard let cell = cell as? UserTableViewCell else {return}
        cell.fetchImage()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // didEndDisplayingCell
        guard let cell = cell as? UserTableViewCell else {return}
        cell.cancelImageFetching()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = filteredUsers![indexPath.row]
        self.delegate?.didSelectUser(selectedUser)
    }
}







