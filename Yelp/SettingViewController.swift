//
//  SettingViewController.swift
//  Yelp
//
//  Created by Dam Vu Duy on 3/17/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class Preference {
    let milesPerMeter = 0.000621371
    var distance: Double? = nil
    var distanceCheckedIndex: Int = 0
    var sortBy: YelpSortMode?
    var sortByCheckedIndex: Int = 0
    var category: [String]?
    var categoryIndex: [Int] = []
    var deals = false
}

class SettingViewController: UIViewController {
    
    let distanceArray = ["Auto": 0.0, "0.3 miles" : 0.3, "1 mile": 1.0, "5 miles": 5.0, "20 miles": 20.0]
    var isDistanceExpanded = false
    var distanceCheckedIndex = 0
    
    let sortByArray = ["Best Match" : YelpSortMode.BestMatched, "Distance" : YelpSortMode.Distance, "Highest Rated" : YelpSortMode.HighestRated]
    var isSortByExpanded = false
    var sortByCheckedIndex = 0
    
    var categoryIndexChoosed: [Int] = []
    var isCategoryExpanded = false
    
    var isDeals = false
    
    var preference = Preference()
    
    @IBOutlet weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        self.distanceCheckedIndex = self.preference.distanceCheckedIndex
        self.sortByCheckedIndex = self.preference.sortByCheckedIndex
        self.isDeals = self.preference.deals
        self.categoryIndexChoosed = self.preference.categoryIndex
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Data provider

extension SettingViewController {
    func getDistanceTextAtIndex(index: Int) -> String {
        switch index {
        case 0:
            return "Auto"
        case 1:
            return "0.3 miles"
        case 2:
            return "1 mile"
        case 3:
            return "5 miles"
        default:
            return "20 miles"
        }
    }
    
    func getSortTextAtIndex(index: Int) -> String {
        switch index {
        case 0:
            return "Best Match"
        case 1:
            return "Distance"
        default:
            return "Highest Rated"
        }
    }
    
