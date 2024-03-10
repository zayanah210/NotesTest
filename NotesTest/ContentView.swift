//
//  ContentView.swift
//  NotesTest
//
//  Created by Tuhin Mahmud on 3/10/24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var text: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Spacer() // Push the scrolling bar to the middle of the screen
                ScrollView(.horizontal, showsIndicators: false) { // Hide scroll indicators
                    HStack(spacing: 16) { // Adjust the spacing as needed
                        ForEach(items) { item in
                            VStack {
                                NavigationLink(destination: EditNoteView(item: item)) {
                                    Image("craneImage") // Assuming "craneImage" is the name of your image asset
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200) // Adjust the width and height as needed
                                        .padding()
                                        .background(Color.clear) // Set background color to clear
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue, lineWidth: 2) // Add a border
                                        )
                                }
                            }
                            .id(item) // Ensure each item has a unique identifier
                        }
                    }
                }
                .frame(height: 100) // Adjust the height as needed
                .padding()
                .onAppear {
                    // Ensure the list scrolls to the end when it appears
                    withAnimation {
                        scrollToBottom()
                    }
                }
                Spacer() // Add a spacer to push the button to the bottom of the screen
                
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
                .padding()
            }
            .navigationBarTitle("Items")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func scrollToBottom() {
        guard let lastItem = items.last else { return }
        DispatchQueue.main.async {
            withAnimation {
                // Scroll to the last item
            }
        }
    }
}

struct EditNoteView: View {
    @ObservedObject var item: Item
    @State private var editedNote: String

    init(item: Item) {
        self.item = item
        self._editedNote = State(initialValue: item.note ?? "")
    }

    var body: some View {
        VStack {
            TextEditor(text: $editedNote)
                .frame(width: 200, height: 200) // Set the width and height as needed
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            Button("Save") {
                saveNote()
            }
            .padding()
        }
        .navigationBarTitle("Edit Note")
    }

    private func saveNote() {
        item.note = editedNote
        do {
            try item.managedObjectContext?.save()
        } catch {
            print("Error saving note: \(error)")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
