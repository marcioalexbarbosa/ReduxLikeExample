import Foundation

/// Estado da tela de lista de produtos
///
/// Princípios seguidos:
/// - Todas as properties são `let` (imutável)
/// - Struct (value type)
/// - Computed properties para dados derivados
/// - Equatable para comparações eficientes
struct ProductListState: State {
    /// Lista de produtos carregados
    let products: [Product]
    
    /// Texto de busca atual
    let searchText: String
    
    /// Categoria selecionada para filtro
    let selectedCategory: String?
    
    /// Indica se está carregando dados
    let isLoading: Bool
    
    /// Erro atual, se houver
    let error: ProductListError?
    
    /// Produto selecionado para detalhes
    let selectedProduct: Product?
    
    // MARK: - Computed Properties (sempre consistentes!)
    
    /// Produtos filtrados por busca e categoria
    ///
    /// Esta propriedade é sempre calculada baseada no estado atual,
    /// garantindo que nunca fica dessincronizada
    var filteredProducts: [Product] {
        var result = products
        
        // Filtrar por categoria
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filtrar por texto de busca
        if !searchText.isEmpty {
            result = result.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    /// Categorias disponíveis (únicas)
    var availableCategories: [String] {
        Array(Set(products.map { $0.category })).sorted()
    }
    
    /// Indica se há produtos no estoque
    var hasInStockProducts: Bool {
        filteredProducts.contains { $0.inStock }
    }
    
    /// Total de produtos filtrados
    var productCount: Int {
        filteredProducts.count
    }
    
    /// Mensagem a ser exibida quando não há produtos
    var emptyMessage: String {
        if isLoading {
            return "Carregando..."
        } else if let error = error {
            return "Erro: \(error.localizedDescription)"
        } else if !searchText.isEmpty {
            return "Nenhum produto encontrado para '\(searchText)'"
        } else if selectedCategory != nil {
            return "Nenhum produto nesta categoria"
        } else {
            return "Nenhum produto disponível"
        }
    }
    
    /// Indica se deve mostrar a mensagem de vazio
    var shouldShowEmptyState: Bool {
        !isLoading && filteredProducts.isEmpty
    }
    
    // MARK: - Initial State
    
    static let initial = ProductListState(
        products: [],
        searchText: "",
        selectedCategory: nil,
        isLoading: false,
        error: nil,
        selectedProduct: nil
    )
}

// MARK: - Errors

enum ProductListError: Error, Equatable {
    case networkError(String)
    case decodingError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Erro de rede: \(message)"
        case .decodingError:
            return "Erro ao processar dados"
        case .unknown:
            return "Erro desconhecido"
        }
    }
}

// MARK: - State Helpers

extension ProductListState {
    /// Helper para resetar filtros
    var withClearedFilters: ProductListState {
        ProductListState(
            products: products,
            searchText: "",
            selectedCategory: nil,
            isLoading: isLoading,
            error: error,
            selectedProduct: selectedProduct
        )
    }
    
    /// Helper para limpar erros
    var withClearedError: ProductListState {
        ProductListState(
            products: products,
            searchText: searchText,
            selectedCategory: selectedCategory,
            isLoading: isLoading,
            error: nil,
            selectedProduct: selectedProduct
        )
    }
}
