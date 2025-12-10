# Projeto de Exemplo: Redux-like em iOS

## 📦 O que está incluído

### Estrutura Completa
```
ReduxLikeExample/
├── Core/                          # Protocolos base reutilizáveis
│   ├── State.swift               # Protocolo State com helpers
│   ├── Action.swift              # Protocolo Action base
│   └── Reducer.swift             # Protocolo Reducer + composição
│
├── ProductList/                   # Feature completa de exemplo
│   ├── Product.swift             # Modelo com dados mock
│   ├── ProductListState.swift   # Estado imutável + computed properties
│   ├── ProductListAction.swift  # Todas as ações possíveis
│   ├── ProductListReducer.swift # Lógica pura de transformação
│   ├── ProductRepository.swift  # Mock + exemplo real
│   ├── ProductListViewModel.swift # Orquestrador Redux-like
│   └── ProductListView.swift    # SwiftUI view state-driven
│
├── Tests/                         # Testes unitários
│   └── ProductListReducerTests.swift # 15+ testes do reducer
│
├── README.md                      # Documentação completa
└── MIGRATION_GUIDE.md            # Guia passo a passo
```

## 🎯 Features Demonstradas

### 1. Core Architecture (Protocolos Reutilizáveis)
- ✅ Protocolo `State` com helpers
- ✅ Protocolo `Action` extensível
- ✅ Protocolo `Reducer` com composição
- ✅ Type-safe e genérico

### 2. ProductList (Exemplo Completo)
- ✅ Lista de produtos com filtros
- ✅ Busca em tempo real
- ✅ Filtro por categoria
- ✅ Loading states
- ✅ Error handling
- ✅ Pull-to-refresh
- ✅ Product details
- ✅ Mock repository + exemplo real

### 3. State Management
- ✅ Estado imutável (`struct` com `let`)
- ✅ Computed properties sempre consistentes
- ✅ Equatable para comparações eficientes
- ✅ Estado inicial bem definido

### 4. Actions
- ✅ Enum type-safe
- ✅ Associated values para dados
- ✅ Self-documenting
- ✅ CustomStringConvertible para logging

### 5. Reducer
- ✅ Função pura (testável!)
- ✅ Sem side effects
- ✅ Pattern matching limpo
- ✅ Exemplo de composição

### 6. ViewModel
- ✅ Single responsibility
- ✅ Método `send()` único
- ✅ Side effects isolados
- ✅ Task cancellation
- ✅ Analytics hooks

### 7. View (SwiftUI)
- ✅ State-driven UI
- ✅ Reactive updates
- ✅ Error alerts
- ✅ Loading overlays
- ✅ Empty states
- ✅ Pull-to-refresh
- ✅ Navigation

### 8. Testing
- ✅ 15+ testes de reducer
- ✅ Testes de pureza
- ✅ Testes de edge cases
- ✅ Testes de computed properties
- ✅ 100% síncronos e rápidos

## 💡 Conceitos Ensinados

### Princípios de FP
- Imutabilidade
- Funções puras
- Composição
- Type safety

### Arquitetura Redux
- Unidirectional data flow
- Single source of truth
- Estado previsível
- Time-travel debugging possível

### Best Practices iOS
- SwiftUI moderno
- Async/await
- Task management
- Protocol-oriented design
- Dependency injection

## 📚 Documentação

### README.md
- Conceitos principais
- Como usar cada componente
- Exemplos de código
- Referências externas

### MIGRATION_GUIDE.md
- Comparação antes/depois
- Passo a passo detalhado
- Checklist completa
- Erros comuns
- Dicas práticas

## 🚀 Como Usar

### 1. Estudar o Código
```bash
# Ver a estrutura
cat PROJECT_STRUCTURE.txt

# Começar pelo README
open README.md

# Estudar o exemplo completo
cd ProductList/
```

### 2. Rodar os Testes
```swift
// Abrir em Xcode
// Cmd+U para rodar testes
// Ver como tudo é testável!
```

### 3. Experimentar
- Modifique o reducer
- Adicione novas actions
- Implemente novos filtros
- Adicione analytics
- Crie novas features

### 4. Adaptar para Seu Projeto
- Copie os protocolos Core/
- Use como template
- Siga o MIGRATION_GUIDE.md
- Adapte para suas necessidades

## 🎓 Próximos Passos

### Nível Intermediário
1. Adicionar middleware de logging
2. Implementar time-travel debugging
3. Adicionar persistência (UserDefaults/CoreData)
4. State-driven navigation

### Nível Avançado
1. Effects system robusto
2. Selectors com memoization
3. Reducer composition avançada
4. State normalization
5. Migrar para TCA (The Composable Architecture)

## 📖 Material de Apoio

### Arquivos Incluídos
- ✅ 13 arquivos Swift
- ✅ 2 guias Markdown
- ✅ Testes completos
- ✅ Comentários extensivos
- ✅ Exemplos práticos

### Códigos de Exemplo
- ✅ Mock data
- ✅ Repository pattern
- ✅ Error handling
- ✅ Async operations
- ✅ SwiftUI best practices

## 🔗 Links Úteis

- Redux: https://redux.js.org
- Elm Architecture: https://guide.elm-lang.org/architecture/
- TCA: https://github.com/pointfreeco/swift-composable-architecture
- ReSwift: https://github.com/ReSwift/ReSwift
- Point-Free: https://pointfree.co

## 💬 Suporte

- Abra issues no repositório
- Faça PRs com melhorias
- Compartilhe seu feedback
- Conte suas experiências

---

**Desenvolvido como material de apoio para a apresentação:**
"Uma abordagem para mitigar a mutabilidade e reduzir bugs em iOS"

**Autor:** Marcio Barbosa
**Data:** Dezembro 2025
