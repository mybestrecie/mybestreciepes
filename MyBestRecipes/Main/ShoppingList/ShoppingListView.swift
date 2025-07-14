//
//  ShoppingListView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  ShoppingListView.swift
import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    List {
                        Section {
                            HStack {
                                TextField("Add product...", text: $viewModel.newItemName, onCommit: viewModel.addItem)
                                Button(action: viewModel.addItem) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.appAccent)
                                }
                                .disabled(viewModel.newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                        
                        // Секция с основным списком
                        Section {
                            if viewModel.items.isEmpty {
                                Text("Your shopping list is empty.")
                                    .foregroundColor(.appSecondaryText)
                            } else {
                                ForEach(viewModel.sortedItems) { item in
                                    ShoppingItemRow(item: item) {
                                        viewModel.toggleItem(id: item.id)
                                    }
                                }
                                .onDelete(perform: viewModel.deleteItems)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden) // Делает фон List прозрачным
                }
            }
            .navigationTitle("Shopping list")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }.foregroundColor(.appAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") { viewModel.clearPurchasedItems() }
                        .foregroundColor(viewModel.hasPurchasedItems ? .appAccent : .appSecondaryText)
                        .disabled(!viewModel.hasPurchasedItems)
                }
            }
        }
        .tint(.appAccent)
        .preferredColorScheme(.dark)
    }
}

// Отдельный View для строки списка, чтобы код был чище
struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                Image(systemName: item.isPurchased ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(item.isPurchased ? .appAccent : .appSecondaryText)
                
                Text(item.name)
                    .strikethrough(item.isPurchased, color: .appSecondaryText)
                    .foregroundColor(item.isPurchased ? .appSecondaryText : .appPrimaryText)
                
                Spacer()
            }
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
