import Foundation

/// Reducer para ProductList - função pura que transforma estado
///
/// Princípios:
/// - 100% puro: sem side effects
/// - 100% síncrono
/// - 100% testável
/// - Retorna SEMPRE um novo estado
struct ProductListReducer: Reducer {
    typealias StateType = ProductListState
    typealias ActionType = ProductListAction
    
    func reduce(state: ProductListState, action: ProductListAction) -> ProductListState {
        switch action {
            
        // MARK: - Loading Actions
            
        case .loadProducts, .refreshTriggered, .retryAfterError:
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: true,
                error: nil,  // Limpa erro ao tentar novamente
                selectedProduct: state.selectedProduct
            )
            
        case .productsLoaded(let products):
            return ProductListState(
                products: products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: false,
                error: nil,
                selectedProduct: state.selectedProduct
            )
            
        case .loadProductsFailed(let error):
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: false,
                error: error,
                selectedProduct: state.selectedProduct
            )
            
        // MARK: - Filter Actions
            
        case .searchTextChanged(let text):
            return ProductListState(
                products: state.products,
                searchText: text,
                selectedCategory: state.selectedCategory,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: state.selectedProduct
            )
            
        case .categorySelected(let category):
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: category,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: state.selectedProduct
            )
            
        case .clearFilters:
            return state.withClearedFilters
            
        // MARK: - Selection Actions
            
        case .productTapped(let product):
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: product
            )
            
        case .closeProductDetails:
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: nil
            )
            
        // MARK: - Error Actions
            
        case .clearError:
            return state.withClearedError
            
        // MARK: - Lifecycle Actions (não mudam estado)
            
        case .viewAppeared, .viewDisappeared:
            return state
        }
    }
}

// MARK: - Reducer Composition Example

/// Exemplo de como quebrar o reducer em pedaços menores
struct LoadingReducer: Reducer {
    func reduce(state: ProductListState, action: ProductListAction) -> ProductListState {
        guard action.isLoadingAction else { return state }
        
        switch action {
        case .loadProducts, .refreshTriggered, .retryAfterError:
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: true,
                error: nil,
                selectedProduct: state.selectedProduct
            )
            
        case .productsLoaded(let products):
            return ProductListState(
                products: products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: false,
                error: nil,
                selectedProduct: state.selectedProduct
            )
            
        case .loadProductsFailed(let error):
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: state.selectedCategory,
                isLoading: false,
                error: error,
                selectedProduct: state.selectedProduct
            )
            
        default:
            return state
        }
    }
}

/// Reducer focado em filtros
struct FilterReducer: Reducer {
    func reduce(state: ProductListState, action: ProductListAction) -> ProductListState {
        guard action.isFilterAction else { return state }
        
        switch action {
        case .searchTextChanged(let text):
            return ProductListState(
                products: state.products,
                searchText: text,
                selectedCategory: state.selectedCategory,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: state.selectedProduct
            )
            
        case .categorySelected(let category):
            return ProductListState(
                products: state.products,
                searchText: state.searchText,
                selectedCategory: category,
                isLoading: state.isLoading,
                error: state.error,
                selectedProduct: state.selectedProduct
            )
            
        case .clearFilters:
            return state.withClearedFilters
            
        default:
            return state
        }
    }
}

// MARK: - Composed Reducer (composição dos reducers menores)

/// Você poderia usar assim:
/// ```swift
/// let reducer = CombinedReducer(
///     LoadingReducer().reduce,
///     FilterReducer().reduce
/// )
/// ```
