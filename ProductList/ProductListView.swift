import SwiftUI

/// View principal da lista de produtos
///
/// Princípios:
/// - View reage ao estado (state-driven UI)
/// - Todas as ações passam pelo ViewModel.send()
/// - View não contém lógica de negócio
struct ProductListView: View {
    
    @StateObject var viewModel: ProductListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Lista de produtos
                productsList
                
                // Loading overlay
                if viewModel.state.isLoading && viewModel.state.products.isEmpty {
                    loadingView
                }
                
                // Empty state
                if viewModel.state.shouldShowEmptyState {
                    emptyStateView
                }
            }
            .navigationTitle("Produtos")
            .searchable(
                text: viewModel.searchBinding,
                prompt: "Buscar produtos"
            )
            .toolbar {
                toolbarContent
            }
            .sheet(item: .constant(viewModel.state.selectedProduct)) { product in
                ProductDetailView(
                    product: product,
                    onDismiss: { viewModel.send(.closeProductDetails) }
                )
            }
            .alert(
                "Erro",
                isPresented: .constant(viewModel.state.error != nil),
                actions: {
                    Button("Tentar Novamente") {
                        viewModel.send(.retryAfterError)
                    }
                    Button("Cancelar", role: .cancel) {
                        viewModel.send(.clearError)
                    }
                },
                message: {
                    Text(viewModel.state.error?.localizedDescription ?? "")
                }
            )
            .onAppear {
                viewModel.send(.viewAppeared)
                if viewModel.state.products.isEmpty {
                    viewModel.send(.loadProducts)
                }
            }
            .onDisappear {
                viewModel.send(.viewDisappeared)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var productsList: some View {
        List {
            // Filtro de categorias
            if !viewModel.state.availableCategories.isEmpty {
                categoryPicker
            }
            
            // Produtos
            ForEach(viewModel.state.filteredProducts) { product in
                ProductRow(product: product)
                    .onTapGesture {
                        viewModel.send(.productTapped(product))
                    }
            }
        }
        .refreshable {
            viewModel.send(.refreshTriggered)
        }
    }
    
    private var categoryPicker: some View {
        Section("Categoria") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Botão "Todas"
                    CategoryChip(
                        title: "Todas",
                        isSelected: viewModel.state.selectedCategory == nil,
                        action: { viewModel.send(.categorySelected(nil)) }
                    )
                    
                    // Categorias disponíveis
                    ForEach(viewModel.state.availableCategories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            isSelected: viewModel.state.selectedCategory == category,
                            action: { viewModel.send(.categorySelected(category)) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Carregando produtos...")
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(viewModel.state.emptyMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.state.error != nil {
                Button("Tentar Novamente") {
                    viewModel.send(.retryAfterError)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Contador de produtos
        ToolbarItem(placement: .principal) {
            if viewModel.state.productCount > 0 {
                Text("\(viewModel.state.productCount) produtos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        // Botão de limpar filtros
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.state.searchText != "" || viewModel.state.selectedCategory != nil {
                Button("Limpar") {
                    viewModel.send(.clearFilters)
                }
            }
        }
    }
}

// MARK: - Product Row

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("R$ \(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
                
                if !product.inStock {
                    Text("Fora de estoque")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
        .opacity(product.inStock ? 1.0 : 0.6)
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Product Detail View

struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "photo")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                
                VStack(spacing: 8) {
                    Text(product.name)
                        .font(.title)
                        .bold()
                    
                    Text(product.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("R$ \(product.price, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
                
                if product.inStock {
                    Label("Em estoque", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Fora de estoque", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button("Adicionar ao Carrinho") {
                    // Ação de adicionar ao carrinho
                }
                .buttonStyle(.borderedProminent)
                .disabled(!product.inStock)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview com dados
        ProductListView(
            viewModel: ProductListViewModel(
                initialState: ProductListState(
                    products: Product.mockProducts,
                    searchText: "",
                    selectedCategory: nil,
                    isLoading: false,
                    error: nil,
                    selectedProduct: nil
                )
            )
        )
        
        // Preview com loading
        ProductListView(
            viewModel: ProductListViewModel(
                initialState: ProductListState(
                    products: [],
                    searchText: "",
                    selectedCategory: nil,
                    isLoading: true,
                    error: nil,
                    selectedProduct: nil
                )
            )
        )
        .previewDisplayName("Loading")
        
        // Preview com erro
        ProductListView(
            viewModel: ProductListViewModel(
                initialState: ProductListState(
                    products: [],
                    searchText: "",
                    selectedCategory: nil,
                    isLoading: false,
                    error: .networkError("Sem conexão"),
                    selectedProduct: nil
                )
            )
        )
        .previewDisplayName("Error")
    }
}
#endif
