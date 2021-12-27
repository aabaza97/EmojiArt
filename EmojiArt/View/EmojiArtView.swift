//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Ahmed Abaza on 26/12/2021.
//

import UIKit

class EmojiArtView: UIView {
    
    //MARK: -Inits & Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    private func configure() {
        self.addInteraction(UIDropInteraction(delegate: self))
    }
    
    
    var backgroundImage: UIImage? {didSet {self.setNeedsDisplay()}}
    
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}



//MARK: -View Drop Delegate
extension EmojiArtView: UIDropInteractionDelegate {
    //can handle
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    //session did update
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }
    
    //perform drop
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            let dropLocation = session.location(in: self)
            providers.forEach { provider in
                guard let attrString = provider as? NSAttributedString else { return }
                self.embedInView(attrString, at: dropLocation)
            }
        }
    }
    
    private func embedInView(_ attributedString: NSAttributedString, at location: CGPoint) -> Void {
        let lbl = UILabel()
        lbl.backgroundColor = .clear
        lbl.attributedText = attributedString
        lbl.sizeToFit()
        lbl.center = location
        self.addEmojiArtGestureRecognizers(to: lbl)
        self.addSubview(lbl)
    }
}

