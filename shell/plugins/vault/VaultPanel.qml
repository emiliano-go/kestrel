import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Unlock dialog for the portable vault (kestrel-vault). The vault is a LUKS2
// container baked into the ISO; unlocking mounts it writable for the session
// through a copy-on-write store, so edits are discarded on lock. Summoned with
// `kestrel-shell shell summon kestrel.vault '{}'` or `kestrel vault unlock`.
//
// The passphrase is written to the command's stdin, never to its arguments, so
// it cannot leak through the process list.
Item {
  id: root

  property var shell: null
  property bool closingFromHost: false

  property string vaultStatus: "unknown"
  property string message: ""
  property bool busy: false
  property bool failed: false

  readonly property bool unlocked: vaultStatus === "unlocked"

  function refreshStatus() {
    if (!statusProcess.running) statusProcess.running = true
  }

  // Host-initiated open. Payload is unused; kept for the summon contract.
  function open(_payloadJson) {
    closingFromHost = false
    message = ""
    failed = false
    prompt.text = ""
    window.visible = true
    refreshStatus()
    Qt.callLater(function() { prompt.forceActiveFocus() })
  }

  // Host-initiated close (`shell hide`).
  function close() {
    closingFromHost = true
    window.visible = false
    closingFromHost = false
  }

  function submit() {
    if (busy || unlocked || prompt.text.length === 0) return
    busy = true
    failed = false
    message = "Unlocking…"
    unlockProcess.running = true
  }

  function lockVault() {
    if (busy || !unlocked) return
    busy = true
    failed = false
    message = "Locking…"
    lockProcess.running = true
  }

  Process {
    id: statusProcess
    command: ["kestrel-vault", "status"]
    stdout: SplitParser {
      onRead: function(line) {
        var first = String(line).trim().split("\n")[0]
        if (first.indexOf("unlocked") === 0) root.vaultStatus = "unlocked"
        else if (first.indexOf("locked") === 0) root.vaultStatus = "locked"
        else root.vaultStatus = "none"
      }
    }
  }

  Process {
    id: unlockProcess
    command: ["kestrel-vault", "unlock"]
    stdinEnabled: true
    running: false
    onStarted: {
      unlockProcess.write(prompt.text + "\n")
      prompt.text = ""
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var t = String(text).trim()
        if (t.length > 0) root.message = t
      }
    }
    onExited: function(code) {
      root.busy = false
      if (code === 0) {
        root.failed = false
        root.vaultStatus = "unlocked"
        root.message = "Unlocked. Changes are discarded when you lock."
      } else {
        root.failed = true
        root.vaultStatus = "locked"
        if (root.message.indexOf("Unlocking") === 0 || root.message === "")
          root.message = "Could not unlock the vault."
      }
    }
  }

  Process {
    id: lockProcess
    command: ["kestrel-vault", "lock"]
    running: false
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var t = String(text).trim()
        if (t.length > 0) root.message = t
      }
    }
    onExited: function(code) {
      root.busy = false
      if (code === 0) {
        root.failed = false
        root.vaultStatus = "locked"
        root.message = "Locked. Session changes discarded."
      } else {
        root.failed = true
        if (root.message.indexOf("Locking") === 0 || root.message === "")
          root.message = "Could not lock the vault."
      }
    }
  }

  FloatingWindow {
    id: window
    title: "Kestrel vault"
    color: Commons.Color.background
    implicitWidth: 420
    implicitHeight: content.implicitHeight + Style.space(32)
    minimumSize: Qt.size(360, 220)

    onVisibleChanged: {
      if (!visible && !root.closingFromHost && root.shell && typeof root.shell.hide === "function")
        root.shell.hide("kestrel.vault")
    }

    FocusScope {
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.close()

      Column {
        id: content
        anchors.fill: parent
        anchors.margins: Style.space(16)
        spacing: Style.space(12)

        PanelHero {
          width: content.width
          title: "Portable vault"
          meta: root.unlocked ? "Unlocked — session only" : "Locked"
          detail: "Files stay encrypted on the pendrive. Changes live in memory and are discarded when you lock."
        }

        TextField {
          id: prompt
          width: content.width
          password: true
          placeholderText: "Vault passphrase"
          enabled: !root.unlocked && !root.busy
          onAccepted: root.submit()
        }

        Row {
          spacing: Style.space(8)

          Button {
            text: root.busy ? "Working…" : "Unlock"
            visible: !root.unlocked
            enabled: !root.busy && prompt.text.length > 0
            onClicked: root.submit()
          }

          Button {
            text: "Lock"
            visible: root.unlocked
            enabled: !root.busy
            onClicked: root.lockVault()
          }
        }

        Text {
          width: content.width
          wrapMode: Text.WordWrap
          visible: root.message !== ""
          text: (root.failed ? "Error: " : "") + root.message
          color: Commons.Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
