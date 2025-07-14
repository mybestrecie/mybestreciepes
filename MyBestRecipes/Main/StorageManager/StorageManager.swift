//
//  StorageManager.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//



import Foundation
import RealmSwift


class RealmRecipe: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var recipeId: String
    
    @Persisted var name: String
    @Persisted var image: String
    
    @Persisted var recipeDescription: String
    @Persisted var cookingTime: String
    @Persisted var servings: String
    
    @Persisted var ingredients: List<String>
    @Persisted var cookingSteps: List<String>
    
    @Persisted var imageData: Data?
}

class StorageManager {
    static let shared = StorageManager()
    let realm: Realm
    
    // Результаты, которые автоматически обновляются
    @ObservedResults(RealmRecipe.self) var recipes
    
    private init() {
        // Конфигурация для миграции, если модель будет меняться
        let config = Realm.Configuration(
            schemaVersion: 1, // Увеличивайте, если меняете структуру @Persisted свойств
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Код миграции, если понадобится
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
            print("Realm is located at:", realm.configuration.fileURL!)
        } catch {
            fatalError("Failed to instantiate Realm: \(error)")
        }
    }

    // ВАША СУЩЕСТВУЮЩАЯ ФУНКЦИЯ (идеально подходит)
    func addNewRecipe(name: String, description: String, ingredients: [String], steps: [String], data: Data) {
        let recipe = RealmRecipe()
        recipe.recipeId = "" // Ключевой момент! Пустой ID означает, что это рецепт пользователя.
        recipe.name = name
        recipe.recipeDescription = description
        
        let ingredientsList = List<String>()
        ingredientsList.append(objectsIn: ingredients)
        recipe.ingredients = ingredientsList
        
        let stepsList = List<String>()
        stepsList.append(objectsIn: steps)
        recipe.cookingSteps = stepsList
        
        recipe.imageData = data
        
        try! realm.write {
            realm.add(recipe)
        }
    }

    // НОВАЯ ФУНКЦИЯ ДЛЯ УДАЛЕНИЯ
    func deleteUserRecipe(id: ObjectId) {
        if let recipeToDelete = realm.object(ofType: RealmRecipe.self, forPrimaryKey: id) {
            try? realm.write {
                realm.delete(recipeToDelete)
            }
        }
    }
    
    // Эти функции для работы с "Избранным" из каталога мы не трогаем
    func toggleRecipeLike(recipe: Recipe) {

        // Пытаемся найти рецепт по ID
        if let existingRecipe = realm.objects(RealmRecipe.self).filter("recipeId == %@", recipe.id).first {
            // Если рецепт уже есть, удаляем его
            try! realm.write {
                realm.delete(existingRecipe)
            }
        } else {
            // Если рецепт отсутствует, добавляем его
            let realmRecipe = RealmRecipe()
            realmRecipe.recipeId = recipe.id
            realmRecipe.name = recipe.name
            realmRecipe.image = recipe.image
            realmRecipe.recipeDescription = recipe.description
            realmRecipe.cookingTime = recipe.cookingTime
            realmRecipe.servings = recipe.servings
            realmRecipe.ingredients.append(objectsIn: recipe.ingredients)
            realmRecipe.cookingSteps.append(objectsIn: recipe.cookingSteps)

            try! realm.write {
                realm.add(realmRecipe)
            }
        }
    }
    
    
    func isRecipeLiked(recipe: Recipe) -> Bool {
        return realm.objects(RealmRecipe.self).filter("recipeId == %@", recipe.id).first != nil
    }
    
    func addMasterpiece(imageData: Data, caption: String) {
           let newMasterpiece = Masterpiece(imageData: imageData, caption: caption)
           
           do {
               try realm.write {
                   realm.add(newMasterpiece)
               }
           } catch {
               print("Error saving masterpiece: \(error)")
           }
       }

       // Удаление шедевра по его ID
       func deleteMasterpiece(id: ObjectId) {
           if let masterpieceToDelete = realm.object(ofType: Masterpiece.self, forPrimaryKey: id) {
               try? realm.write {
                   realm.delete(masterpieceToDelete)
               }
           }
       }
}




final class Masterpiece: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
  
    @Persisted var imageData: Data
    
   
    @Persisted var createdAt: Date = Date()
    
    @Persisted var caption: String = ""

   
    convenience init(imageData: Data, caption: String = "") {
        self.init()
        self.imageData = imageData
        self.caption = caption
    }
}
