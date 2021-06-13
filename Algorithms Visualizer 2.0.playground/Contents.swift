
import UIKit
import PlaygroundSupport

var pathFindingViewController = PathFindingViewController()
var pathFindingNavigationController = UINavigationController(rootViewController: pathFindingViewController)

var sortingViewController = SortingAlgorithmsViewController()
var sortingNavigationController = UINavigationController(rootViewController: sortingViewController)


sortingNavigationController.tabBarItem.image = UIImage(systemName: "chart.bar")
pathFindingNavigationController.tabBarItem.image = UIImage(systemName: "arrow.2.squarepath")
var tabViewController = UITabBarController()
tabViewController.viewControllers = [sortingNavigationController , pathFindingNavigationController]


tabViewController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
PlaygroundPage.current.liveView = tabViewController



