//
//  WaitingChatsNavigation.swift
//  iChat
//
//  Created by Данил Дубов on 28.09.2021.
//

import Foundation

protocol WaitingChatsNavigation: AnyObject {
    func removeWaitingChat(chat: MChat)
    func changeToActive(chat: MChat)
}
