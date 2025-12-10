import Foundation

/// Protocolo para repositório de produtos
/// Permite mock fácil para testes
protocol ProductRepositoryProtocol {
    func fetchProducts() async throws -> [Product]
}

/// Implementação mock do repositório
///
/// Para uma app real, você implementaria:
/// - NetworkProductRepository (que faz requests HTTP)
/// - CachedProductRepository (com cache local)
/// - CoreDataProductRepository (persistência local)
class MockProductRepository: ProductRepositoryProtocol {
    
    /// Simula delay de network
    private let networkDelay: TimeInterval
    
    /// Simula taxa de erro (0.0 a 1.0)
    private let errorRate: Double
    
    init(networkDelay: TimeInterval = 1.0, errorRate: Double = 0.0) {
        self.networkDelay = networkDelay
        self.errorRate = errorRate
    }
    
    func fetchProducts() async throws -> [Product] {
        // Simular delay de rede
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
        
        // Simular erro aleatório
        if Double.random(in: 0...1) < errorRate {
            throw ProductListError.networkError("Falha na conexão")
        }
        
        // Retornar produtos mock
        return Product.mockProducts
    }
}

/// Implementação real (exemplo de estrutura)
class NetworkProductRepository: ProductRepositoryProtocol {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetchProducts() async throws -> [Product] {
        let url = baseURL.appendingPathComponent("/products")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProductListError.networkError("Status code inválido")
        }
        
        do {
            let products = try JSONDecoder().decode([Product].self, from: data)
            return products
        } catch {
            throw ProductListError.decodingError
        }
    }
}

// MARK: - Repository com cache (exemplo avançado)

/// Repositório com cache local
class CachedProductRepository: ProductRepositoryProtocol {
    private let networkRepository: ProductRepositoryProtocol
    private var cachedProducts: [Product]?
    private var lastFetchDate: Date?
    
    /// Tempo de validade do cache (5 minutos)
    private let cacheValidity: TimeInterval = 300
    
    init(networkRepository: ProductRepositoryProtocol) {
        self.networkRepository = networkRepository
    }
    
    func fetchProducts() async throws -> [Product] {
        // Verificar se cache é válido
        if let cached = cachedProducts,
           let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < cacheValidity {
            return cached
        }
        
        // Buscar da rede
        let products = try await networkRepository.fetchProducts()
        
        // Atualizar cache
        cachedProducts = products
        lastFetchDate = Date()
        
        return products
    }
    
    /// Invalida o cache forçando novo fetch
    func invalidateCache() {
        cachedProducts = nil
        lastFetchDate = nil
    }
}
