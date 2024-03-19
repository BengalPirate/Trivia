//
//  SettingViewController.swift
//  Trivia
//
//  Created by Brandon Newton on 3/18/24.
//

import UIKit

protocol SettingsDelegate: AnyObject {
    func didUpdateSettings(category: Int, difficulty: String)
}

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!

    weak var delegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the picker view.
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.reloadAllComponents() // Reload the picker view components.

        // Set up the segmented control with difficulties.
        difficultySegmentedControl.removeAllSegments()
        for (index, difficulty) in TriviaData.difficulties.enumerated() {
            difficultySegmentedControl.insertSegment(withTitle: difficulty.capitalized, at: index, animated: false)
        }
        difficultySegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment // No default selection.
    }

    
    // Implement UIPickerViewDataSource and UIPickerViewDelegate methods
    // Similar to your setup in TriviaViewController
    // MARK: UIPickerViewDataSource Methods
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TriviaData.categories.count
    }
  
    // MARK: UIPickerViewDelegate Methods
  
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TriviaData.categories[row].name
    }
  
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle the selection of a row here
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        let selectedCategory = TriviaData.categories[selectedCategoryIndex].id
        let selectedDifficulty = TriviaData.difficulties[difficultySegmentedControl.selectedSegmentIndex]

        delegate?.didUpdateSettings(category: selectedCategory, difficulty: selectedDifficulty)
        dismiss(animated: true, completion: nil)
    }
}

