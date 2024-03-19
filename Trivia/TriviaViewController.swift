//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

extension String {
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let decodedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil).string else {
            return self
        }
        return decodedString
    }
}

extension TriviaViewController: SettingsDelegate {
    func didUpdateSettings(category: Int, difficulty: String) {
        // Reset the game state
        currQuestionIndex = 0
        numCorrectQuestions = 0
        // Fetch new questions based on the selected settings
        fetchTriviaQuestions(category: category, difficulty: difficulty)
    }
}



class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  private var shouldPresentSettings = false

  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    fetchTriviaQuestions()
  }

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if shouldPresentSettings {
                shouldPresentSettings = false
                showSettingsPopup()
            }
    }
    
    private func showSettingsPopup() {
            if presentedViewController != nil {
                dismiss(animated: true) { [weak self] in
                    self?.presentSettingsViewController()
                }
            } else {
                presentSettingsViewController()
            }
        }
    
    /*
    func showSettingsPopup() {
        // Dismiss any currently presented view controller first, if needed.
        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
                settingsVC.modalPresentationStyle = .overCurrentContext
                settingsVC.modalTransitionStyle = .crossDissolve
                settingsVC.delegate = self
                self.present(settingsVC, animated: true, completion: nil)
            }
        }
    }*/


    private func addGradient() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [
                UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func didChooseSettings(category: Int, difficulty: String) {
            fetchTriviaQuestions(category: category, difficulty: difficulty)
        }
        
    private func fetchTriviaQuestions(category: Int? = nil, difficulty: String? = nil) {
        var urlString = "https://opentdb.com/api.php?amount=10"
        if let category = category {
            urlString += "&category=\(category)"
        }
        if let difficulty = difficulty {
            urlString += "&difficulty=\(difficulty)"
        }
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching trivia questions: \(String(describing: error))")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                
                self?.questions = triviaResponse.results.map { question in
                    var modifiedQuestion = question
                    modifiedQuestion.question = question.question.decodingHTMLEntities()
                    modifiedQuestion.correctAnswer = question.correctAnswer.decodingHTMLEntities()
                    modifiedQuestion.incorrectAnswers = question.incorrectAnswers.map { $0.decodingHTMLEntities() }
                    return modifiedQuestion
                }
                    
                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self?.updateQuestion(withQuestionIndex: self?.currQuestionIndex ?? 0)
                }
                /*
                self?.questions = triviaResponse.results
                // Make sure to update the UI on the main thread
                DispatchQueue.main.async {
                    self?.updateQuestion(withQuestionIndex: self?.currQuestionIndex ?? 0)*/
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
      }

    private func presentSettingsViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
                settingsVC.delegate = self
                settingsVC.modalPresentationStyle = .overFullScreen
                present(settingsVC, animated: true, completion: nil)
            }
        }

  private func updateQuestion(withQuestionIndex questionIndex: Int) {
      guard questionIndex < questions.count else {
                  print("Index out of range. No more questions to display.")
                  showFinalScore()
                  return
      }
      let question = questions[questionIndex]
        
      // Update question and category labels
      currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
      questionLabel.text = question.question
      categoryLabel.text = question.category
        
      // Check if the question is True/False and adjust UI accordingly
      if question.type.lowercased() == "boolean" {
          // For True/False questions, set up two buttons
          answerButton0.setTitle("True", for: .normal)
          answerButton1.setTitle("False", for: .normal)
            
          // Show only the first two buttons and hide the rest
          answerButton0.isHidden = false
          answerButton1.isHidden = false
          answerButton2.isHidden = true
          answerButton3.isHidden = true
      } else {
          // For multiple-choice questions, set up all buttons
          let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
          answerButton0.setTitle(answers.count > 0 ? answers[0] : "", for: .normal)
          answerButton1.setTitle(answers.count > 1 ? answers[1] : "", for: .normal)
          answerButton2.setTitle(answers.count > 2 ? answers[2] : "", for: .normal)
          answerButton3.setTitle(answers.count > 3 ? answers[3] : "", for: .normal)
            
          // Show all buttons
          answerButton0.isHidden = false
          answerButton1.isHidden = false
          answerButton2.isHidden = false
          answerButton3.isHidden = false
      }
  }
    
  
  private func updateToNextQuestion(answer: String) {
    if isCorrectAnswer(answer) {
      numCorrectQuestions += 1
    }
    currQuestionIndex += 1
    guard currQuestionIndex < questions.count else {
      showFinalScore()
      return
    }
    updateQuestion(withQuestionIndex: currQuestionIndex)
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game over!",
                                                message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.restartQuiz()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }

    private func restartQuiz() {
        currQuestionIndex = 0
        numCorrectQuestions = 0
        questions.removeAll() // Clear previous questions
        shouldPresentSettings = true
        viewDidAppear(true) // Or you can directly call showSettingsPopup() if appropriate
    }

  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
      guard let answer = sender.titleLabel?.text else { return }
      let correct = isCorrectAnswer(answer)
      let message = correct ? "Correct!" : "Sorry, that's not right."
        
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Next", style: .default, handler: { _ in
          self.updateToNextQuestion(answer: answer)
      }))
      present(alert, animated: true)
  }

  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
      guard let answer = sender.titleLabel?.text else { return }
      let correct = isCorrectAnswer(answer)
      let message = correct ? "Correct!" : "Sorry, that's not right."
          
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Next", style: .default, handler: { _ in
          self.updateToNextQuestion(answer: answer)
      }))
      present(alert, animated: true)
  }
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
      guard let answer = sender.titleLabel?.text else { return }
      let correct = isCorrectAnswer(answer)
      let message = correct ? "Correct!" : "Sorry, that's not right."
          
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Next", style: .default, handler: { _ in
          self.updateToNextQuestion(answer: answer)
      }))
      present(alert, animated: true)
  }
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
      guard let answer = sender.titleLabel?.text else { return }
      let correct = isCorrectAnswer(answer)
      let message = correct ? "Correct!" : "Sorry, that's not right."
          
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Next", style: .default, handler: { _ in
          self.updateToNextQuestion(answer: answer)
      }))
      present(alert, animated: true)
  }
}
