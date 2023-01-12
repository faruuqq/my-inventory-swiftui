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
    
    @State private var showInLaundry = false
    @State private var showAddInventory = false
    @State private var addLabel = ""
    @State private var uploadedImage: UIImage?
    @State private var showAlert = false
    @State private var errorString = ""
    
    var filteredInventories: [Inventory] {
        inventories.filter { inventory in
            (!showInLaundry || inventory.isInLaundry)
        }
    }
    
    var body: some View {
        List {
            Toggle(isOn: $showInLaundry) {
                if showInLaundry {
                    Text("In laundry")
                } else {
                    Text("Currently in laundry")
                }
            }
            
            ForEach(filteredInventories) { inventory in
                NavigationLink {
                    InventoryDetail(inventory: inventory)
                } label: {
                    HStack {
                        inventoryImage(from: inventory)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(5)
                        
                        VStack(alignment: .leading) {
                            Text(inventory.label ?? "No Label")
                            Text("Times In laundry: \(inventory.timesInLaundry)x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if inventory.isInLaundry {
                            Spacer()
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.teal)
                        }
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        markInLaundry(inventory: inventory)
                    } label: {
                        Label("", systemImage: "archivebox.fill")
                    }
                    .tint(inventory.isInLaundry ? .red : .teal)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
            if showInLaundry {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: markFinished) {
                        Label("Mark finished", systemImage: "checkmark.circle.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddInventory, onDismiss: {
            guard !addLabel.isEmpty else { return }
            let newInventory = Inventory(context: viewContext)
            newInventory.label = addLabel
            if let uploadedImage {
                newInventory.image = uploadedImage.jpegData(compressionQuality: 0)
            }
            newInventory.isInLaundry = false
            newInventory.timesInLaundry = 0
            newInventory.timestamp = Date()
            do {
                try viewContext.save()
            } catch {
                errorString = error.localizedDescription
            }
        }) {
            AddInventory(
                label: $addLabel,
                isBeingPresented: $showAddInventory,
                uploadedImage: $uploadedImage)
            .ignoresSafeArea()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorString),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }
}

// MARK: - Functions
extension InventoryView {
    private func markInLaundry(inventory: Inventory) {
        withAnimation {
            inventory.isInLaundry.toggle()
            if inventory.isInLaundry {
                inventory.timesInLaundry += 1
            }
            do {
                try viewContext.save()
            } catch {
                errorString = error.localizedDescription
            }
        }
    }
    
    fileprivate func addItem() {
        showAddInventory.toggle()
    }

    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { inventories[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                errorString = error.localizedDescription
            }
        }
    }
    
    fileprivate func inventoryImage(from inventory: Inventory) -> Image {
        var defaultImage = Image("ImagePlaceholder")
        if let imageData = inventory.image,
            let uiImage = UIImage(data: imageData) {
            defaultImage = Image(uiImage: uiImage)
        }
        return defaultImage
    }
    
    fileprivate func markFinished() {
        withAnimation {
            filteredInventories.forEach { $0.isInLaundry.toggle() }
            do {
                try viewContext.save()
            } catch {
                errorString = error.localizedDescription
            }
        }
    }
}

// MARK: - Previews
struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
