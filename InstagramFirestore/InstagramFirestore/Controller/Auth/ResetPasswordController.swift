//
//  ResetPasswordController.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/14/21.
//

import UIKit

protocol ResetPasswordControllerDelegate: class {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController)
}

class ResetPasswordController: UIViewController {
    //MARK: Properties
    
    private var viewModel = ResetPasswordViewModel()
    
    weak var delegate: ResetPasswordControllerDelegate?
    
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let iconImage = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
    var email: String?
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false;
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(handleBackButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupSubviews()
    }
    
    //MARK: Helpers
    
    func configureUI() {
        configureGradientLayer(color1: UIColor.systemPurple.cgColor, color2: UIColor.systemBlue.cgColor)
    }
    
    func setupSubviews() {
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        view.addSubview(iconImage)
        iconImage.contentMode = .scaleAspectFill
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, resetButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32, paddingRight: 32)
        

        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        if let email = email {
            emailTextField.text = email
            viewModel.email = email
            updateForm()
        }
    }
    
    //MARK: Actions
    
    @objc func handleResetPassword() {
        guard let email = viewModel.email else { return }
        
        showLoader(true)
        
        AuthService.resetPassword(withEmail: email) { (error) in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: Error resetting password \(error.localizedDescription)")
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                return
            }
            
            self.delegate?.controllerDidSendResetPasswordLink(self)
        }
    }
    
    @objc func handleBackButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        switch sender {
        case emailTextField:
            viewModel.email = sender.text
        default:
            print("DEBUG: text changing on unknown textfield :/")
        }
        
        updateForm()
    }
}

// MARK: - FormViewModel

extension ResetPasswordController: IFormViewModel {
    func updateForm() {
        resetButton.backgroundColor = viewModel.buttonBackgroundColor
        resetButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        resetButton.isEnabled = viewModel.formIsValid
    }
}
