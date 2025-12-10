import Foundation

/// Protocolo base para todas as ações da aplicação
///
/// Princípios:
/// - Descreve "o que aconteceu", não "como fazer"
/// - Use enums para representar todas as possíveis ações
/// - Associated values para dados da ação
///
/// Exemplo:
/// ```swift
/// enum MyFeatureAction: Action {
///     case buttonTapped
///     case dataLoaded([Item])
///     case errorOccurred(Error)
/// }
/// ```
protocol Action {}

// MARK: - Action Helpers

/// Namespace para actions relacionadas a UI
enum UIAction {
    /// Ação de aparecimento da tela
    case viewAppeared
    
    /// Ação de desaparecimento da tela
    case viewDisappeared
    
    /// Ação de pull-to-refresh
    case refreshTriggered
}

/// Namespace para actions relacionadas a Network
enum NetworkAction<T> {
    /// Início de request
    case started
    
    /// Request completou com sucesso
    case succeeded(T)
    
    /// Request falhou
    case failed(Error)
}
