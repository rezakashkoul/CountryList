//
//  SearchController.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchControllerDelegate: AnyObject {
    func choosedCountry(countries: [Country])
}

class SearchController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBAction func doneButtonAction(_ sender: Any) {
        delegate?.choosedCountry(countries: selectedCountries)
        dismiss(animated: true, completion: nil)
    }
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    var rows = PublishSubject<[Country]>()
    weak var delegate: SearchControllerDelegate?
    var selectedCountries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.slideUpViews(delay: 1.0)
        setupUI()
        bindViewModel()
        viewModel.APIRequest()
    }
    
    func setupUI(){
        navigationItem.title = "Select Countries"
        if #available(iOS 13.0, *) {
            searchField.searchTextField.delegate = self
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissModalVC))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("X", comment: "Close"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissModalVC))
        }
        doneButton.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .onDrag
    }
    
    func bindViewModel(){

        viewModel.tableRowsItem.bind(to: rows).disposed(by: disposeBag)
        let searchedText = searchField.rx.text.orEmpty.distinctUntilChanged()
        Observable.combineLatest(rows, searchedText) { [unowned self] (allItems, country) -> [Country] in
            return self.viewModel.filteredCountries(with: allItems, searchedPlace: country)
        }.bind(to: tableView.rx.items(cellIdentifier: "TableViewCell", cellType: TableViewCell.self)) { (row,item,cell) in
            cell.countryNameLabel.text = item.name.official
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Country.self).subscribe { item in
            self.selectedCountries.append(item.element!)
        }.disposed(by: disposeBag)
        tableView.rx.modelDeselected(Country.self).subscribe { [self] item in
            selectedCountries = selectedCountries.filter {$0 != item.element}
//            selectedCountries.remove(at: selectedCountries.firstIndex(of: item.element!)!)
            print("deselected: \(item)")
        }.disposed(by: disposeBag)
        rows.subscribe(onNext: {_ in
            self.tableView.reloadWithAnimation()
        }).disposed(by: disposeBag)
    }
    
    @objc func dismissModalVC() {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
    

}
