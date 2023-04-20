//
//  JoinGameRequestModel.swift
//  Neuroginarium
//
//  Created by Станислава on 01.04.2023.
//

import Foundation

struct JoinGameRequest: Codable {
    let userId: Int
    let gameToken: String
}

struct GameCreateResponse: Codable {
    let gameId: Int
    let gameToken: String
}

struct VotingResult: Codable {
    let isVotingFinished: Bool
    let isGameFinished: Bool
}

struct GameDto: Codable {
    let isAutoGame: Bool
    let playersCnt: Int
    let gameStatus: GameStatus
    let isGameStarted: Bool
}

enum GameStatus: String, Codable {
    case created = "CREATED"
    case started = "STARTED"
    case finished = "FINISHED"
}

struct GameRoundDto: Codable {
    let id: Int
    let associationCreatorUserId: Int
    let association: String?
    let status: RaundStatus
    let cardId: Int?
}

enum RaundStatus: String, Codable {
    case started = "STARTED"
    case associationGiven = "ASSOCIATION_GIVEN"
    case votingStarted = "VOTING_STARTED"
    case votingMade = "VOTING_MADE"
}

struct PlayerDto: Codable {
    let userId: Int
    let nickname: String
    let points: Int
}

struct CardDto: Codable {
    let id: Int
    let image: String
    let userId: Int
    let status: CardStatus
}

enum CardStatus: String, Codable {
    case inCardDeck = "IN_CARD_DECK"
    case onHands = "ON_HANDS"
    case onTable = "ON_TABLE"
    case played = "PLAYED"
}

struct RoundPointsDto: Codable {
    let realImage: String
    let usersPoints: [UserPointsDto]
}

struct UserPointsDto: Codable {
    let nickname: String
    let points: Int?
    let totalPoints: Int
}

struct CreateUserDto: Codable {
    let nickname: String
    let password: String
    let email: String
}

struct UserInfoDto: Codable {
    let userId: Int
    let nickname: String
    let rating: Int
    let email: String
}

struct UserNicknameRatingDto: Codable {
    let nickname: String
    let rating: Int
}

struct UserRatingDto: Codable {
    let points: Int
    let position: Int
}

