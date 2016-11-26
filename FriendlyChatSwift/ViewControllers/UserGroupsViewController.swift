//
//  UserGroupsViewController.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 11/22/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//
// TODO : Create Group model
// Create custom table View Cell
// 

import UIKit

class UserGroupsViewController: UIViewController {

    @IBOutlet weak var groupsTable: UITableView!
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        populateNavBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindTableView() {
        self.groupsTable.dataSource = self;
        self.groupsTable.delegate = self;
        self.groupsTable.register(UINib(nibName: "GroupsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: GroupsTableViewCell.reuseID)
        FirebaseUtils.sharedInstance.groupsForCurrentUser {[weak self] (groups) in
            guard let strongSelf = self else {return}
            strongSelf.groups = groups
            self?.groupsTable.reloadData()
        }
    }
    
    func populateNavBar() {
        self.title = "Hello \(FirebaseUtils.sharedInstance.authUser?.displayName ?? "user")"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutCurrentUser))
    }
    
    func signOutCurrentUser() {
        print("TODO : signout current user");
    }

}

extension UserGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return tableViewCell
        let cell = self.groupsTable.dequeueReusableCell(withIdentifier: GroupsTableViewCell.reuseID) as! GroupsTableViewCell
        cell.group = groups[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}

extension UserGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedGroup = groups[indexPath.row];
//        let groupMessagesVC = UserGroupsMessageExtensionViewController()
//        groupMessagesVC.selectedGroup = selectedGroup
//        navigationController?.pushViewController(groupMessagesVC, animated: true)
        
        let groupMessagesVC = MovieViewController()    
        navigationController?.pushViewController(groupMessagesVC, animated: true)
        // Touched row at indexpath
    }
}
