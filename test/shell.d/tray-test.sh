#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')

assert(tray.itemNamed({ id: 'dropbox-client' }, 'dropbox'), 'tray matches item ids')
assert(tray.itemNamed({ title: 'Dropbox' }, 'dropbox'), 'tray matches item titles')
assert(tray.itemNamed({ tooltipTitle: 'LocalSend' }, 'localsend'), 'tray matches item tooltips')
assert(!tray.itemNamed({ id: 'nextcloud' }, 'dropbox'), 'tray ignores items named for something else')

const layout = {
  left: [{ id: 'helios.menu' }],
  center: [],
  right: [{ id: 'helios.dropbox' }, { id: 'helios.tray' }]
}

assert(tray.layoutHasWidget(layout, 'helios.dropbox'), 'tray finds dedicated dropbox widget in layout')
assert(tray.ownedByHeliOS({ id: 'dropbox' }, layout), 'tray suppresses dropbox when dedicated widget is in bar')
assert(!tray.ownedByHeliOS({ id: 'dropbox' }, { left: [], center: [], right: [] }), 'tray keeps dropbox when dedicated widget is absent')
assert(tray.ownedByHeliOS({ id: 'qlBCprNUqU', title: 'localsend' }, { left: [], center: [], right: [] }), 'tray suppresses localsend regardless of layout')
assert(!tray.ownedByHeliOS({ id: 'nextcloud' }, layout), 'tray keeps unrelated tray items')
JS
