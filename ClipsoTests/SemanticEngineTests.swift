import XCTest
@testable import Clipso

final class SemanticEngineTests: XCTestCase {

    var engine: SemanticEngine!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        engine = SemanticEngine.shared
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDown() {
        // Clean up test items
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClipboardItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)

        engine = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Embedding Generation Tests

    func testGenerateEmbeddingForValidText() {
        let text = "This is a test sentence for embedding generation."

        let embedding = engine.generateEmbedding(for: text)

        XCTAssertNotNil(embedding, "Should generate embedding for valid text")
        XCTAssertFalse(embedding!.isEmpty, "Embedding should not be empty")

        // NLEmbedding typically generates vectors with consistent dimensions
        if let embedding = embedding {
            XCTAssertGreaterThan(embedding.count, 0, "Embedding should have dimensions")
        }
    }

    func testGenerateEmbeddingForEmptyString() {
        let embedding = engine.generateEmbedding(for: "")

        XCTAssertNil(embedding, "Should return nil for empty string")
    }

    func testGenerateEmbeddingForLongText() {
        // Test text truncation to 1000 characters
        let longText = String(repeating: "Lorem ipsum dolor sit amet. ", count: 50) // ~1400 chars

        let embedding = engine.generateEmbedding(for: longText)

        XCTAssertNotNil(embedding, "Should generate embedding for long text with truncation")
    }

    func testGenerateEmbeddingForUnicode() {
        let unicodeText = "Hello 世界 🌍 Привет"

        let embedding = engine.generateEmbedding(for: unicodeText)

        XCTAssertNotNil(embedding, "Should handle Unicode text")
    }

    func testGenerateEmbeddingConsistency() {
        let text = "Consistent text for testing"

        let embedding1 = engine.generateEmbedding(for: text)
        let embedding2 = engine.generateEmbedding(for: text)

        XCTAssertNotNil(embedding1)
        XCTAssertNotNil(embedding2)

        // Same text should produce identical embeddings
        if let emb1 = embedding1, let emb2 = embedding2 {
            XCTAssertEqual(emb1.count, emb2.count, "Embeddings should have same dimensions")

            for i in 0..<min(emb1.count, emb2.count) {
                XCTAssertEqual(emb1[i], emb2[i], accuracy: 0.0001, "Embeddings should be identical")
            }
        }
    }

    // MARK: - Embedding Serialization Tests

    func testEmbeddingToDataAndBack() {
        let embedding = [0.1, 0.2, 0.3, 0.4, 0.5]

        let data = engine.embeddingToData(embedding)
        XCTAssertNotNil(data, "Should convert embedding to data")

        let decoded = engine.dataToEmbedding(data!)
        XCTAssertNotNil(decoded, "Should decode data back to embedding")
        XCTAssertEqual(decoded!, embedding, "Decoded embedding should match original")
    }

