//
//  ProfileCell.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 4/30/21.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    //MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configureViewModel()
        }
    }
    
    private let postImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "venom-7"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureViewModel() {
        guard let viewModel = viewModel else { return }
        
        postImageView.sd_setImage(with: viewModel.imageUrl)
    }
}
