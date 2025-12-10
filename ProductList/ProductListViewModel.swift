import Foundation
import Combine

/// ViewModel para a lista de produtos usando arquitetura Redux-like
///
/// Responsabilidades:
/// - Publicar o estado via @Published
/// - Receber ações via send()
/// - Orquestrar side effects (network, timers, etc)
/// - Delegar transformações de estado para o reducer
///
/// O que NÃO faz:
/// - Mutar estado diretamente
/// - Conter lógica de negócio (isso fica no reducer)
@MainActor
class ProductListViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Estado atual - única fonte de verdade
    /// `private(set)` garante que só pode ser modificado internamente
    @Published private(set) var state: ProductListState = .initial
    
    // MARK: - Dependencies
    
    private let repository: ProductRepositoryProtocol
    private let reducer: ProductListReducer
    
    // MARK: - Private Properties
    
    /// Task atual de loading (para cancelamento)
    private var loadingTask: Task<Void, Never>?
    
    /// Set de cancellables para Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        repository: ProductRepositoryProtocol = MockProductRepository(),
        reducer: ProductListReducer = ProductListReducer()
    ) {
        self.repository = repository
        self.reducer = reducer
    }
    
    // MARK: - Public API
    
    /// Despacha uma ação para o sistema
    ///
    /// Esta é a ÚNICA forma de modificar o estado.
    /// Todas as interações da View passam por aqui.
    func send(_ action: ProductListAction) {
        // Log da ação (útil para debugging)
        print("📤 Action: \(action)")
        
        // Atualizar estado via reducer (síncrono, puro)
        let previousState = state
        state = reducer.reduce(state: state, action: action)
        
        // Log da mudança de estado
        if previousState != state {
            print("📦 State changed")
        }
        
        // Processar side effects (assíncrono)
        if action.requiresSideEffect {
            handleSideEffect(action)
        }
    }
    
    // MARK: - Side Effects
    
    /// Processa side effects das ações
    ///
    /// Side effects incluem:
    /// - Network requests
    /// - Database operations
    /// - Timers
    /// - Anything async ou com efeitos colaterais
    private func handleSideEffect(_ action: ProductListAction) {
        switch action {
        case .loadProducts, .refreshTriggered, .retryAfterError:
            loadProducts()
            
        default:
            break
        }
    }
    
    /// Carrega produtos do repositório
    private func loadProducts() {
        // Cancelar task anterior se existir
        loadingTask?.cancel()
        
        // Criar nova task
        loadingTask = Task {
            do {
                // Simular delay mínimo para UX (opcional)
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                
                // Buscar produtos
                let products = try await repository.fetchProducts()
                
                // Verificar se não foi cancelado
                guard !Task.isCancelled else { return }
                
                // Despachar sucesso
                send(.productsLoaded(products))
                
            } catch {
                // Verificar se não foi cancelado
                guard !Task.isCancelled else { return }
                
                // Converter erro para nosso tipo
                let productError: ProductListError
                if let error = error as? ProductListError {
                    productError = error
                } else {
                    productError = .unknown
                }
                
                // Despachar falha
                send(.loadProductsFailed(productError))
            }
        }
    }
    
    // MARK: - Lifecycle
    
    deinit {
        // Cancelar tasks pendentes
        loadingTask?.cancel()
    }
}

// MARK: - Convenience Helpers

extension ProductListViewModel {
    
    /// Helper para busca - pode ser usado com .searchable()
    var searchBinding: Binding<String> {
        Binding(
            get: { self.state.searchText },
            set: { self.send(.searchTextChanged($0)) }
        )
    }
    
    /// Helper para categoria selecionada
    var categoryBinding: Binding<String?> {
        Binding(
            get: { self.state.selectedCategory },
            set: { self.send(.categorySelected($0)) }
        )
    }
}

// MARK: - Analytics/Logging (exemplo de extensão)

extension ProductListViewModel {
    
    /// Versão do send() com analytics
    ///
    /// Exemplo de como você poderia adicionar tracking
    func sendWithAnalytics(_ action: ProductListAction) {
        // Log para analytics
        trackEvent("action_dispatched", properties: [
            "action": String(describing: action),
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Despachar normalmente
        send(action)
    }
    
    private func trackEvent(_ name: String, properties: [String: Any]) {
        // Implementar seu sistema de analytics aqui
        // Firebase, Mixpanel, etc
        print("📊 Analytics: \(name) - \(properties)")
    }
}

// MARK: - Testing Helpers

#if DEBUG
extension ProductListViewModel {
    
    /// Inicializador para testes com estado customizado
    convenience init(
        initialState: ProductListState,
        repository: ProductRepositoryProtocol = MockProductRepository()
    ) {
        self.init(repository: repository)
        self.state = initialState
    }
    
    /// Força um estado específico (só para testes!)
    func _test_setState(_ state: ProductListState) {
        self.state = state
    }
}
#endif
