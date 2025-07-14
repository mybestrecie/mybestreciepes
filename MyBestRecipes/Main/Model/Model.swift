//
//  Model.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

//  Recipe.swift
import Foundation

// Новая структура для рецепта. Используем struct, так как это просто набор данных.
// Hashable нужен для навигации, Identifiable для списков.
struct Recipe: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let image: String // Переименовали 'image' в 'imageName' для ясности
    let description: String
    let cookingTime: String
    let servings: String
    let ingredients: [String]
    let cookingSteps: [String]
    let category: String // Добавим категорию для фильтрации

    // Псевдоним для Codable, чтобы сопоставить 'image' из JSON с 'imageName'
    private enum CodingKeys: String, CodingKey {
        case id, name, description, cookingTime, servings, ingredients, cookingSteps, category, image
        //case imageName = "image"
    }
    
    // Моковый рецепт для превью и тестов
    static let mock = Recipe(
        id: "1",
        name: "Классический Тирамису",
        image: "tiramisu_placeholder", // Используй то же имя, что и в HomeView
        description: "Нежный итальянский десерт, который покорит ваше сердце. Слои пропитанного эспрессо печенья савоярди, сливочного крема маскарпоне и какао.",
        cookingTime: "30 мин",
        servings: "6 порций",
        ingredients: ["Печенье 'Дамские пальчики' 200г", "Сыр Маскарпоне 250г", "Жирные сливки 120мл", "Сахар 100г", "Яичные желтки 4 шт", "Кофе эспрессо 1 чашка", "Какао-порошок для посыпки"],
        cookingSteps: ["Сварите эспрессо и дайте ему остыть.", "Взбейте желтки с сахаром до светлой, кремовой массы.", "Добавьте маскарпоне и аккуратно перемешайте.", "В отдельной миске взбейте сливки до устойчивых пиков и введите в смесь с маскарпоне.", "Быстро окунайте печенье в эспрессо и выкладывайте слоем в форму.", "Распределите половину крема поверх печенья.", "Повторите слои.", "Посыпьте какао-порошком и уберите в холодильник на 4 часа."],
        category: "cake"
    )
}



// Структура для декодирования ответа от Gemini
struct GeneratedRecipe: Decodable {
    let recipeName: String
    let description: String
    let cookingTime: String
    let ingredients: [Ingredient]
    let cookingSteps: [String]
    let tip: String // Полезный совет от шефа
    
    struct Ingredient: Decodable {
        let name: String
        let quantity: String
    }
}



// Codable позволяет легко кодировать/декодировать объект в/из JSON (для UserDefaults)
struct ShoppingItem: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var isPurchased: Bool

    init(name: String, isPurchased: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isPurchased = isPurchased
    }
}


struct CookingTip: Codable, Identifiable {
    // Используем title как ID, так как он уникален в нашем JSON
    var id: String { title }
    let title: String
    let shortDescription: String
    let longDescription: String

    // Помогает сопоставить snake_case из JSON с camelCase в Swift
    enum CodingKeys: String, CodingKey {
        case title
        case shortDescription = "short_description"
        case longDescription = "long_description"
    }
}
