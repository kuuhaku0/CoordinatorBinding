//
//  WordInputViewController.swift
//  Coordinator Binding
//
//  Created by Tyler Zhao on 4/29/23.
//

import Combine
import UIKit

class WordInputViewController: UIViewController {
	struct Output {
		let textDidChange = CurrentValueSubject<String, Never>("")
		let publishWord = JustPassthrough<Word>()
		let rewind = VoidPassthrough()
	}

	lazy var textField: UITextField = {
		let tf = UITextField()
		tf.textAlignment = .center
		tf.tintColor = .blue
		tf.backgroundColor = .white
		tf.delegate = self
		tf.textColor = .blue
		tf.autocorrectionType = .no
		return tf
	}()

	private var cancelBag = CancelBag()
	private let outputs = Output()

	var forwardPassthrough = VoidPassthrough()
	var backwardPassthrough = VoidPassthrough()

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		textField.becomeFirstResponder()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		outputs.textDidChange.send(textField.text ?? "")
	}

	init(word: Word?) {
		super.init(nibName: nil, bundle: nil)
		textField.text = word?.text
		outputs.textDidChange.send(word?.text ?? "")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		view.backgroundColor = .black

		view.addSubview(textField)
		textField.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().inset(100)
			make.leading.trailing.equalToSuperview().inset(32)
			make.height.equalTo(44)
		}
	}

	func transform(input: SentenceBuilderActions) -> Output {
		backwardPassthrough
			.sink { [unowned self] in
				outputs.rewind.send()
			}.store(in: &cancelBag)

		forwardPassthrough
			.sink { [unowned self] in
				guard navigationController?.topViewController == self else { return }
				let text = outputs.textDidChange.value
				guard !text.isEmpty else { return }

				outputs.publishWord.send(Word(text: text))
			}.store(in: &cancelBag)

		return outputs
	}
}

extension WordInputViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentText = textField.text ?? ""
		guard let stringRange = Range(range, in: currentText) else {
			outputs.textDidChange.send("")
			return false
		}

		let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

		if updatedText.split(separator: " ").count > 1 {
			outputs.textDidChange.send("")
		} else {
			let trimmedText = updatedText.split(separator: " ").first ?? ""
			outputs.textDidChange.send(String(trimmedText))
		}
		return true
	}
}

extension WordInputViewController: SentenceBuildable {}
