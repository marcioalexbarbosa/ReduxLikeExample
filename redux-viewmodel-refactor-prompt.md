# Prompt: Refatorar ViewModel para Padrão Redux-like com Estado Imutável

Você receberá um ViewModel Swift que tem problemas de mutabilidade, com propriedades `@Published` expostas publicamente. Sua tarefa é refatorá-lo para usar um padrão Redux-like que protege o estado contra mutações externas.

## Regras de Transformação:

### 1. Criar um State Struct Imutável
- Transforme todas as propriedades `@Published var` em um único `struct` de estado
- O struct deve conformar com `Equatable`
- Todas as propriedades devem ser `let` (imutáveis)
- Propriedades derivadas/computadas devem ser `var computed` dentro do struct
- Nomeie como `[Feature]State` (exemplo: `LoginState`, `ProductListState`)

### 2. Criar um Action Enum
- Defina um `enum` que represente todas as ações/intenções do usuário
- Nomeie como `[Feature]Action` (exemplo: `LoginAction`, `ProductListAction`)
- Cada `case` deve ter um nome descritivo e parâmetros associados se necessário
- Exemplos:
  - `.userDidTapButton`
  - `.textFieldChanged(String)`
  - `.dataLoaded(Result<Data, Error>)`

### 3. Encapsular o Estado no ViewModel
- Substitua todas as `@Published var` por uma única propriedade:
  ```swift
  @Published private(set) var state: [Feature]State
  ```
- O estado deve ser `private(set)` - apenas leitura pública, escrita privada

### 4. Criar Função `send(_:)` ou `handle(_:)`
- Todas as mutações devem passar por uma função centralizadora:
  ```swift
  func send(_ action: [Feature]Action) {
      // lógica de redução do estado
  }
  ```
- Use `switch` para tratar cada action
- Cada branch deve criar um **novo** estado, nunca mutar o existente

### 5. Padrão de Redução (Reducer)
- Para cada action, crie um novo estado:
  ```swift
  state = [Feature]State(
      property1: newValue,
      property2: state.property2, // mantém valores não alterados
      ...
  )
  ```
- Ou crie uma função `reduce(_:action:)` separada se preferir

### 6. Side Effects (Assíncronos)
- Operações assíncronas (network, database) disparam dentro do `send(_:)`
- Quando completam, chamam `send(_:)` novamente com o resultado:
  ```swift
  case .loadData:
      state = [Feature]State(..., isLoading: true, ...)
      repository.fetch { [weak self] result in
          self?.send(.dataLoaded(result))
      }
  case .dataLoaded(let result):
      // atualiza estado com os dados
  ```

## Exemplo de Input e Output Esperado:

### Input (Código Problemático):
```swift
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func login() {
        isLoading = true
        // ... lógica de login
    }
}
```

### Output Esperado:
```swift
struct LoginState: Equatable {
    let email: String
    let password: String
    let isLoading: Bool
    let errorMessage: String?
    
    static let initial = LoginState(
        email: "",
        password: "",
        isLoading: false,
        errorMessage: nil
    )
    
    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }
}

enum LoginAction {
    case emailChanged(String)
    case passwordChanged(String)
    case loginButtonTapped
    case loginCompleted(Result<User, Error>)
}

class LoginViewModel: ObservableObject {
    @Published private(set) var state: LoginState = .initial
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func send(_ action: LoginAction) {
        switch action {
        case .emailChanged(let email):
            state = LoginState(
                email: email,
                password: state.password,
                isLoading: state.isLoading,
                errorMessage: nil
            )
            
        case .passwordChanged(let password):
            state = LoginState(
                email: state.email,
                password: password,
                isLoading: state.isLoading,
                errorMessage: nil
            )
            
        case .loginButtonTapped:
            state = LoginState(
                email: state.email,
                password: state.password,
                isLoading: true,
                errorMessage: nil
            )
            authService.login(email: state.email, password: state.password) { [weak self] result in
                self?.send(.loginCompleted(result))
            }
            
        case .loginCompleted(let result):
            switch result {
            case .success:
                state = LoginState(
                    email: state.email,
                    password: state.password,
                    isLoading: false,
                    errorMessage: nil
                )
            case .failure(let error):
                state = LoginState(
                    email: state.email,
                    password: state.password,
                    isLoading: false,
                    errorMessage: error.localizedDescription
                )
            }
        }
    }
}
```

## Checklist Final:
- [ ] State struct criado com todas as propriedades como `let`
- [ ] State conforma com `Equatable`
- [ ] Action enum cobre todas as intenções do usuário
- [ ] ViewModel expõe apenas `@Published private(set) var state`
- [ ] Função `send(_:)` centraliza todas as mutações
- [ ] Cada action cria um novo estado ao invés de mutar
- [ ] Side effects retornam como actions
- [ ] Propriedades computadas estão no State struct
- [ ] Estado inicial está bem definido

## Agora refatore o seguinte ViewModel:

[Cole aqui o ViewModel com @Published vars expostas]
