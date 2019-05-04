//
//  SelectColorTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/4.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class SelectColorTableViewController: UITableViewController {

    var selectedColor: UIColor? = nil
    var colors = [UIColor]()
    var colorNames = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple, UIColor.brown]
        colorNames = ["Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Brown"]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        cell.textLabel?.text = colorNames[indexPath.row]
        cell.imageView?.tintColor = colors[indexPath.row]
        if cell.imageView?.tintColor == selectedColor {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "colorSelectedUnwind":
            let addEditProjectViewController = segue.destination as! AddEditProjectTableViewController
            selectedColor = colors[tableView.indexPathForSelectedRow!.row]
            addEditProjectViewController.currentColor = selectedColor
        default:
            break
        }
    }

}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
