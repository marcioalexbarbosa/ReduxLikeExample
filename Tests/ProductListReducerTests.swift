import XCTest
@testable import ReduxLikeExample

/// Testes do ProductListReducer
///
/// Benefícios de testar reducers:
/// - 100% síncronos (rápidos!)
/// - Sem dependências externas
/// - Sem mocks necessários
/// - Testa a lógica de negócio core
final class ProductListReducerTests: XCTestCase {
    
    var reducer: ProductListReducer!
    var initialState: ProductListState!
    
    override func setUp() {
        super.setUp()
        reducer = ProductListReducer()
        initialState = .initial
    }
    
    // MARK: - Loading Actions Tests
    
    func testLoadProducts_SetsLoadingTrue() {
        // Given
        let action = ProductListAction.loadProducts
        
        // When
        let newState = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertTrue(newState.isLoading)
        XCTAssertNil(newState.error)
    }
    
    func testProductsLoaded_SetsProductsAndLoadingFalse() {
        // Given
        let products = Product.mockProducts
        let action = ProductListAction.productsLoaded(products)
        let loadingState = ProductListState(
            products: [],
            searchText: "",
            selectedCategory: nil,
            isLoading: true,
            error: nil,
            selectedProduct: nil
        )
        
        // When
        let newState = reducer.reduce(state: loadingState, action: action)
        
        // Then
        XCTAssertEqual(newState.products.count, products.count)
        XCTAssertFalse(newState.isLoading)
        XCTAssertNil(newState.error)
    }
    
    func testLoadProductsFailed_SetsErrorAndLoadingFalse() {
        // Given
        let error = ProductListError.networkError("Test error")
        let action = ProductListAction.loadProductsFailed(error)
        let loadingState = ProductListState(
            products: [],
            searchText: "",
            selectedCategory: nil,
            isLoading: true,
            error: nil,
            selectedProduct: nil
        )
        
        // When
        let newState = reducer.reduce(state: loadingState, action: action)
        
        // Then
        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.error, error)
    }
    
    // MARK: - Filter Actions Tests
    
    func testSearchTextChanged_UpdatesSearchText() {
        // Given
        let searchText = "iPhone"
        let action = ProductListAction.searchTextChanged(searchText)
        
        // When
        let newState = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertEqual(newState.searchText, searchText)
    }
    
    func testCategorySelected_UpdatesSelectedCategory() {
        // Given
        let category = "Smartphones"
        let action = ProductListAction.categorySelected(category)
        
        // When
        let newState = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertEqual(newState.selectedCategory, category)
    }
    
    func testClearFilters_ResetsFilters() {
        // Given
        let filteredState = ProductListState(
            products: Product.mockProducts,
            searchText: "iPhone",
            selectedCategory: "Smartphones",
            isLoading: false,
            error: nil,
            selectedProduct: nil
        )
        let action = ProductListAction.clearFilters
        
        // When
        let newState = reducer.reduce(state: filteredState, action: action)
        
        // Then
        XCTAssertEqual(newState.searchText, "")
        XCTAssertNil(newState.selectedCategory)
        XCTAssertEqual(newState.products.count, Product.mockProducts.count)
    }
    
    // MARK: - Selection Actions Tests
    
    func testProductTapped_SetsSelectedProduct() {
        // Given
        let product = Product.mockProducts[0]
        let action = ProductListAction.productTapped(product)
        
        // When
        let newState = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertEqual(newState.selectedProduct, product)
    }
    
    func testCloseProductDetails_ClearsSelectedProduct() {
        // Given
        let product = Product.mockProducts[0]
        let stateWithSelection = ProductListState(
            products: Product.mockProducts,
            searchText: "",
            selectedCategory: nil,
            isLoading: false,
            error: nil,
            selectedProduct: product
        )
        let action = ProductListAction.closeProductDetails
        
        // When
        let newState = reducer.reduce(state: stateWithSelection, action: action)
        
        // Then
        XCTAssertNil(newState.selectedProduct)
    }
    
    // MARK: - State Computed Properties Tests
    
    func testFilteredProducts_WithSearchText() {
        // Given
        let state = ProductListState(
            products: Product.mockProducts,
            searchText: "iPhone",
            selectedCategory: nil,
            isLoading: false,
            error: nil,
            selectedProduct: nil
        )
        
        // When
        let filtered = state.filteredProducts
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.name.contains("iPhone") })
    }
    
    func testFilteredProducts_WithCategory() {
        // Given
        let state = ProductListState(
            products: Product.mockProducts,
            searchText: "",
            selectedCategory: "Smartphones",
            isLoading: false,
            error: nil,
            selectedProduct: nil
        )
        
        // When
        let filtered = state.filteredProducts
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.category == "Smartphones" })
    }
    
    func testFilteredProducts_WithBothFilters() {
        // Given
        let state = ProductListState(
            products: Product.mockProducts,
            searchText: "Pro",
            selectedCategory: "Smartphones",
            isLoading: false,
            error: nil,
            selectedProduct: nil
        )
        
        // When
        let filtered = state.filteredProducts
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { 
            $0.category == "Smartphones" && $0.name.contains("Pro")
        })
    }
    
    // MARK: - Reducer Purity Tests
    
    func testReducer_IsPure_SameInputProducesSameOutput() {
        // Given
        let action = ProductListAction.searchTextChanged("test")
        
        // When
        let result1 = reducer.reduce(state: initialState, action: action)
        let result2 = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertEqual(result1, result2)
    }
    
    func testReducer_DoesNotMutateOriginalState() {
        // Given
        let originalState = initialState!
        let action = ProductListAction.searchTextChanged("test")
        
        // When
        _ = reducer.reduce(state: initialState, action: action)
        
        // Then
        XCTAssertEqual(initialState, originalState)
    }
    
    // MARK: - Edge Cases
    
    func testRetryAfterError_ClearsError() {
        // Given
        let errorState = ProductListState(
            products: [],
            searchText: "",
            selectedCategory: nil,
            isLoading: false,
            error: .networkError("Test"),
            selectedProduct: nil
        )
        let action = ProductListAction.retryAfterError
        
        // When
        let newState = reducer.reduce(state: errorState, action: action)
        
        // Then
        XCTAssertNil(newState.error)
        XCTAssertTrue(newState.isLoading)
    }
    
    func testClearError_OnlyRemovesError() {
        // Given
        let errorState = ProductListState(
            products: Product.mockProducts,
            searchText: "test",
            selectedCategory: "Smartphones",
            isLoading: false,
            error: .networkError("Test"),
            selectedProduct: nil
        )
        let action = ProductListAction.clearError
        
        // When
        let newState = reducer.reduce(state: errorState, action: action)
        
        // Then
        XCTAssertNil(newState.error)
        XCTAssertEqual(newState.products.count, Product.mockProducts.count)
        XCTAssertEqual(newState.searchText, "test")
        XCTAssertEqual(newState.selectedCategory, "Smartphones")
    }
}
