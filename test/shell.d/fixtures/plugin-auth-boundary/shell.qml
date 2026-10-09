import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root

  property var calls: []
  property QtObject ownService: QtObject {
    property string marker: "own"
    property var manifest: null
  }

  AuthStoreOwner { id: authStoreOwner }
  AuthStoreReader { id: authStoreReader }

  Component {
    id: apiComponent
    PluginShellApi { }
  }

  FileView {
    id: resultFile
    path: Quickshell.env("KESTREL_QML_TEST_RESULT")
    atomicWrites: true
  }

  Component.onCompleted: {
    var caller = "example.safe"
    authStoreOwner.retain("kestrel.lock", root.ownService)
    authStoreOwner.updateManifest("kestrel.lock", { version: "kept" })
    var api = apiComponent.createObject(null, {
      pluginId: caller,
      idleConfig: { screensaver: 60, lock: 120 },
      _serviceLookup: function(requestedId) {
        return requestedId === caller ? root.ownService : null
      },
      _summon: function(requestedId) {
        if (requestedId !== caller) return false
        root.calls = root.calls.concat(["summon"])
        return true
      },
      _hide: function(requestedId) {
        if (requestedId !== caller) return false
        root.calls = root.calls.concat(["hide"])
        return true
      },
      _toggle: function(requestedId) {
        if (requestedId !== caller) return false
        root.calls = root.calls.concat(["toggle"])
        return true
      },
      _isOpen: function(requestedId) { return requestedId === caller },
      _updateSettings: function(requestedId) {
        if (requestedId !== caller) return false
        root.calls = root.calls.concat(["settings"])
        return true
      }
    })

    var own = api.serviceFor(caller)
    var result = {
      detached: api.parent === undefined || api.parent === null,
      ownService: own && own.marker === "own",
      foreignService: api.serviceFor("kestrel.lock") === null,
      firstPartyService: api.firstPartyServiceFor("kestrel.polkit") === null,
      ownSummon: api.summon(caller, "{}") === true,
      foreignSummon: api.summon("kestrel.lock", "{}") === false,
      ownHide: api.hide(caller) === true,
      foreignHide: api.hide("kestrel.lock") === false,
      ownToggle: api.toggle(caller, "{}") === true,
      foreignToggle: api.toggle("kestrel.lock", "{}") === false,
      ownOpen: api.isPluginOpen(caller) === true,
      foreignOpen: api.isPluginOpen("kestrel.lock") === false,
      ownSettings: api.updateEntryInline(caller, {}) === true,
      foreignSettings: api.updateEntryInline("kestrel.lock", {}) === false,
      detachedIdleConfig: api.idleConfig.screensaver === 60 && api.idleConfig.lock === 120,
      authStoreOwnerRetains: authStoreOwner.has("kestrel.lock") === true,
      authStoreOwnerRemembersTrust: authStoreOwner.isTrusted("kestrel.lock") === true,
      authStoreOwnerUpdatesManifest: root.ownService.manifest
        && root.ownService.manifest.version === "kept",
      authStoreImportIsolated: authStoreReader.has("kestrel.lock") === false,
      noGenericPluginShellFactory: typeof api.pluginShellForId !== "function",
      calls: root.calls
    }
    result.ok = Object.keys(result).every(function(key) {
      return key === "ok" || key === "calls" || result[key] === true
    }) && JSON.stringify(result.calls) === JSON.stringify(["summon", "hide", "toggle", "settings"])
    resultFile.setText(JSON.stringify(result))
  }
}
