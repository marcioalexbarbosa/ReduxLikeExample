import Foundation

/// Protocolo para reducers - funções puras que transformam estado
///
/// Princípios:
/// - Função pura: mesmo input = mesmo output
/// - Sem side effects (sem network, timers, random, etc)
/// - Totalmente síncrona
/// - 100% testável
///
/// Exemplo:
/// ```swift
/// struct MyFeatureReducer: Reducer {
///     func reduce(state: MyFeatureState, action: MyFeatureAction) -> MyFeatureState {
///         switch action {
///         case .buttonTapped:
///             return state.with { $0.count += 1 }
///         case .dataLoaded(let items):
///             return state.with { $0.items = items }
///         }
///     }
/// }
/// ```
protocol Reducer {
    associatedtype StateType: State
    associatedtype ActionType: Action
    
    /// Transforma o estado atual baseado na ação recebida
    ///
    /// - Parameters:
    ///   - state: Estado atual
    ///   - action: Ação a ser processada
    /// - Returns: Novo estado (imutável)
    func reduce(state: StateType, action: ActionType) -> StateType
}

// MARK: - Reducer Composition

/// Combina múltiplos reducers em um só
///
/// Útil para quebrar reducers grandes em pedaços menores
///
/// Exemplo:
/// ```swift
/// let mainReducer = CombinedReducer(
///     loadingReducer,
///     dataReducer,
///     errorReducer
/// )
/// ```
struct CombinedReducer<StateType: State, ActionType: Action>: Reducer {
    private let reducers: [(StateType, ActionType) -> StateType]
    
    init(_ reducers: (StateType, ActionType) -> StateType...) {
        self.reducers = reducers
    }
    
    func reduce(state: StateType, action: ActionType) -> StateType {
        reducers.reduce(state) { currentState, reducer in
            reducer(currentState, action)
        }
    }
}

// MARK: - Reducer Utilities

extension Reducer {
    /// Cria um reducer que só age em ações específicas
    ///
    /// Exemplo:
    /// ```swift
    /// let loadingReducer = reducer.filter { action in
    ///     if case .loading = action { return true }
    ///     return false
    /// }
    /// ```
    func filter(_ predicate: @escaping (ActionType) -> Bool) -> some Reducer<StateType, ActionType> {
        FilteredReducer(base: self, predicate: predicate)
    }
}

private struct FilteredReducer<R: Reducer>: Reducer {
    let base: R
    let predicate: (R.ActionType) -> Bool
    
    func reduce(state: R.StateType, action: R.ActionType) -> R.StateType {
        guard predicate(action) else { return state }
        return base.reduce(state: state, action: action)
    }
}
