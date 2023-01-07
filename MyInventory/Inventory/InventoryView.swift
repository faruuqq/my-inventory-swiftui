//
//  InventoryView.swift
//  MyInventory
//
//  Created by Muhammad Faruuq Qayyum on 07/01/23.
//

import SwiftUI

struct InventoryView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Inventory.timestamp, ascending: false)], animation: .easeIn)
    private var inventories: FetchedResults<Inventory>
    
    @State private var editMode: EditMode = .inactive
    @State private var multiSelection = Set<ObjectIdentifier>()
    
    var body: some View {
        NavigationView {
            List(selection: $multiSelection) {
                ForEach(inventories, id: \.id) { inventory in
                    NavigationLink {
                        VStack {
                            inventoryImage(from: inventory)
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(5)
                            Text(inventory.label ?? "No Label")
                            Text("Added at \(inventory.timestamp!, formatter: itemFormatter)")
                            Spacer(minLength: 50)
                        }
                    } label: {
                        InventoryRow(inventory: inventory)
                    }
                    .toolbar(.hidden, for: .bottomBar)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                if $editMode.wrappedValue == .active {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: moveToLaundry) {
                            Label("Mark in laundry", systemImage: "archivebox.fill")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
            }
            .navigationTitle("My Inventory")
            .environment(\.editMode, $editMode)
        }
    }
}

// MARK: - Functions
extension InventoryView {
    fileprivate func addItem() {
        withAnimation {
            let labels = [
                "Hoodie",
                "Sweater",
                "Long Pants",
                "Short Pants",
                "T-Shirt",
                "Shirt",
                "Underwear",
                "Hat",
                "Socks",
                "Gloves"
            ]
            for i in 0..<7 {
                let newItem = Inventory(context: viewContext)
                newItem.isInLaundry = i % 2 == 0 ? true : false
                newItem.label = labels[i]
                newItem.timesInLaundry = Int16(i)
                newItem.timestamp = Date()
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
//        withAnimation {
//            let newItem = Inventory(context: viewContext)
//            newItem.label = "New item"
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
    }

    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { inventories[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    fileprivate func inventoryImage(from inventory: Inventory) -> Image {
        var defaultImage = Image("ImagePlaceholder")
        if let imageData = inventory.image,
            let uiImage = UIImage(data: imageData) {
            defaultImage = Image(uiImage: uiImage)
        }
        return defaultImage
    }
    
    fileprivate func moveToLaundry() {
        print("--faruuq: move to laundry")
    }
}

// MARK: - Previews
struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
