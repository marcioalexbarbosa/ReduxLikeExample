# Redux-like Architecture em iOS

Exemplo prático de implementação Redux-like para ViewModels iOS, demonstrando controle de mutabilidade e state management previsível.

## 📁 Estrutura do Projeto

```
ReduxLikeExample/
├── Core/
│   ├── State.swift          # Protocolo base para estados
│   ├── Action.swift         # Protocolo base para ações
│   └── Reducer.swift        # Protocolo base para reducers
├── ProductList/
│   ├── ProductListState.swift
│   ├── ProductListAction.swift
│   ├── ProductListReducer.swift
│   ├── ProductListViewModel.swift
│   └── ProductListView.swift
└── README.md
```

## 🎯 Conceitos Principais

### 1. State (Estado Imutável)
- Struct com `let` properties
- Sempre `Equatable`
- Única fonte de verdade
- Computed properties para dados derivados

### 2. Actions (Intenções)
- Enum que representa todas as ações possíveis
- Descreve "o que aconteceu", não "como fazer"
- Associated values para dados da ação

### 3. Reducer (Função Pura)
- Recebe estado atual + ação
- Retorna novo estado
- Sem side effects
- Totalmente testável

### 4. ViewModel (Orquestrador)
- Publica o state via `@Published`
- Método `send(_:)` para despachar ações
- Gerencia side effects (network, timers, etc)
- Single responsibility: coordenar o fluxo

## 🚀 Como Usar

### Definir o State
```swift
struct ProductListState: Equatable {
    let products: [Product]
    let searchText: String
    let isLoading: Bool
    let error: Error?
    
    // Computed property - sempre consistente!
    var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter { $0.name.contains(searchText) }
    }
    
    static let initial = ProductListState(
        products: [],
        searchText: "",
        isLoading: false,
        error: nil
    )
}
```

### Definir Actions
```swift
enum ProductListAction {
    case loadProducts
    case productsLoaded([Product])
    case productsFailed(Error)
    case searchChanged(String)
    case productTapped(Product)
}
```

### Implementar o Reducer
```swift
func reduce(state: ProductListState, action: ProductListAction) -> ProductListState {
    switch action {
    case .loadProducts:
        return ProductListState(
            products: state.products,
            searchText: state.searchText,
            isLoading: true,
            error: nil
        )
        
    case .productsLoaded(let products):
        return ProductListState(
            products: products,
            searchText: state.searchText,
            isLoading: false,
            error: nil
        )
        
    case .searchChanged(let text):
        return ProductListState(
            products: state.products,
            searchText: text,
            isLoading: state.isLoading,
            error: state.error
        )
        
    // ... outros cases
    }
}
```

### Criar o ViewModel
```swift
class ProductListViewModel: ObservableObject {
    @Published private(set) var state: ProductListState = .initial
    
    private let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func send(_ action: ProductListAction) {
        // Atualizar estado via reducer
        state = reduce(state: state, action: action)
        
        // Side effects (async)
        Task {
            await handleSideEffects(action)
        }
    }
    
    private func handleSideEffects(_ action: ProductListAction) async {
        switch action {
        case .loadProducts:
            do {
                let products = try await repository.fetchProducts()
                send(.productsLoaded(products))
            } catch {
                send(.productsFailed(error))
            }
            
        default:
            break
        }
    }
}
```

### Usar na View
```swift
struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.state.filteredProducts) { product in
                ProductRow(product: product)
                    .onTapGesture {
                        viewModel.send(.productTapped(product))
                    }
            }
        }
        .searchable(text: .constant(viewModel.state.searchText)) { text in
            viewModel.send(.searchChanged(text))
        }
        .overlay {
            if viewModel.state.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.send(.loadProducts)
        }
    }
}
```

## ✅ Benefícios

### Testabilidade
```swift
func testLoadProducts() {
    let state = ProductListState.initial
    let action = ProductListAction.loadProducts
    let newState = reduce(state: state, action: action)
    
    XCTAssertTrue(newState.isLoading)
    XCTAssertNil(newState.error)
}
```

### Debugging
- Time-travel debugging possível
- Cada mudança de estado é rastreável
- Actions são self-documenting

### Manutenibilidade
- Estado sempre consistente
- Lógica centralizada no reducer
- Fácil adicionar novas features

## 🎓 Próximos Passos

1. **Middleware**: Adicionar logging, analytics
2. **Selectors**: Memoization de computed properties
3. **Effects**: Sistema mais robusto de side effects
4. **Navigation**: State-driven navigation
5. **Persistence**: Sync com CoreData/UserDefaults

## 📚 Referências

- [Redux Documentation](https://redux.js.org)
- [Elm Architecture](https://guide.elm-lang.org/architecture/)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [ReSwift](https://github.com/ReSwift/ReSwift)

## 📝 Licença

MIT - Use livremente nos seus projetos!

---

**Dúvidas?** Abra uma issue ou entre em contato: [seu contato]
