import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// My Shortcuts: one bar icon that opens a searchable menu of the keybindings
// you added yourself (parsed from your bindings.lua) plus any extra rows you
// keep in a small text file. Selecting a row runs its command.
BarWidget {
  id: root
  moduleName: "robbied112.my-shortcuts"

  readonly property string script: Qt.resolvedUrl("my-shortcuts.sh").toString().replace(/^file:\/\//, "")
  readonly property string bindingsFile: setting("bindingsFile", "~/.config/hypr/bindings.lua")
  readonly property string extrasFile: setting("extrasFile", "~/.config/omarchy/my-shortcuts.extra")
  readonly property int menuWidth: setting("menuWidth", 980)

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function openMenu() {
    Quickshell.execDetached([script, "--bindings", bindingsFile, "--extras", extrasFile, "--width", String(menuWidth)])
  }
  function editExtras() {
    Quickshell.execDetached([script, "--edit-extras", "--extras", extrasFile])
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.setting("glyph", "󰌌")
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: "My shortcuts · right-click to edit extras"
    onPressed: function(b) {
      if (b === Qt.RightButton) root.editExtras()
      else root.openMenu()
    }
  }
}
