import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var sightingTextView: UITextView!
    @IBOutlet weak var classinateButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataRobotLogoImageView: UIImageView!

    private var classinator = Classinator.shared
    private var locator = Locator.shared
    private var messages = Messages.shared

    private let tapGestureRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        tapGestureRecognizer.addTarget(self, action: #selector(logoTapped(tapGestureRecognizer:)))
        dataRobotLogoImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sightingTextView.resignFirstResponder()
            return false
        }

        return true
    }

    @IBAction func classinateButtonTapped(_ sender: Any) {
        let sighting: String = self.sightingTextView?.text ?? ""
        let latitude: Double = locator.latitude
        let longitude: Double = locator.longitude

        startActivityIndication()

        _ = classinator.classinate(latitude: latitude, longitude: longitude, sighting: sighting)
            .done { classination in
                self.clearInput()
                self.showResults(classination: classination)
            }
            .ensure {
                self.stopActivityIndication()
            }
            .catch { error in
                self.showError(error: error)
            }
    }

    @objc func logoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let url = URL(string: "https://www.datarobot.com/") {
            UIApplication.shared.open(url)
        }
    }

    private func clearInput() {
        sightingTextView.text = ""
    }

    private func showResults(classination: Classination) {
        let title = classination.rawValue
        let message = self.messages.fetchMessage(classination: classination)
        showAlert(title: title, message: message)
    }

    private func showError(error: Error) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }

    private func startActivityIndication() {
        sightingTextView.isEditable = false
        sightingTextView.isSelectable = false
        classinateButton.isEnabled = false
        activityIndicator.startAnimating()
    }

    private func stopActivityIndication() {
        activityIndicator.stopAnimating()
        classinateButton.isEnabled = true
        sightingTextView.isSelectable = true
        sightingTextView.isEditable = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
