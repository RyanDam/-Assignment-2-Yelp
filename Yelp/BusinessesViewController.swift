//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import SwiftLoader

class BusinessesViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var searchText = ""
    
    var businesses: [Business]!
    
    var preference:Preference?
    
    let mainSearchBar = UISearchBar()
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainSearchBar.placeholder = "Search"
        mainSearchBar.tintColor = UIColor.lightGrayColor()
        mainSearchBar.delegate = self
        self.navigationItem.titleView = mainSearchBar
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.estimatedRowHeight = 10
        mainTableView.rowHeight = UITableViewAutomaticDimension
    
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, mainTableView.contentSize.height, mainTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        mainTableView.addSubview(loadingMoreView!)
        
        var insets = mainTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        mainTableView.contentInset = insets
        
        doSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchDataComplete(businesses: [Business]!, error: NSError?) {
        if error == nil {
            if let business2 = businesses {
                self.businesses = business2
                self.mainTableView.reloadData()
            }
            hideWaitingIndicate()
        }
        else {
            showErrorIndicate()
        }
    }
    
    func doSearch() {
        print("search")
        showWaitingIndicate()
        if let preference = self.preference {
            Business.searchWithTerm(self.searchText, offset: 0, sort: preference.sortBy, distance: preference.distance, categories: preference.category, deals: preference.deals, completion: fetchDataComplete)
        }
        else {
            Business.searchWithTerm(self.searchText, offset: 0, completion: fetchDataComplete)
        }
        // reset search filter after search
        //self.preference = nil
    }
    
    func showWaitingIndicate() {
        SwiftLoader.show(title: "Loading...", animated: true)
        hideErrorIndicate()
    }
    
    func hideWaitingIndicate() {
        SwiftLoader.hide()
    }
    
    func showErrorIndicate() {
        loadingMoreView?.stopAnimating()
        hideWaitingIndicate()
    }
    
    func hideErrorIndicate() {
        
    }
    
}

// MARK: Navigation

extension BusinessesViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! SettingViewController
        settingVC.preference = self.preference ?? Preference()
    }
    
    @IBAction func saveUnwind(segue: UIStoryboardSegue) {
        let settingVC = segue.sourceViewController as! SettingViewController
        self.preference = settingVC.getPreference()
        doSearch()
    }
    
    @IBAction func cancelUnwind(segue: UIStoryboardSegue) {
        
    }
}

// MARK: Table controller

extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultViewCell", forIndexPath: indexPath) as! ResultViewCell
        
        cell.titleLabel.text = self.businesses[indexPath.row].name
        cell.distanceLabel.text = self.businesses[indexPath.row].distance
        
        if let imgUrl = self.businesses[indexPath.row].imageURL {
            cell.thumbnailImage.setImageWithURL(imgUrl)
        }
        else {
            cell.thumbnailImage.image = UIImage(named: "checked")
        }
        
        cell.thumbnailImage.layer.masksToBounds = true
        cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.size.height / 2
        
        cell.ratingImage.setImageWithURL(self.businesses[indexPath.row].ratingImageURL!)
        cell.locationLabel.text = self.businesses[indexPath.row].address
        cell.reviewCountLabel.text = "\(self.businesses[indexPath.row].reviewCount!) reviews"
        cell.catalogyLabel.text = self.businesses[indexPath.row].categories
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: Search bar controller

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        doSearch()
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.mainSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.mainSearchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.text = searchText
    }
}

// MARK: Scroll controller

extension BusinessesViewController: UIScrollViewDelegate {
    
    func loadMoreDataComplete(businesses: [Business]!, error: NSError?) {
        if error == nil {
            if let business2 = businesses {
                self.businesses.appendContentsOf(business2)
                self.mainTableView.reloadData()
            }
            loadingMoreView!.stopAnimating()
        }
        else {
            showErrorIndicate()
        }
        isMoreDataLoading = false
    }
    
    func loadMoreData() {
        print("Load more data")
        
        if let preference = self.preference {
            Business.searchWithTerm(self.searchText, offset: businesses?.count ?? 0, sort: preference.sortBy, distance: preference.distance, categories: preference.category, deals: preference.deals, completion: loadMoreDataComplete)
        }
        else {
            Business.searchWithTerm(self.searchText, offset: businesses?.count ?? 0, completion: loadMoreDataComplete)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = mainTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - mainTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && mainTableView.dragging) {
                isMoreDataLoading = true
                
                let frame = CGRectMake(0, mainTableView.contentSize.height, mainTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
}
