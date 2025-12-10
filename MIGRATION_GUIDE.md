# Guia de Migração: ViewModel Tradicional → Redux-like

Este guia mostra como migrar um ViewModel tradicional para a arquitetura Redux-like passo a passo.

## 📋 Passo a Passo

### ViewModel ANTES (Tradicional)

```swift
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var errorMessage: String?
    @Published var selectedCategory: String?
    
    private let repository: ProductRepository
    
    func loadProducts() {
        isLoading = true
        
        repository.fetchProducts { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let products):
                self?.products = products
                self?.filterProducts() // 😱 Fácil esquecer!
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func filterProducts() {
        var result = products
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.contains(searchText) }
        }
        
        filteredProducts = result // 😱 Pode ficar dessincronizado!
    }
    
    func updateSearch(_ text: String) {
        searchText = text
        filterProducts() // 😱 Tem que lembrar de chamar!
    }
}
```

**Problemas:**
- ❌ Estado espalhado (6 @Published vars)
- ❌ `filteredProducts` pode ficar dessincronizado
- ❌ Fácil esquecer de chamar `filterProducts()`
- ❌ Mutação direta dificulta debugging
- ❌ Difícil de testar
- ❌ Race conditions possíveis

### Migração Passo 1: Criar o State

```swift
struct ProductListState: Equatable {
    let products: [Product]
    let searchText: String
    let selectedCategory: String?
    let isLoading: Bool
    let error: Error?
    
    // ✅ Computed property - SEMPRE consistente!
    var filteredProducts: [Product] {
        var result = products
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.contains(searchText) }
        }
        
        return result
    }
    
    static let initial = ProductListState(
        products: [],
        searchText: "",
        selectedCategory: nil,
        isLoading: false,
        error: nil
    )
}
```

**Benefícios:**
- ✅ Estado consolidado em um lugar
- ✅ `filteredProducts` sempre correto
- ✅ Imutável (`let` properties)
- ✅ Equatable para comparações

### Migração Passo 2: Definir Actions

```swift
enum ProductListAction {
    // Load
    case loadProducts
    case productsLoaded([Product])
    case loadFailed(Error)
    
    // Filter
    case searchChanged(String)
    case categorySelected(String?)
    
    // Selection
    case productTapped(Product)
}
```

**Benefícios:**
- ✅ Self-documenting
- ✅ Type-safe
- ✅ Fácil de rastrear no log

### Migração Passo 3: Criar o Reducer

```swift
func reduce(state: ProductListState, action: ProductListAction) -> ProductListState {
    switch action {
    case .loadProducts:
        return ProductListState(
            products: state.products,
            searchText: state.searchText,
            selectedCategory: state.selectedCategory,
            isLoading: true,
            error: nil
        )
        
    case .productsLoaded(let products):
        return ProductListState(
            products: products,
            searchText: state.searchText,
            selectedCategory: state.selectedCategory,
            isLoading: false,
            error: nil
        )
        
    case .searchChanged(let text):
        return ProductListState(
            products: state.products,
            searchText: text, // Só muda isso
            selectedCategory: state.selectedCategory,
            isLoading: state.isLoading,
            error: state.error
        )
        
    // ... outros cases
    }
}
```

**Benefícios:**
- ✅ Função pura (testável!)
- ✅ Sem side effects
- ✅ Lógica centralizada

### Migração Passo 4: Refatorar o ViewModel

```swift
class ProductListViewModel: ObservableObject {
    @Published private(set) var state: ProductListState = .initial
    
    private let repository: ProductRepository
    private let reducer = ProductListReducer()
    
    func send(_ action: ProductListAction) {
        // Atualizar estado
        state = reducer.reduce(state: state, action: action)
        
        // Side effects
        switch action {
        case .loadProducts:
            Task {
                do {
                    let products = try await repository.fetchProducts()
                    send(.productsLoaded(products))
                } catch {
                    send(.loadFailed(error))
                }
            }
        default:
            break
        }
    }
}
```

**Benefícios:**
- ✅ Um único `@Published`
- ✅ Método `send()` único
- ✅ Side effects isolados
- ✅ State sempre consistente

### Migração Passo 5: Atualizar a View

**ANTES:**
```swift
TextField("Buscar", text: $viewModel.searchText)
    .onChange(of: viewModel.searchText) { _ in
        viewModel.filterProducts()
    }
```

**DEPOIS:**
```swift
TextField("Buscar", text: .constant(viewModel.state.searchText))
    .onChange(of: viewModel.state.searchText) { text in
        viewModel.send(.searchChanged(text))
    }
```

Ou melhor ainda:
```swift
TextField("Buscar", text: viewModel.searchBinding)
```

## 📊 Comparação Final

### Tradicional
```
6 @Published vars
→ Estado espalhado
→ Mutação direta
→ Race conditions
→ Difícil testar
→ Bugs sutis
```

### Redux-like
```
1 @Published var (State)
→ Estado consolidado
→ Imutabilidade
→ Previsível
→ 100% testável
→ Rastreável
```

## 🎯 Checklist de Migração

- [ ] Identificar todas as `@Published` vars
- [ ] Criar `State` struct com todas elas
- [ ] Mover computed properties para o State
- [ ] Listar todas as ações possíveis
- [ ] Criar enum `Action`
- [ ] Criar função `reduce()`
- [ ] Testar o reducer isoladamente
- [ ] Refatorar ViewModel para usar `send()`
- [ ] Mover side effects para dentro do `send()`
- [ ] Atualizar a View para usar `state.property`
- [ ] Testar integração

## 💡 Dicas

### Migração Incremental
Você não precisa migrar tudo de uma vez:
1. Comece com um ViewModel pequeno
2. Aprenda o padrão
3. Migre ViewModels maiores aos poucos

### Estado Aninhado
Para apps grandes, use composição:
```swift
struct AppState {
    let productList: ProductListState
    let cart: CartState
    let user: UserState
}
```

### Computed Properties Pesadas
Se uma computed property é cara, use memoization:
```swift
var expensiveComputation: Result {
    // Cache ou lazy computation
}
```

## 🚨 Erros Comuns

### ❌ Mutação Acidental
```swift
// ERRADO
state.products.append(newProduct)

// CERTO
state = ProductListState(
    products: state.products + [newProduct],
    // ... resto
)
```

### ❌ Side Effects no Reducer
```swift
// ERRADO
func reduce(state: State, action: Action) -> State {
    repository.save() // ❌ Side effect!
    return newState
}

// CERTO
func reduce(state: State, action: Action) -> State {
    return newState // Só transformação pura
}
// Side effects vão no ViewModel.send()
```

### ❌ Esquecer de Copiar Properties
```swift
// ERRADO - esqueceu selectedCategory
return ProductListState(
    products: products,
    searchText: state.searchText,
    isLoading: false
)

// CERTO
return ProductListState(
    products: products,
    searchText: state.searchText,
    selectedCategory: state.selectedCategory, // ✅
    isLoading: false,
    error: nil
)
```

## 📚 Próximos Passos

1. **Middleware**: Adicione logging automático
2. **Time Travel**: Debug com histórico de estados
3. **Persistence**: Salve/restaure estado
4. **Testing**: Crie snapshot tests
5. **Navigation**: State-driven navigation

## 🎓 Recursos

- Exemplo completo neste repositório
- Slides da apresentação
- Testes de exemplo
- README com conceitos

---

**Dúvidas?** Abra uma issue ou me procure no Slack!
