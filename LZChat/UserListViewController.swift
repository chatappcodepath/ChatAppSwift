//
//  UserListViewController.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/23/16.
//  Copyright © 2016 Google Inc. All rights reserved.
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
    var userList = [LZUser]()
    var delegate:UserListViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Back"
        bindViews()
        fetchDataSource()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindViews() {
        self.userListTableView.register(UINib(nibName: UserTableViewCell.nibName, bundle: Bundle.main), forCellReuseIdentifier: UserTableViewCell.reuseID)
        self.userListTableView.dataSource = self
        self.userListTableView.delegate = self
    }

    func fetchDataSource() {
        FirebaseUtils.sharedInstance.listAllUsers { [weak self] (users) in
            guard let strongSelf = self else {return}
            strongSelf.userList = users
            strongSelf.userListTableView.reloadData()
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseID) as! UserTableViewCell
        userCell.displayUser = userList[indexPath.row]
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
        let selectedUser = userList[indexPath.row]
        self.delegate?.didSelectUser(selectedUser)
    }
}







