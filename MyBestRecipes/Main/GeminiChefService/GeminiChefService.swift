//  RecipeAIService.swift
import Foundation

// Сервис для взаимодействия с Gemini API для получения рецептов
class RecipeAIService {

    // ВАЖНО: Замени на свой API ключ
    private let apiKey = "AIzaSyDeKZRT21892LO6NjoSWdWgq3OfXeiOG1c"
    private let modelName = "gemini-1.5-flash-latest" // Используем свежую и быструю модель
    private lazy var baseURL = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent"

    // --- Структуры для ответа от API ---
    // Эта структура описывает один рецепт, который вернет AI
    struct AIGeneratedRecipe: Decodable, Identifiable {
        let id = UUID() // Для SwiftUI списков
        let title: String
        let description: String
        let ingredients: [String]
        let instructions: [String]
        let cookingTime: String // Например "30 минут"
    }

    // --- Структуры для взаимодействия с API (немного упрощены) ---
    private struct GeminiRequest: Encodable { let contents: [Content] }
    private struct Content: Encodable { let parts: [Part] }
    private struct Part: Encodable { let text: String }

    private struct GeminiResponse: Decodable { let candidates: [Candidate]? }
    private struct Candidate: Decodable { let content: ResponseContent? }
    private struct ResponseContent: Decodable { let parts: [ResponsePart]? }
    private struct ResponsePart: Decodable { let text: String? }
    
    // --- Ошибки ---
    enum AIServiceError: Error, LocalizedError {
        case invalidUrl, networkError(Error), apiError(String), decodingError(Error), noContentGenerated, resultJsonDecodingError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidUrl: "Invalid API URL."
            case .networkError(let err): "Network error: \(err.localizedDescription)"
            case .apiError(let msg): " API Error: \(msg)"
            case .decodingError(let err): "Error decoding API response: \(err.localizedDescription)"
            case .noContentGenerated: "The model did not generate any content.."
            case .resultJsonDecodingError(let err): "Error decoding JSON with recipes: \(err.localizedDescription)"
            }
        }
    }
    
    // Основная функция для запроса рецептов
    func suggestRecipes(from ingredients: String) async -> Result<[AIGeneratedRecipe], AIServiceError> {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            return .failure(.invalidUrl)
        }
        
        let prompt = createPrompt(for: ingredients)
        let requestPayload = GeminiRequest(contents: [Content(parts: [Part(text: prompt)])])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestPayload)
        } catch {
            return .failure(.decodingError(error))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                return .failure(.apiError("HTTP Status \((response as? HTTPURLResponse)?.statusCode ?? -1). Body: \(errorBody)"))
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let resultText = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
                return .failure(.noContentGenerated)
            }
            
            // Очистка ответа от Markdown
            let cleanedText = cleanupJsonString(resultText)
            
            guard let resultData = cleanedText.data(using: .utf8) else {
                return .failure(.resultJsonDecodingError(NSError(domain: "RecipeAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert cleaned text to data."])))
            }
            
            let recipes = try JSONDecoder().decode([AIGeneratedRecipe].self, from: resultData)
            return .success(recipes)
            
        } catch let error as DecodingError {
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    // Функция для очистки JSON-строки от "```json" и "```"
    private func cleanupJsonString(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Создание промпта для AI
    private func createPrompt(for ingredients: String) -> String {
        return """
        You are an experienced chef and assistant in a cooking app.
        Your task is to suggest 3 (three) different recipes based on the list of products provided by the user.

        The user has provided the following products:
        "\(ingredients)"
        
        Rules for your answer:
        1. **JSON Only**: Your answer must be STRICTLY a valid JSON array. Do not add any text before or after the JSON.
        2. **JSON Structure**: Each object in the array must have the following structure:
        - `title`: (String) The name of the dish in Russian.
        - `description`: (String) A short (1-2 sentences), appetizing description of the dish in Russian.
        - `cookingTime`: (String) Approximate cooking time (e.g. "25 minutes", "1 hour").
        - `ingredients`: (Array of Strings) A list of necessary ingredients. Include both those provided by the user and any additional ingredients that may be needed (salt, pepper, oil, etc.).
        - `instructions`: (Array of Strings) Step-by-step cooking instructions. Each step is a separate element of the array.
        3. **Variety**: Offer different types of dishes (e.g. salad, main course, soup) if possible with the given ingredients.
        4. **Realistic**: Recipes should be realistic and doable.

        Example of expected JSON response format:
        [
        {
        "title": "Chicken breast with vegetables",
        "description": "A quick and healthy dish, perfect for dinner.",
        "cookingTime": "30 minutes",
        "ingredients": [
        "Chicken breast: 1 pc",
        "Tomato: 2 pcs",
        "Olive oil: 2 tbsp.",
        "Salt, pepper: to taste"
        ],
        "instructions": [
        "Cut the chicken breast into cubes.",
        "Heat the frying pan with olive oil.",
        "Fry the chicken until golden brown.",
        "Add chopped tomatoes and simmer for 10 minutes." ]
        },
        {
        "title": "Tomato Omelette",
        "description": "A classic breakfast that's ready in minutes.",
        "cookingTime": "15 minutes",
        "ingredients": [
        "Eggs: 3 pcs",
        "Tomato: 1 pc",
        "Milk: 50 ml",
        "Salt: to taste"
        ],
        "instructions": [
        "Chop the tomato.",
        "Whisk the eggs with milk and salt.",
        "Pour the egg mixture into the pan with the tomatoes.",
        "Cook covered over medium heat until done."
        ]
        }
        ]
        """
    }
}
