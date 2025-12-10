import Foundation

/// Protocolo base para todos os estados da aplicação
/// 
/// Princípios:
/// - Imutável (use `let` para todas as properties)
/// - Equatable para comparações eficientes
/// - Structs são value types (copy-on-write)
protocol State: Equatable {
    /// Estado inicial padrão
    static var initial: Self { get }
}

// MARK: - Helpers para criação de novos estados

extension State {
    /// Helper para criar um novo estado com mudanças específicas
    /// Útil para reducers que precisam mudar apenas algumas properties
    ///
    /// Exemplo:
    /// ```swift
    /// return state.with { new in
    ///     new.isLoading = true
    /// }
    /// ```
    func with(_ transform: (inout Self) -> Void) -> Self {
        var mutable = self
        transform(&mutable)
        return mutable
    }
}
