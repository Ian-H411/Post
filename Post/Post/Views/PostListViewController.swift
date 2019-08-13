//
//  PostListViewController.swift
//  Post
//
//  Created by Ian Hall on 8/12/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postController = PostController()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.reloadTableView()
        
            }
        }
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
         refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            DispatchQueue.main.async { self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func reloadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) + \(post.timestamp)"
        return cell
    }
    func presentNewPostAlert(){
        ///if its empty use me
        let badAlert = UIAlertController(title: "INVALID", message: "please fill out all fields", preferredStyle: .alert)
        badAlert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
            self.presentNewPostAlert()
            return
        }))
        /////// if they did it right use me
        let alert = UIAlertController(title: "add a new Post", message: "please be kind ", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        alert.addTextField { (textfield) in
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            guard let userName = alert.textFields?[0].text else {return}
            guard let text = alert.textFields?[1].text else {return}
            if text == "" || userName == ""{
                self.present(badAlert, animated: true, completion: nil)
            }
            self.postController.addNewPostWith(username: userName, text: text, completion: {
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}
extension PostListViewController{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) {
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            }
        }
    }
}
