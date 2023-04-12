//
//  PlayerRatingTableViewCell.swift
//  Neuroginarium
//
//  Created by Станислава on 31.03.2023.
//
import UIKit

class PlayerRatingTableViewCell: UITableViewCell {
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = Colors.white.uiColor
        
        contentView.addSubview(rankLabel)
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rankLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 20).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(rank: Int, userNicknameRatingDto: UserNicknameRatingDto) {
        rankLabel.text = "\(rank)"
        nameLabel.text = userNicknameRatingDto.nickname
        scoreLabel.text = "\(userNicknameRatingDto.rating)"
    }
    
}

struct Player {
    let name: String
    let score: Int
}

   

