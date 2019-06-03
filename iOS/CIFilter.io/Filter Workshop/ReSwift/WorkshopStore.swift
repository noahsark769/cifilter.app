//
//  WorkshopStore.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 6/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import ReSwift

struct WorkshopReadyState: StateType {
    let filter: FilterInfo
    var currentOutputImage: RenderingResult? = nil

    enum Reducers {
        static func reducer(action: Action, state: WorkshopReadyState) -> WorkshopReadyState {
            var state = state
            switch action {
            case let imageDidRender as WorkshopActions.ImageDidRender:
                state.currentOutputImage = imageDidRender.image
            default: break
            }
            return state
        }
    }
}

extension WorkshopReadyState {
    init(filter: FilterInfo) {
        self.init(filter: filter, currentOutputImage: nil)
    }
}

enum WorkshopState: StateType {
    case notInitialized
    case ready(WorkshopReadyState)

    enum Reducers {
        static func storeReducer(action: Action, state: WorkshopState?) -> WorkshopState {
            var state = state ?? WorkshopState.notInitialized
            switch action {
            case let initializationAction as WorkshopActions.WorkshopDidBecomeReady:
                state = .ready(WorkshopReadyState(filter: initializationAction.filter))
            default: break
            }

            if case let .ready(workshopReadyState) = state {
                state = .ready(WorkshopReadyState.Reducers.reducer(action: action, state: workshopReadyState))
            }

            return state
        }
    }
}

enum WorkshopStore {
    static let store = Store(reducer: WorkshopState.Reducers.storeReducer, state: .notInitialized)
}

enum WorkshopActions {
    struct WorkshopDidBecomeReady: Action {
        let filter: FilterInfo
    }

    struct ImageDidRender: Action {
        let image: RenderingResult
    }
}
