//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

struct TriviaQuestion: Decodable { // Make sure TriviaQuestion conforms to Decodable
  var category: String
  var type: String
  var difficulty: String // Corrected the spelling here
  var question: String
  var correctAnswer: String
  var incorrectAnswers: [String]

  private enum CodingKeys: String, CodingKey {
    case category, type, difficulty, question, correctAnswer = "correct_answer", incorrectAnswers = "incorrect_answers"
  }
}

struct TriviaResponse: Decodable {
  let results: [TriviaQuestion]
}
