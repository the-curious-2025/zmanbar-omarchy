import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "zmanbar"
  ipcTarget: "zmanbar"
  manageIpc: false

  property var anchorItem: null
  property bool openedFromHotkey: false

  // The bar tracks the widget mounted in its slot (BarWidget.qml), not this
  // nested panel, so anything the bar identifies a panel by has to resolve
  // through that widget.
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  function open() {
    openedFromHotkey = false
    setCenterHoverRevealSuppressed(false)
    root.controller.show()
    root.refresh()
  }

  function openFromHotkey() {
    openedFromHotkey = true
    root.controller.show()
    root.refresh()
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
    })
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.openFromHotkey()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  // Location support removed by request — the Hebrew day always rolls over
  // at local midnight now, which is what Model.hebrewInfoForNow does when
  // passed no coordinates.
  property var info: Model.hebrewInfoForNow(new Date(), null, null)

  // Bar pill and popup always show Hebrew script for the Hebrew date,
  // regardless of the system/UI language — matching the original ZmanBar
  // behavior. The Gregorian date below stays in the shell's own locale.
  readonly property string label: info.shortLabelHebrew
  readonly property string fullLabel: info.fullLabelHebrew
  readonly property string gregorianLabel: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")

  function refresh() {
    root.info = Model.hebrewInfoForNow(new Date(), null, null)
  }

  Timer {
    id: refreshTimer
    interval: 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: root.ipcTarget

    function open(): void { root.openFromHotkey() }
    function close(): void { root.close() }
    function show(): void { root.openFromHotkey() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  // The panel's width is measured from its two lines (the Hebrew headline
  // and the Gregorian date) instead of a flat guess, so the box hugs its
  // content instead of leaving a fixed, often-empty margin. The headline
  // uses Style.font.subtitle — the same size Omarchy's own clock panel uses
  // for its date line — rather than a large custom size, so it stays inside
  // Omarchy's normal type scale instead of needing special-cased handling.
  TextMetrics {
    id: titleMetrics
    font.family: root.bar ? root.bar.fontFamily : ""
    font.pixelSize: Style.font.subtitle
    font.bold: true
    text: root.fullLabel
  }

  TextMetrics {
    id: gregorianMetrics
    font.family: root.bar ? root.bar.fontFamily : ""
    font.pixelSize: Style.font.body
    text: root.gregorianLabel
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(
      Math.min(Style.space(320), Math.max(titleMetrics.width, gregorianMetrics.width) + Style.space(40))
    )
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(6)
        topPadding: Style.space(12)
        bottomPadding: Style.space(12)
        leftPadding: Style.space(20)
        rightPadding: Style.space(20)

        Text {
          textFormat: Text.PlainText
          text: root.fullLabel
          horizontalAlignment: Text.AlignRight
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        Text {
          textFormat: Text.PlainText
          text: root.gregorianLabel
          color: Qt.darker(root.bar.foreground, 1.4)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
