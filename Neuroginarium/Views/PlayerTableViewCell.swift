//
//  PlayerTableViewCell.swift
//  Neuroginarium
//
//  Created by Станислава on 31.03.2023.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let roundScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let totalScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Colors.white.uiColor
        contentView.addSubview(rankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roundScoreLabel)
        contentView.addSubview(totalScoreLabel)
        
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        roundScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        totalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 32),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            roundScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roundScoreLabel.trailingAnchor.constraint(equalTo: totalScoreLabel.leadingAnchor, constant: -32),
            roundScoreLabel.widthAnchor.constraint(equalToConstant: 60),
            
            totalScoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            totalScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            totalScoreLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(_ player: UserPointsDto, _ rank: Int) {
        rankLabel.text = "\(rank)"
        nameLabel.text = player.nickname
        roundScoreLabel.text = "\(player.points)"
        totalScoreLabel.text = "\(player.totalPoints)"
     }
    
}

