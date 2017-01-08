//
//  UserGroupsViewController.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/22/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//
// TODO : Create Group model
// Create custom table View Cell
// 

import UIKit
import Firebase

class UserGroupsViewController: UIViewController {

    @IBOutlet weak var groupsTable: UITableView!
    var _groups = [Group]()
    var groups: [Group] {
        get {
            return _groups
        }
        set {
            
            let oldGids = _groups.map { (group) -> String in
                return "\(group.id!):\(group.ts!)"
            }
            
            _groups = newValue.sorted(by: { (group1, group2) -> Bool in
                return group1.ts! > group2.ts!
            })
            
            let newGids = _groups.map { (group) -> String in
                return "\(group.id!):\(group.ts!)"
            }
            
            if (oldGids.joined() == newGids.joined()) {
                return
            }
            
            self.groupsTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        populateNavBar()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Hello \(FirebaseUtils.sharedInstance.authUser?.displayName ?? "user")"
        FirebaseUtils.sharedInstance.groupsForCurrentUser {[weak self] (groups) in
            guard let strongSelf = self else {return}
            strongSelf.groups = groups
        }
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
        }
    }
    
    func populateNavBar() {
        self.title = "Hello \(FirebaseUtils.sharedInstance.authUser?.displayName ?? "user")"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutCurrentUser))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Chat", style: .plain, target: self, action: #selector(startNewConversation))
    }
    
    func startNewConversation() {
        let userListVC = UserListViewController()
        userListVC.delegate = self
        self.navigationController?.pushViewController(userListVC, animated: true)
    }
    
    func signOutCurrentUser() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.signOut()
        }
    }

}

extension UserGroupsViewController: UserListViewControllerDelegate {
    func didSelectUser(_ selectedUser: LZUser) {
        //selected User
        _ = self.navigationController?.popToRootViewController(animated: false)
        if let selectedUserID = selectedUser.id,
            let currentUserID = FirebaseUtils.sharedInstance.authUser?.uid {
            for group in groups {
                if (group.containsOnlyUIDs(uids: [selectedUserID, currentUserID])) {
                    displayMessagesForGroup(group, animated: false)
                    return
                }
            }
            
            let currentUser = LZUser(withFIRUser: FirebaseUtils.sharedInstance.authUser)
            createNewGroupAndDisplay(users: [selectedUser, currentUser])
        }
    }
    
    func createNewGroupAndDisplay(users: [LZUser]) {
        // create a group with given uids...
        let newGroup = FirebaseUtils.sharedInstance.createNewGroup(withUsers: users)
        displayMessagesForGroup(newGroup, animated: false)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // make the call to get the image and then call the cell.updateImage
        guard let cell = cell as? GroupsTableViewCell else {
            return
        }
        cell.fetchImage()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancel the operation.
        guard let cell = cell as? GroupsTableViewCell else {
            return
        }
        cell.cancelImageFetching()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}

extension UserGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedGroup = groups[indexPath.row];
        displayMessagesForGroup(selectedGroup, animated: true)
        // Touched row at indexpath
    }
    
    func displayMessagesForGroup(_ selectedGroup: Group, animated: Bool) {
        let groupMessagesVC = GroupMessagesViewController()
        groupMessagesVC.group = selectedGroup
        navigationController?.pushViewController(groupMessagesVC, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupsTableViewCell.cellHeight
    }
}
