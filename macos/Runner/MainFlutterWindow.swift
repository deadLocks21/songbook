import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController

    // Mode « fenêtre de mise à jour » (songbook --updating) : l'updater desktop
    // (tool/updater) lance l'app avec `--updating …` pour afficher une petite
    // fenêtre (prompt + progression) pendant qu'il télécharge/installe la MAJ.
    // On rétrécit et on centre la fenêtre, au lieu de la grande fenêtre de l'app.
    // Équivalent macOS du bloc `--updating` de windows/runner/main.cpp.
    //
    // Les arguments de ligne de commande atteignent déjà `main(args)` côté Dart :
    // sur macOS, FlutterDartProject.dartEntrypointArguments vaut par défaut le
    // contenu de NSProcessInfo.arguments (sans le nom du binaire) — rien à câbler.
    if CommandLine.arguments.contains("--updating") {
      // Assez haut pour le prompt (titre + 3 boutons) comme pour la progression.
      let contentSize = NSSize(width: 480, height: 250)
      self.setContentSize(contentSize)
      self.styleMask.remove(.resizable) // fenêtre fixe
      self.center()
    } else {
      self.setFrame(windowFrame, display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
