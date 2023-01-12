//
//  InventoryDetail.swift
//  MyInventory
//
//  Created by Muhammad Faruuq Qayyum on 10/01/23.
//

import SwiftUI

struct InventoryDetail: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var showAlert = false
    @State private var showAlertConfirmation = false
    @State private var errorString = ""
    
    var inventory: Inventory
    
    var body: some View {
        VStack(spacing: 0) {
            inventoryImage(from: inventory)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: UIScreen.main.bounds.height * 0.5)
            List {
                Section {
                    HStack {
                        Text("Label")
                        Spacer()
                        Text(inventory.label ?? "No Label")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Times in laundry")
                        Spacer()
                        Text("\(inventory.timesInLaundry)x")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Data added")
                        Spacer()
                        Text("\(inventory.timestamp ?? Date(), formatter: itemFormatter)")
                            .foregroundColor(.secondary)
                    }
                }
                
                if inventory.isInLaundry {
                    Section {
                        HStack {
                            Spacer()
                            Label("In Laundry", systemImage: "archivebox.fill")
                                .foregroundColor(.teal)
                            Spacer()
                        }
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button {
                            showAlertConfirmation.toggle()
                        } label: {
                            Text("Delete item")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Text("ID: \(inventory.id.debugDescription)")
                        Spacer()
                    }
                }

            }
        }
        .ignoresSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorString),
                dismissButton: .cancel(Text("OK"))
            )
        }
        .alert("Warning", isPresented: $showAlertConfirmation) {
            HStack {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }

    }
}

// MARK: - Functions
extension InventoryDetail {
    private func inventoryImage(from inventory: Inventory) -> Image {
        var defaultImage = Image("ImagePlaceholder")
        if let imageData = inventory.image,
            let uiImage = UIImage(data: imageData) {
            defaultImage = Image(uiImage: uiImage)
        }
        return defaultImage
    }
    
    private func deleteItem() {
        withAnimation {
            viewContext.delete(inventory)
            do {
                try viewContext.save()
            } catch {
                errorString = error.localizedDescription
            }
        }
    }
    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Previews
struct InventoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let inventories = try! viewContext.fetch(Inventory.fetchRequest())
        let withLaundry = inventories.first(where: { $0.isInLaundry })!
        InventoryDetail(inventory: withLaundry)
    }
}
