//
//  ShoppingListViewModel.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  ShoppingListViewModel.swift
import Foundation
import Combine

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var newItemName: String = ""
    
    // Удобное свойство, чтобы знать, есть ли что очищать
    var hasPurchasedItems: Bool {
        items.contains { $0.isPurchased }
    }
    
    // Сортируем список: сначала некупленные, потом купленные, все по алфавиту
    var sortedItems: [ShoppingItem] {
        items.sorted {
            if $0.isPurchased != $1.isPurchased {
                return !$0.isPurchased // false (некупленные) идут первыми
            }
            return $0.name.lowercased() < $1.name.lowercased()
        }
    }

    init() {
        self.items = ShoppingListService.shared.loadItems()
    }

    func addItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newItem = ShoppingItem(name: trimmedName)
        items.append(newItem)
        newItemName = ""
        save()
    }

    func toggleItem(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isPurchased.toggle()
        save()
    }

    func deleteItems(at offsets: IndexSet) {
        // Мы должны удалять из оригинального (несортированного) массива,
        // но так как sortedItems - это просто временная сортировка,
        // а не новый массив, нам нужно найти реальные объекты для удаления.
        let idsToDelete = offsets.map { sortedItems[$0].id }
        items.removeAll { idsToDelete.contains($0.id) }
        save()
    }
    
    func clearPurchasedItems() {
        items.removeAll { $0.isPurchased }
        save()
    }

    private func save() {
        ShoppingListService.shared.saveItems(items)
    }
}