    func getPreference() -> Preference {
        self.preference.deals = isDeals
        self.preference.distanceCheckedIndex = self.distanceCheckedIndex
        self.preference.sortByCheckedIndex = self.sortByCheckedIndex
        self.preference.categoryIndex = categoryIndexChoosed
        
        for (key, value) in distanceArray {
            if key == getDistanceTextAtIndex(distanceCheckedIndex) {
                if value != 0.0 {
                    self.preference.distance = value / self.preference.milesPerMeter
                }
                break
            }
        }
        
        for (key, value) in sortByArray {
            if key == getSortTextAtIndex(sortByCheckedIndex) {
                self.preference.sortBy = value
                break
            }
        }
        
        if categoryIndexChoosed.count > 0 {
            var tempCatagory = [String]()
            for index in categoryIndexChoosed{
                tempCatagory.append(categories[index]["code"]!)
            }
            preference.category = tempCatagory
        }
        
        return self.preference
    }
}

// MARK: table delegate

extension SettingViewController: UITableViewDelegate, UITableViewDataSource, SettingSliderCellDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(56)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerHeight = CGFloat(56)
        let headerRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerHeight)
        let view = UIView(frame: headerRect)
        
        view.backgroundColor = UIColor.whiteColor()
        
        let labelHeight = CGFloat(22)
        let label = UILabel(frame: CGRect(x: 30, y: (headerHeight - labelHeight) / 2, width: 100, height: labelHeight))
        
        label.textColor = UIColor.lightGrayColor()
        label.font = UIFont.boldSystemFontOfSize(14)
        
        switch section {
        case 0:
            label.text = "Deals"
            break
        case 1:
            label.text = "Distance"
            break
        case 2:
            label.text = "Sort by"
            break
        case 3:
            label.text = "Category"
            break
        default:
            label.text = ""
        }
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if isDistanceExpanded {
                return distanceArray.count
            }
            return 1
        case 2:
            if isSortByExpanded {
                return sortByArray.count
            }
            return 1
        case 3:
            if isCategoryExpanded {
                return categories.count
            }
            else {
                return 4
            }
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
            // deal
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingOnOffCell", forIndexPath: indexPath) as! SettingSliderCell
            cell.delegate = self
            cell.cellTitleLabel.text = "Offering a Deal"
            cell.cellSlider.on = isDeals
            return cell
        }
        else if indexPath.section == 1 {
            // Distance
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingCheckCell", forIndexPath: indexPath) as! SettingCheckCell
            if !isDistanceExpanded {
                cell.cellMode = CheckCellState.Collapsed
                cell.cellTitle.text = getDistanceTextAtIndex(distanceCheckedIndex)
            }
            else {
                if indexPath.row == distanceCheckedIndex {
                    cell.cellMode = CheckCellState.Checked
                } else {
                    cell.cellMode = CheckCellState.Uncheck
                }
                cell.cellTitle.text = getDistanceTextAtIndex(indexPath.row)
            }
            return cell
        }
        else if indexPath.section == 2 {
            // Sort By
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingCheckCell", forIndexPath: indexPath) as! SettingCheckCell
            if !isSortByExpanded {
                cell.cellMode = CheckCellState.Collapsed
                cell.cellTitle.text = getSortTextAtIndex(sortByCheckedIndex)
            }
            else {
                if indexPath.row == sortByCheckedIndex {
                    cell.cellMode = CheckCellState.Checked
                }
                else {
                    cell.cellMode = CheckCellState.Uncheck
                }
                cell.cellTitle.text = getSortTextAtIndex(indexPath.row)
            }
            return cell
        }
        else if indexPath.section == 3 {
            if !isCategoryExpanded && indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingMoreCell")
                return cell!
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingCheckCell", forIndexPath: indexPath) as! SettingCheckCell
                if categoryIndexChoosed.contains(indexPath.row) {
                    cell.cellMode = CheckCellState.Checked
                }
                else {
                    cell.cellMode = CheckCellState.Uncheck
                }
                cell.cellTitle.text = categories[indexPath.row]["name"]
                return cell
            }
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            // Distance
            if isDistanceExpanded {
                distanceCheckedIndex = indexPath.row
            }
            self.isDistanceExpanded = !self.isDistanceExpanded
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if indexPath.section == 2 {
            // Sort by
            if isSortByExpanded {
                sortByCheckedIndex = indexPath.row
            }
            self.isSortByExpanded = !self.isSortByExpanded
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if indexPath.section == 3 {
            if indexPath.row == 3 && !isCategoryExpanded {
                isCategoryExpanded = true
            }
            else {
                if !categoryIndexChoosed.contains(indexPath.row) {
                    categoryIndexChoosed.append(indexPath.row)
                }
                else {
                    var tempCateIndex = [Int]()
                    for value in categoryIndexChoosed {
                        if value != indexPath.row {
                            tempCateIndex.append(value)
                        }
                    }
                    self.categoryIndexChoosed = tempCateIndex
                }
            }
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func onSliderToggle(sender: SettingSliderCell, switcher: UISwitch) {
        isDeals = !isDeals
    }
}

let categories = [["name" : "Afghan", "code": "afghani"],
    ["name" : "African", "code": "african"],
    ["name" : "American, New", "code": "newamerican"],
    ["name" : "American, Traditional", "code": "tradamerican"],
    ["name" : "Arabian", "code": "arabian"],
    ["name" : "Argentine", "code": "argentine"],
    ["name" : "Armenian", "code": "armenian"],
    ["name" : "Asian Fusion", "code": "asianfusion"],
    ["name" : "Asturian", "code": "asturian"],
    ["name" : "Australian", "code": "australian"],
    ["name" : "Austrian", "code": "austrian"],
    ["name" : "Baguettes", "code": "baguettes"],
    ["name" : "Bangladeshi", "code": "bangladeshi"],
    ["name" : "Barbeque", "code": "bbq"],
    ["name" : "Basque", "code": "basque"],
    ["name" : "Bavarian", "code": "bavarian"],
    ["name" : "Beer Garden", "code": "beergarden"],
    ["name" : "Beer Hall", "code": "beerhall"],
    ["name" : "Beisl", "code": "beisl"],
    ["name" : "Belgian", "code": "belgian"],
    ["name" : "Bistros", "code": "bistros"],
    ["name" : "Black Sea", "code": "blacksea"],
    ["name" : "Brasseries", "code": "brasseries"],
    ["name" : "Brazilian", "code": "brazilian"],
    ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
    ["name" : "British", "code": "british"],
    ["name" : "Buffets", "code": "buffets"],
    ["name" : "Bulgarian", "code": "bulgarian"],
    ["name" : "Burgers", "code": "burgers"],
    ["name" : "Burmese", "code": "burmese"],
    ["name" : "Cafes", "code": "cafes"],
    ["name" : "Cafeteria", "code": "cafeteria"],
    ["name" : "Cajun/Creole", "code": "cajun"],
    ["name" : "Cambodian", "code": "cambodian"],
    ["name" : "Canadian", "code": "New)"],
    ["name" : "Canteen", "code": "canteen"],
    ["name" : "Caribbean", "code": "caribbean"],
    ["name" : "Catalan", "code": "catalan"],
    ["name" : "Chech", "code": "chech"],
    ["name" : "Cheesesteaks", "code": "cheesesteaks"],
    ["name" : "Chicken Shop", "code": "chickenshop"],
    ["name" : "Chicken Wings", "code": "chicken_wings"],
    ["name" : "Chilean", "code": "chilean"],
    ["name" : "Chinese", "code": "chinese"],
    ["name" : "Comfort Food", "code": "comfortfood"],
    ["name" : "Corsican", "code": "corsican"],
    ["name" : "Creperies", "code": "creperies"],
    ["name" : "Cuban", "code": "cuban"],
    ["name" : "Curry Sausage", "code": "currysausage"],
    ["name" : "Cypriot", "code": "cypriot"],
    ["name" : "Czech", "code": "czech"],
    ["name" : "Czech/Slovakian", "code": "czechslovakian"],
    ["name" : "Danish", "code": "danish"],
    ["name" : "Delis", "code": "delis"],
    ["name" : "Diners", "code": "diners"],
    ["name" : "Dumplings", "code": "dumplings"],
    ["name" : "Eastern European", "code": "eastern_european"],
    ["name" : "Ethiopian", "code": "ethiopian"],
    ["name" : "Fast Food", "code": "hotdogs"],
    ["name" : "Filipino", "code": "filipino"],
    ["name" : "Fish & Chips", "code": "fishnchips"],
    ["name" : "Fondue", "code": "fondue"],
    ["name" : "Food Court", "code": "food_court"],
    ["name" : "Food Stands", "code": "foodstands"],
    ["name" : "French", "code": "french"],
    ["name" : "French Southwest", "code": "sud_ouest"],
    ["name" : "Galician", "code": "galician"],
    ["name" : "Gastropubs", "code": "gastropubs"],
    ["name" : "Georgian", "code": "georgian"],
    ["name" : "German", "code": "german"],
    ["name" : "Giblets", "code": "giblets"],
    ["name" : "Gluten-Free", "code": "gluten_free"],
    ["name" : "Greek", "code": "greek"],
    ["name" : "Halal", "code": "halal"],
    ["name" : "Hawaiian", "code": "hawaiian"],
    ["name" : "Heuriger", "code": "heuriger"],
    ["name" : "Himalayan/Nepalese", "code": "himalayan"],
    ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
    ["name" : "Hot Dogs", "code": "hotdog"],
    ["name" : "Hot Pot", "code": "hotpot"],
    ["name" : "Hungarian", "code": "hungarian"],
    ["name" : "Iberian", "code": "iberian"],
    ["name" : "Indian", "code": "indpak"],
    ["name" : "Indonesian", "code": "indonesian"],
    ["name" : "International", "code": "international"],
    ["name" : "Irish", "code": "irish"],
    ["name" : "Island Pub", "code": "island_pub"],
    ["name" : "Israeli", "code": "israeli"],
    ["name" : "Italian", "code": "italian"],
    ["name" : "Japanese", "code": "japanese"],
    ["name" : "Jewish", "code": "jewish"],
    ["name" : "Kebab", "code": "kebab"],
    ["name" : "Korean", "code": "korean"],
    ["name" : "Kosher", "code": "kosher"],
    ["name" : "Kurdish", "code": "kurdish"],
    ["name" : "Laos", "code": "laos"],
    ["name" : "Laotian", "code": "laotian"],
    ["name" : "Latin American", "code": "latin"],
    ["name" : "Live/Raw Food", "code": "raw_food"],
    ["name" : "Lyonnais", "code": "lyonnais"],
    ["name" : "Malaysian", "code": "malaysian"],
    ["name" : "Meatballs", "code": "meatballs"],
    ["name" : "Mediterranean", "code": "mediterranean"],
    ["name" : "Mexican", "code": "mexican"],
    ["name" : "Middle Eastern", "code": "mideastern"],
    ["name" : "Milk Bars", "code": "milkbars"],
    ["name" : "Modern Australian", "code": "modern_australian"],
    ["name" : "Modern European", "code": "modern_european"],
    ["name" : "Mongolian", "code": "mongolian"],
    ["name" : "Moroccan", "code": "moroccan"],
    ["name" : "New Zealand", "code": "newzealand"],
    ["name" : "Night Food", "code": "nightfood"],
    ["name" : "Norcinerie", "code": "norcinerie"],
    ["name" : "Open Sandwiches", "code": "opensandwiches"],
    ["name" : "Oriental", "code": "oriental"],
    ["name" : "Pakistani", "code": "pakistani"],
    ["name" : "Parent Cafes", "code": "eltern_cafes"],
    ["name" : "Parma", "code": "parma"],
    ["name" : "Persian/Iranian", "code": "persian"],
    ["name" : "Peruvian", "code": "peruvian"],
    ["name" : "Pita", "code": "pita"],
    ["name" : "Pizza", "code": "pizza"],
    ["name" : "Polish", "code": "polish"],
    ["name" : "Portuguese", "code": "portuguese"],
    ["name" : "Potatoes", "code": "potatoes"],
    ["name" : "Poutineries", "code": "poutineries"],
    ["name" : "Pub Food", "code": "pubfood"],
    ["name" : "Rice", "code": "riceshop"],
    ["name" : "Romanian", "code": "romanian"],
    ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
    ["name" : "Rumanian", "code": "rumanian"],
    ["name" : "Russian", "code": "russian"],
    ["name" : "Salad", "code": "salad"],
    ["name" : "Sandwiches", "code": "sandwiches"],
    ["name" : "Scandinavian", "code": "scandinavian"],
    ["name" : "Scottish", "code": "scottish"],
    ["name" : "Seafood", "code": "seafood"],
    ["name" : "Serbo Croatian", "code": "serbocroatian"],
    ["name" : "Signature Cuisine", "code": "signature_cuisine"],
    ["name" : "Singaporean", "code": "singaporean"],
    ["name" : "Slovakian", "code": "slovakian"],
    ["name" : "Soul Food", "code": "soulfood"],
    ["name" : "Soup", "code": "soup"],
    ["name" : "Southern", "code": "southern"],
    ["name" : "Spanish", "code": "spanish"],
    ["name" : "Steakhouses", "code": "steak"],
    ["name" : "Sushi Bars", "code": "sushi"],
    ["name" : "Swabian", "code": "swabian"],
    ["name" : "Swedish", "code": "swedish"],
    ["name" : "Swiss Food", "code": "swissfood"],
    ["name" : "Tabernas", "code": "tabernas"],
    ["name" : "Taiwanese", "code": "taiwanese"],
    ["name" : "Tapas Bars", "code": "tapas"],
    ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
    ["name" : "Tex-Mex", "code": "tex-mex"],
    ["name" : "Thai", "code": "thai"],
    ["name" : "Traditional Norwegian", "code": "norwegian"],
    ["name" : "Traditional Swedish", "code": "traditional_swedish"],
    ["name" : "Trattorie", "code": "trattorie"],
    ["name" : "Turkish", "code": "turkish"],
    ["name" : "Ukrainian", "code": "ukrainian"],
    ["name" : "Uzbek", "code": "uzbek"],
    ["name" : "Vegan", "code": "vegan"],
    ["name" : "Vegetarian", "code": "vegetarian"],
    ["name" : "Venison", "code": "venison"],
    ["name" : "Vietnamese", "code": "vietnamese"],
    ["name" : "Wok", "code": "wok"],
    ["name" : "Wraps", "code": "wraps"],
    ["name" : "Yugoslav", "code": "yugoslav"]]