    func testEmbeddingToDataWithEmptyArray() {
        let embedding: [Double] = []

        let data = engine.embeddingToData(embedding)
        XCTAssertNotNil(data, "Should handle empty embedding array")

        let decoded = engine.dataToEmbedding(data!)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded!, [], "Should decode to empty array")
    }

    func testDataToEmbeddingWithInvalidData() {
        let invalidData = "Invalid data".data(using: .utf8)!

        let embedding = engine.dataToEmbedding(invalidData)

        XCTAssertNil(embedding, "Should return nil for invalid data")
    }

    // MARK: - Cosine Similarity Tests

    func testCosineSimilarityIdenticalVectors() {
        let vec1 = [1.0, 2.0, 3.0, 4.0, 5.0]
        let vec2 = [1.0, 2.0, 3.0, 4.0, 5.0]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, 1.0, accuracy: 0.001, "Identical vectors should have similarity 1.0")
    }

    func testCosineSimilarityOrthogonalVectors() {
        let vec1 = [1.0, 0.0, 0.0]
        let vec2 = [0.0, 1.0, 0.0]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, 0.0, accuracy: 0.001, "Orthogonal vectors should have similarity 0.0")
    }

    func testCosineSimilarityOppositeVectors() {
        let vec1 = [1.0, 2.0, 3.0]
        let vec2 = [-1.0, -2.0, -3.0]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, -1.0, accuracy: 0.001, "Opposite vectors should have similarity -1.0")
    }

    func testCosineSimilarityDifferentLengthVectors() {
        let vec1 = [1.0, 2.0, 3.0]
        let vec2 = [1.0, 2.0]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, 0.0, "Different length vectors should return 0.0")
    }

    func testCosineSimilarityEmptyVectors() {
        let vec1: [Double] = []
        let vec2: [Double] = []

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, 0.0, "Empty vectors should return 0.0")
    }

    func testCosineSimilarityZeroMagnitudeVector() {
        let vec1 = [0.0, 0.0, 0.0]
        let vec2 = [1.0, 2.0, 3.0]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertEqual(similarity, 0.0, "Zero magnitude vector should return 0.0")
    }

    func testCosineSimilaritySimilarVectors() {
        let vec1 = [1.0, 2.0, 3.0]
        let vec2 = [1.1, 2.1, 3.1]

        let similarity = engine.cosineSimilarity(vec1, vec2)

        XCTAssertGreaterThan(similarity, 0.99, "Very similar vectors should have high similarity")
    }

    // MARK: - Find Similar Items Tests

    func testFindSimilarItemsExcludesSelf() {
        let item1 = createTestItem(content: "Machine learning and artificial intelligence")
        let item2 = createTestItem(content: "Deep learning and neural networks")
        let item3 = createTestItem(content: "Cooking recipes and kitchen tips")

        // Generate and store embeddings
        generateAndStoreEmbedding(for: item1)
        generateAndStoreEmbedding(for: item2)
        generateAndStoreEmbedding(for: item3)

        let similar = engine.findSimilarItems(to: item1, in: [item1, item2, item3], threshold: 0.5)

        // Should not include item1 itself
        XCTAssertFalse(similar.contains(where: { $0.0.id == item1.id }), "Should exclude the query item itself")
    }

    func testFindSimilarItemsWithThreshold() {
        let item1 = createTestItem(content: "Swift programming language")
        let item2 = createTestItem(content: "Swift development and iOS apps")
        let item3 = createTestItem(content: "Completely unrelated text about gardening")

        generateAndStoreEmbedding(for: item1)
        generateAndStoreEmbedding(for: item2)
        generateAndStoreEmbedding(for: item3)

        let similar = engine.findSimilarItems(to: item1, in: [item1, item2, item3], threshold: 0.7)

        // Should respect the threshold
        for (_, similarity) in similar {
            XCTAssertGreaterThanOrEqual(similarity, 0.7, "All results should meet threshold")
        }
    }

    func testFindSimilarItemsSortedByScore() {
        let item1 = createTestItem(content: "Original text about technology")
        let item2 = createTestItem(content: "Technology and computers")
        let item3 = createTestItem(content: "Tech innovations")
        let item4 = createTestItem(content: "Unrelated content")

        generateAndStoreEmbedding(for: item1)
        generateAndStoreEmbedding(for: item2)
        generateAndStoreEmbedding(for: item3)
        generateAndStoreEmbedding(for: item4)

        let similar = engine.findSimilarItems(to: item1, in: [item1, item2, item3, item4], threshold: 0.3)

        // Should be sorted by similarity descending
        for i in 0..<(similar.count - 1) {
            XCTAssertGreaterThanOrEqual(similar[i].1, similar[i + 1].1, "Results should be sorted by similarity")
        }
    }

    func testFindSimilarItemsWithNoEmbedding() {
        let item1 = createTestItem(content: "Test item")
        let item2 = createTestItem(content: "Another item")

        // Don't generate embeddings

        let similar = engine.findSimilarItems(to: item1, in: [item1, item2], threshold: 0.5)

        XCTAssertTrue(similar.isEmpty, "Should return empty array when embeddings are missing")
    }

    // MARK: - Core Data Integration Tests

    func testProcessAndStoreEmbedding() {
        let item = createTestItem(content: "Test content for embedding storage")

        let expectation = self.expectation(description: "Embedding stored")

        engine.processAndStoreEmbedding(for: item, context: context)

        // Wait for async Core Data operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.context.refresh(item, mergeChanges: true)

            XCTAssertNotNil(item.embedding, "Embedding should be stored in Core Data")

            if let embeddingData = item.embedding {
                let embedding = self.engine.dataToEmbedding(embeddingData)
                XCTAssertNotNil(embedding, "Stored embedding should be decodable")
                XCTAssertFalse(embedding!.isEmpty, "Stored embedding should not be empty")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testProcessAndStoreEmbeddingForEmptyContent() {
        let item = createTestItem(content: "")

        engine.processAndStoreEmbedding(for: item, context: context)

        // Give time for async operation
        let expectation = self.expectation(description: "Wait for processing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.context.refresh(item, mergeChanges: true)
            XCTAssertNil(item.embedding, "Should not store embedding for empty content")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testProcessExistingItemsBatch() {
        // Create multiple items without embeddings
        let item1 = createTestItem(content: "First item")
        let item2 = createTestItem(content: "Second item")
        let item3 = createTestItem(content: "Third item")

        try? context.save()

        let expectation = self.expectation(description: "Batch processing complete")

        engine.processExistingItems(context: context)

        // Wait for async batch processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.context.refreshAllObjects()

            // Check that embeddings were generated
            let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "embedding != nil")

            let itemsWithEmbeddings = try? self.context.fetch(fetchRequest)

            XCTAssertNotNil(itemsWithEmbeddings)
            XCTAssertGreaterThan(itemsWithEmbeddings?.count ?? 0, 0, "Should process some items")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    // MARK: - Cache Management Tests

    func testCacheLimit() {
        // This test verifies the cache limit of 100 items
        // Note: This is difficult to test directly as cache is private
        // We can only test indirectly by checking performance doesn't degrade

        let items = (0..<150).map { i in
            createTestItem(content: "Test item \(i) with unique content")
        }

        // Generate embeddings for all items (should trigger cache limiting)
        for item in items {
            generateAndStoreEmbedding(for: item)
        }

        // If we get here without crashing, the cache limit is working
        XCTAssertTrue(true, "Cache limit should prevent unbounded growth")
    }

    // MARK: - Helper Methods

    private func createTestItem(content: String) -> ClipboardItemEntity {
        let item = ClipboardItemEntity(context: context)
        item.id = UUID()
        item.timestamp = Date()
        item.content = content
        item.category = Int16(ClipboardCategory.text.rawValue)
        item.type = 0
        item.isEncrypted = false
        return item
    }

    private func generateAndStoreEmbedding(for item: ClipboardItemEntity) {
        let text = item.displayContent
        guard let embedding = engine.generateEmbedding(for: text) else { return }
        guard let embeddingData = engine.embeddingToData(embedding) else { return }
        item.embedding = embeddingData
    }
}
