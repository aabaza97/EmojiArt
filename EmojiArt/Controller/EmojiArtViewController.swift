//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Ahmed Abaza on 26/12/2021.
//

import UIKit

fileprivate let reuseIdentifier: String = "emojiCell"
fileprivate let placeholderReuseIdentifier: String = "dropPlaceholderCell"
fileprivate let addEmojiReuseIdentifier: String = "addEmojiButtonCell"
fileprivate let inputReuseIdentifier: String = "emojiInputCell"

class EmojiArtViewController: UIViewController {
    
    //MARK: -Properties
    private var imageFetcher: ImageFetcher!
    private var emojis: [String] = "🐒🦉🐰🦋🍎🧅🐧🐸🐢🦖😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map {String($0)}
    
    private var font: UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(50.0))
    }
    
    private var isAddingEmoji: Bool = false
    
    
    
    //MARK: -Outlets
    @IBOutlet weak var dropZoneView: UIView!{
        didSet {
            let interaction = UIDropInteraction(delegate: self)
            self.dropZoneView.addInteraction(interaction)
        }
    }
    @IBOutlet weak var emojiArtView: EmojiArtView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //TODO: -scrollview setup...
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.delegate = self
            emojiCollectionView.dataSource = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.splitViewController?.preferredDisplayMode != .oneOverSecondary {
            self.splitViewController?.preferredDisplayMode = .oneOverSecondary
        }
    }
    
    
    
    //MARK: -Actions
    @IBAction func didTapAddEmoji() -> Void {
        self.isAddingEmoji = true
        self.emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
}



//MARK: -EmojiArtViewController Drop Delegate
extension EmojiArtViewController: UIDropInteractionDelegate  {
    //can handle
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        //simply syaing if you're not that kind of drage don't even talk to me... meh!
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    //session did update
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    //perform drop
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        self.imageFetcher = ImageFetcher() { url, image in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
                self.spinner.stopAnimating()
            }
        }
        
        
        session.loadObjects(ofClass: NSURL.self) { data in
            guard let url = data.first as? URL else {return}
            self.spinner.startAnimating()
            self.imageFetcher.fetch(url)
        }
        
        session.loadObjects(ofClass: UIImage.self) { data in
            guard let image = data.first as? UIImage else {return}
            self.imageFetcher.backup = image
            
        }
    }
}



//MARK: -CollectionView DataSource
extension EmojiArtViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return self.emojis.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell
            else { return UICollectionViewCell() }
            
            let text = NSAttributedString(
                string: self.emojis[indexPath.row],
                attributes: [.font: self.font]
            )
            cell.emojiLabel.attributedText = text
            return cell
        } else if (isAddingEmoji){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputReuseIdentifier ,for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addEmojiReuseIdentifier ,for: indexPath)
            return cell
        }
    }
    
    
}


//MARK: -Collecview Delegate
extension EmojiArtViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //TODO: - Later on b2a 😂
}


//MARK: -CollectionView Drag&Drop Delegate
extension EmojiArtViewController: UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isAddingEmoji && indexPath.section == 0 {
            return CGSize(width: 300.0, height: 80)
        } else {
            return CGSize(width: 80.0, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is EmjoiInputCollectionViewCell {
//            inputCell.inputField.becomeFirstResponder()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return self.dragItems(for: indexPath)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        self.dragItems(for: indexPath)
    }
    
    
    // can handle collection view version
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    
    // drop session did update
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isDragInsideCollectionView: Bool = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isDragInsideCollectionView ? .move : .copy , intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        /*
         Here we have 2 cases
         1- in which we're performing drop of a collection view item inside the collection view itself
         2- in which we're performing drop of a some other item from outer sourse other than the collection view inside the collection view itself
         */
        
        //capture the index path of the drop posiotion (get to know where you're dropping the item)
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        //check the drop items wheather they're coming from the source(ie. inside the collection view) or somewhere else
        for dropItem in coordinator.items {
            //if the drop item is coming from the source (my self which is the collection view), update the model, get the infoooo
            //and there will be no need to look into the local context of the drop item to know it's coming from my self.
            
            switch dropItem.sourceIndexPath {
            case .some(let sourceIndexPath):
                guard let attrString = dropItem.dragItem.localObject as? NSAttributedString else { break }
                collectionView.performBatchUpdates {
                    // perform batch updates is used when we need to make multiple changes to the collection view one by one...
                    self.emojis.remove(at: sourceIndexPath.item)
                    self.emojis.insert(attrString.string, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
                
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
                break
            case .none:
                /*
                 There is a critical case here...
                 - what if the data we're dropping from the extenral source takes a long time to fetch???
                 -> to handle this case we use "PlaceHolders" and the collection view will manage that for you ;)
                 */
                let dropPlaceholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: placeholderReuseIdentifier)
                let placeHolderContext = coordinator.drop(dropItem.dragItem, to: dropPlaceholder)
                
                dropItem.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { provider, error in
                    guard let attrString = provider as? NSAttributedString, error == nil else {
                        placeHolderContext.deletePlaceholder()
                        return
                    }
                    DispatchQueue.main.async {
                        placeHolderContext.commitInsertion { insertionIndexPath in
                            //insertion index path can be different from the destination index path as it may take sometime to load the conetent
                            // that's why we used the placeholder in the first place to prevent freezing the ui for the user!
                            self.emojis.insert(attrString.string, at: insertionIndexPath.item)
                        }
                    }
                }
                break
            }
        }
    }
    
    
    private func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let attrString = (self.emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText,
              !self.isAddingEmoji
        else { return [] }
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attrString))
        //shor circuiting the local (in app) drags to save some time and work....
        //it's still going to work for external drags of course but for the app it self it's going be simpler here!
        dragItem.localObject = attrString
        return  [dragItem]
    }
    
    
}
