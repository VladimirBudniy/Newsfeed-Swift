//
//  MainViewController.swift
//  Newsfeed-Swift
//
//  Created by Vladimir Budniy on 12/29/16.
//  Copyright © 2016 Vladimir Budniy. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa


class MainViewController: UIViewController, ViewControllerRootView, UITableViewDataSource, UITableViewDelegate {
    
    typealias RootViewType = MainView

    var barTitle: String = "Всі новини"
    
    var helveticaTextType: String = "HelveticaNeue-Medium"
    
    var newsArray: Array<News>? {
        didSet {
            self.reloadView()
        }
    }
    
    var tableView: UITableView? {
        return self.rootView.tabelView
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingNavigationBar()
        self.addRefreshControl()
        self.registerCellWithIdentifier(identifier: String(describing: MainViewCell.self))
        self.loadNews(for: self.barTitle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        cleanCache()
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainViewCell.self)) as! MainViewCell
        cell.fillWithNews(news: (self.newsArray?[indexPath.row])!)
        
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let controller = NewsViewController(news: self.newsArray?[indexPath.row])
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Private

    private func reloadView() {
        self.tableView?.reloadData()
        self.tableView?.refreshControl?.endRefreshing()
        self.rootView.removeSpinnerView()
    }
    
    private func addRefreshControl() {
        self.tableView?.refreshControl = self.customRefreshControl()
    }
    
    private func registerCellWithIdentifier(identifier: String) {
        self.tableView?.register(UINib(nibName: identifier, bundle: nil),
                                 forCellReuseIdentifier: identifier)
    }
    
    private func settingNavigationBar() {
        self.customNavigationItem(imageButton: UIImage(named: "categories")!)
        self.customNavigationBar()
    }
    
    @objc private func onOpenRight() {
        self.slideMenuController()?.openRight()
    }
    
    @objc private func load() {
        self.loadNews(for: self.barTitle)
    }
    
    private func loadNews(for category: String) {
        self.rootView.showSpinner()
        LoadModel.loadNewsByCategory(category: category)
            .observe(on: UIScheduler())
            .startWithResult({ result in
                self.newsArray = result.value
            })
    }
    
    private func customNavigationItem(imageButton: UIImage) {
        let navigationItem = self.navigationItem
        navigationItem.title = self.barTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageButton,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onOpenRight))
    }
    
    private func customNavigationBar() {
        let navigationBar = self.navigationController?.navigationBar
        let attribute = [NSForegroundColorAttributeName: UIColor.white,
                         NSFontAttributeName: UIFont(name: helveticaTextType, size: 16)!]
        navigationBar?.titleTextAttributes = attribute
        navigationBar?.tintColor = UIColor.white
        navigationBar?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
    
    private func customRefreshControl() -> UIRefreshControl {
        let control = UIRefreshControl()
        let attribute = [NSForegroundColorAttributeName: UIColor.white,
                         NSFontAttributeName: UIFont(name: helveticaTextType, size: 12)!]
        control.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attribute)
        control.tintColor = UIColor.white
        control.addTarget(self, action: #selector(load), for: UIControlEvents.valueChanged)
        
        return control
    }

}

