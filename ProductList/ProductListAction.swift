import Foundation

/// Ações possíveis na tela de lista de produtos
///
/// Princípios:
/// - Descreve "o que aconteceu", não "como fazer"
/// - Enum para type safety
/// - Associated values para dados da ação
/// - Self-documenting
enum ProductListAction: Action {
    // MARK: - Lifecycle Actions
    
    /// View apareceu na tela
    case viewAppeared
    
    /// View desapareceu da tela
    case viewDisappeared
    
    /// Usuário puxou para refresh
    case refreshTriggered
    
    // MARK: - Load Actions
    
    /// Iniciar carregamento de produtos
    case loadProducts
    
    /// Produtos carregados com sucesso
    case productsLoaded([Product])
    
    /// Falha ao carregar produtos
    case loadProductsFailed(ProductListError)
    
    // MARK: - Filter Actions
    
    /// Texto de busca mudou
    case searchTextChanged(String)
    
    /// Categoria foi selecionada
    case categorySelected(String?)
    
    /// Limpar todos os filtros
    case clearFilters
    
    // MARK: - Selection Actions
    
    /// Produto foi tocado
    case productTapped(Product)
    
    /// Fechar detalhes do produto
    case closeProductDetails
    
    // MARK: - Error Actions
    
    /// Limpar erro atual
    case clearError
    
    /// Tentar novamente após erro
    case retryAfterError
}

// MARK: - Action Descriptions (útil para debugging/logging)

extension ProductListAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .viewAppeared:
            return "View Appeared"
        case .viewDisappeared:
            return "View Disappeared"
        case .refreshTriggered:
            return "Refresh Triggered"
        case .loadProducts:
            return "Load Products Started"
        case .productsLoaded(let products):
            return "Products Loaded: \(products.count) items"
        case .loadProductsFailed(let error):
            return "Load Products Failed: \(error.localizedDescription)"
        case .searchTextChanged(let text):
            return "Search Text Changed: '\(text)'"
        case .categorySelected(let category):
            return "Category Selected: \(category ?? "All")"
        case .clearFilters:
            return "Clear Filters"
        case .productTapped(let product):
            return "Product Tapped: \(product.name)"
        case .closeProductDetails:
            return "Close Product Details"
        case .clearError:
            return "Clear Error"
        case .retryAfterError:
            return "Retry After Error"
        }
    }
}

// MARK: - Action Grouping (útil para reducer composition)

extension ProductListAction {
    /// Indica se a ação é relacionada a loading
    var isLoadingAction: Bool {
        switch self {
        case .loadProducts, .productsLoaded, .loadProductsFailed:
            return true
        default:
            return false
        }
    }
    
    /// Indica se a ação é relacionada a filtros
    var isFilterAction: Bool {
        switch self {
        case .searchTextChanged, .categorySelected, .clearFilters:
            return true
        default:
            return false
        }
    }
    
    /// Indica se a ação requer side effect
    var requiresSideEffect: Bool {
        switch self {
        case .loadProducts, .refreshTriggered, .retryAfterError:
            return true
        default:
            return false
        }
    }
}
