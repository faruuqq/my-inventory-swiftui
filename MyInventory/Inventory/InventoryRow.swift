//
//  InventoryRow.swift
//  MyInventory
//
//  Created by Muhammad Faruuq Qayyum on 07/01/23.
//

import SwiftUI

struct InventoryRow: View {
    
    @State var inventory: Inventory
    
    var body: some View {
        HStack {
            inventoryImage()
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Text(inventory.label ?? "No Label")
                Text("In laundry: \(inventory.timesInLaundry)x")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Functions
extension InventoryRow {
    fileprivate func inventoryImage() -> Image {
        var defaultImage = Image("ImagePlaceholder")
        if let imageData = inventory.image,
            let uiImage = UIImage(data: imageData) {
            defaultImage = Image(uiImage: uiImage)
        }
        return defaultImage
    }
}

// MARK: - Previews
struct InventoryRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let inventories = try! viewContext.fetch(Inventory.fetchRequest())
        InventoryRow(inventory: inventories[0])
    }
}
