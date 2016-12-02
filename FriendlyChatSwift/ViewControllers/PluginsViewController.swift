//
//  PluginsViewController.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 11/26/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit


class PluginsViewController: MultiPageController {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        reloadData()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource = self
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PluginsViewController : MultiPageControllerDataSource {
    func multiPageController(_ multiPageController: MultiPageController, previewViewAt index: Int) -> UIView {
        let label = UILabel()
        label.text = index == 0 ? "Movie" : "Tic-Tac-Toe"
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }
    
    func numberOfItems(in: MultiPageController) -> Int {
        return 2
    }
    
    func multiPageController(_ multiPageController: MultiPageController, viewControllerAt index: Int) -> UIViewController {
        var viewController: UIViewController;
        if (index == 0) {
            viewController = MovieViewController(nibName: "MovieViewController", bundle: Bundle.main)
        } else {
            viewController = TicTacToeViewController(nibName: "TicTacToeViewController", bundle: Bundle.main)
        }
        
        return viewController
    }
}

