//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Sid Sarao on 4/15/15.
//  Copyright (c) 2015 Sid Sarao. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
 
    @IBOutlet weak var networkErrorLabel: UILabel!

    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        SVProgressHUD.show()
        
        // Refresh parameters below
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
        
        //let url = NSURL(string: "http://sdfsdfsd.com")!
        
        let request = NSURLRequest(URL: url)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            //println(data)
            if ((error) != nil) {  //Network error
                //println("Error seen")
                self.networkErrorLabel.hidden = false
            }
            
            
            if (data != nil){   // Adding for network error check
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                println(error)
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.networkErrorLabel.hidden = true
                }
                
            }
            
            
            
        }
        
        
        

        
        
        SVProgressHUD.dismiss()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell =  tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        //cell.textLabel?.text = movie["title"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(url)

        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //refresh fuctions
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        SVProgressHUD.show()
        
        let cell = sender as! UITableViewCell
        let indexpath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexpath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailsViewController.movie = movie
        
        SVProgressHUD.dismiss()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if var indexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
}

