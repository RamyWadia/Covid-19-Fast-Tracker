//
//  Information.swift
//  Covid19Tracker
//
//  Created by Ramy Atalla on 2020-04-11.
//  Copyright © 2020 Ramy Atalla. All rights reserved.
//

import UIKit

class FavoritesListVC: DataLoadingVC {
    
    let tableView = UITableView()
    var favorites: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureVC()
        configureTableView()
        getFavorites()
    }
    
    func configureVC() {
        view.backgroundColor = .systemBackground
        title                = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame      = view.bounds
        tableView.rowHeight  = 80
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.removeExcessCells()
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    func getFavorites() {
        PresistanceManager.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let favorites):
                self.updateUI(with: favorites)
                
            case .failure(let error):
                self.showErrorMessage(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
    
    func updateUI(with favorite: [Country]) {
        if favorite.isEmpty {
            self.showEmptyStateView(with: "Long press a country on the countries screen to add it to favorites.", in: self.view)
        } else {
            self.favorites = favorite
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
}

//MARK: - tableViewDelegation
extension FavoritesListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite            = favorites[indexPath.row]
        let destCV              = CountryDetailVCWithNavigationButtons()
        destCV.countryName      = favorite.country
        destCV.title            = favorite.country
        let destNC              = UINavigationController(rootViewController: destCV)
        present(destNC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PresistanceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                self.getFavorites()
                return
            }
            self.showErrorMessage(title: "Unable to remove", message: error.rawValue)
        }
    }
    
}
