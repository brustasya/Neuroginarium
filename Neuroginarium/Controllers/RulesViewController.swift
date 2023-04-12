//
//  RulesViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 30.03.2023.
//
import UIKit

class RulesViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Правила игры"
        label.textColor = Colors.white.uiColor
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.darkBlue.uiColor
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        let rulesLabel = UILabel()
        rulesLabel.numberOfLines = 0
        rulesLabel.textColor = Colors.white.uiColor
        rulesLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        rulesLabel.text = """
        
        🔸 Игрок, который начинает игру
           (ведущий), выбирает одну из своих
            карт и загадывает ассоциацию,
            которая описывает ее
            (не обязательно прямо).
        
        🔸 Остальные игроки выбирают карту
           из своих рук, которая, по их
           мнению, наилучшим образом
           соответствует данной ассоциации.
        
        🔸 Карты собираются и затем
           раскрываются на столе.
        
        🔸 Все игроки, кроме ведущего,
           голосуют за карту, которая,
           по их мнению, наилучшим образом
           соответствует данной ассоциации.
        
        🔸 Подсчет очков:
            - Если все игроки выбрали карту
               ведущего, то он набирает 0 очков,
               а всем остальным игрокам
               добавляется по 3 очка.
        
            - Если карточку ведущего никто не
              угадал, то ведущий набирает 0
              очков.
              Все остальные игроки получают
              по 1 очку за каждого игрока,
              который выбрал их карточку.
        
            - Во всех остальных случаях игроки,
              правильно угадавшие карточку
              ведущего, получают по три очка.
              Ведущий получает 3 очка плюс по
              очку за каждого угадавшего
              его игрока.
              Все игроки получают по 1 очку
              за каждого игрока, который выбрал
              их карточку.
        
        🔸 После подсчета очков роль ведущего
           переходит к следующему игроку.
        
        🔸 Игра заканчивается, когда один из
           игроков набирает победное
           число очков.
        """
        
        scrollView.addSubview(rulesLabel)
                
        rulesLabel.sizeToFit()

        scrollView.addSubview(rulesLabel)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: rulesLabel.frame.height)
        scrollView.isScrollEnabled = true
    }
}


