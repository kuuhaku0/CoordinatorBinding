//
//  TypeAlias.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import Combine

typealias CancelBag = Set<AnyCancellable>

typealias VoidPassthrough = PassthroughSubject<Void, Never>
typealias JustPassthrough<T> = PassthroughSubject<T, Never>
