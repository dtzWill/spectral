import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import Spectral.Component 2.0
import Spectral.Component.Emoji 2.0
import Spectral.Dialog 2.0
import Spectral.Effect 2.0
import Spectral.Setting 0.1

import Spectral 0.1

Control {
    property alias isReply: replyItem.visible
    property bool isReaction: false
    property var replyModel
    readonly property var replyUser: replyModel ? replyModel.author : null
    readonly property string replyEventID: replyModel ? replyModel.eventId : ""
    readonly property string replyContent: replyModel ? replyModel.display : ""

    property alias isAutoCompleting: autoCompleteListView.visible
    property var autoCompleteModel
    property int autoCompleteBeginPosition
    property int autoCompleteEndPosition

    property bool hasAttachment: false
    property url attachmentPath

    id: root

    padding: 0

    background: Rectangle {
        color: MSettings.darkTheme ? "#303030" : "#fafafa"
        radius: 24

        layer.enabled: true
        layer.effect: ElevationEffect {
            elevation: 1
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8

            id: replyItem

            visible: false

            spacing: 8

            Control {
                Layout.alignment: Qt.AlignTop

                padding: 4

                background: Rectangle {
                    radius: height / 2
                    color: replyUser ? Qt.darker(replyUser.color, 1.1) : MPalette.accent
                }

                contentItem: RowLayout {
                    Avatar {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        source: replyUser ? replyUser.avatarMediaId : ""
                        hint: replyUser ? replyUser.displayName : "No name"
                    }

                    Label {
                        Layout.alignment: Qt.AlignVCenter

                        text: replyUser ? replyUser.displayName : "No name"
                        color: "white"
                        font.weight: Font.Medium
                        rightPadding: 8
                    }
                }
            }

            TextEdit {
                Layout.fillWidth: true

                color: MPalette.foreground
                text: "<style>a{color: " + color + ";} .user-pill{}</style>" + replyContent

                font.family: window.font.family
                font.pixelSize: 14
                selectByMouse: true
                readOnly: true
                wrapMode: Label.Wrap
                selectedTextColor: "white"
                selectionColor: MPalette.accent
                textFormat: Text.RichText
            }
        }

        EmojiPicker {
            Layout.fillWidth: true

            id: emojiPicker

            visible: false

            textArea: inputField
            emojiModel: EmojiModel { id: emojiModel }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.margins: 8

            id: autoCompleteListView

            visible: false

            model: autoCompleteModel

            clip: true
            spacing: 4
            orientation: ListView.Horizontal
            highlightFollowsCurrentItem: true
            keyNavigationWraps: true

            delegate: Control {
                property string autoCompleteText: modelData.displayName || modelData.unicode
                property bool isEmoji: modelData.unicode != null
                readonly property bool highlighted: autoCompleteListView.currentIndex === index

                height: 36
                padding: 6

                background: Rectangle {
                    visible: !isEmoji
                    color: highlighted ? border.color : "transparent"
                    border.color: isEmoji ? Material.accent : modelData.color
                    border.width: 2
                    radius: height / 2
                }

                contentItem: RowLayout {
                    spacing: 6

                    Text {
                        width: 24
                        height: 24
                        visible: isEmoji
                        text: autoCompleteText
                        font.pixelSize: 24
                        font.family: "Emoji"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Avatar {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        visible: !isEmoji
                        source: modelData.avatarMediaId || null
                        color: modelData.color ? Qt.darker(modelData.color, 1.1) : MPalette.accent
                    }

                    Label {
                        Layout.fillHeight: true

                        visible: !isEmoji
                        text: autoCompleteText
                        color: highlighted ? "white" : MPalette.foreground
                        verticalAlignment: Text.AlignVCenter
                        rightPadding: 8
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        autoCompleteListView.currentIndex = index
                        inputField.replaceAutoComplete(autoCompleteText)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            visible: emojiPicker.visible || replyItem.visible || autoCompleteListView.visible

            color: MSettings.darkTheme ? "#424242" : "#e7ebeb"
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: 0

            ToolButton {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignBottom

                id: uploadButton
                visible: !isReply && !hasAttachment

                contentItem: MaterialIcon {
                    icon: "\ue226"
                }

                onClicked: {
                    if (imageClipboard.hasImage) {
                        attachDialog.open()
                    } else {
                        var fileDialog = openFileDialog.createObject(ApplicationWindow.overlay)

                        fileDialog.chosen.connect(function(path) {
                            if (!path) return

                            roomPanelInput.attach(path)
                        })

                        fileDialog.open()
                    }
                }

                BusyIndicator {
                    anchors.fill: parent

                    running: currentRoom && currentRoom.hasFileUploading
                }
            }

            ToolButton {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignBottom

                id: cancelReplyButton

                visible: isReply

                contentItem: MaterialIcon {
                    icon: "\ue5cd"
                }

                onClicked: clearReply()
            }

            Control {
                Layout.margins: 6
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignVCenter

                visible: hasAttachment

                rightPadding: 8

                background: Rectangle {
                    color: MPalette.accent
                    radius: height / 2
                    antialiasing: true
                }

                contentItem: RowLayout {
                    spacing: 0

                    ToolButton {
                        Layout.preferredWidth: height
                        Layout.fillHeight: true

                        id: cancelAttachmentButton

                        contentItem: MaterialIcon {
                            icon: "\ue5cd"
                            color: "white"
                            font.pixelSize: 18
                        }

                        onClicked: {
                            hasAttachment = false
                            attachmentPath = ""
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignVCenter

                        text: attachmentPath != "" ? attachmentPath.toString().substring(attachmentPath.toString().lastIndexOf('/') + 1, attachmentPath.length) : ""
                        color: "white"
                    }
                }
            }

            TextArea {
                property real progress: 0

                Layout.fillWidth: true
                Layout.minimumHeight: 48

                id: inputField

                wrapMode: Text.Wrap
                placeholderText: "Send a Message"
                topPadding: 0
                bottomPadding: 0
                selectByMouse: true
                verticalAlignment: TextEdit.AlignVCenter

                text: currentRoom != null ? currentRoom.cachedInput : ""

                background: Item {}

                Rectangle {
                    width: currentRoom && currentRoom.hasFileUploading ? parent.width * currentRoom.fileUploadingProgress / 100 : 0
                    height: parent.height

                    opacity: 0.2
                    color: Material.accent
                }

                Timer {
                    id: timeoutTimer

                    repeat: false
                    interval: 2000
                    onTriggered: {
                        repeatTimer.stop()
                        currentRoom.sendTypingNotification(false)
                    }
                }

                Timer {
                    id: repeatTimer

                    repeat: true
                    interval: 5000
                    triggeredOnStart: true
                    onTriggered: currentRoom.sendTypingNotification(true)
                }

                Keys.onReturnPressed: {
                    if (event.modifiers & Qt.ShiftModifier) {
                        insert(cursorPosition, "\n")
                    } else {
                        postMessage(text)
                        text = ""
                        clearReply()
                        closeAll()
                    }
                }

                Keys.onEscapePressed: closeAll()

                Keys.onBacktabPressed: if (isAutoCompleting) autoCompleteListView.decrementCurrentIndex()

                Keys.onTabPressed: {
                    if (isAutoCompleting) {
                        autoCompleteListView.incrementCurrentIndex()
                    } else {
                        autoCompleteBeginPosition = text.substring(0, cursorPosition).lastIndexOf(" ") + 1
                        var autoCompletePrefix = text.substring(0, cursorPosition).split(" ").pop()
                        if (!autoCompletePrefix) return
                        if (autoCompletePrefix.startsWith(":")) {
                            autoCompleteBeginPosition = text.substring(0, cursorPosition).lastIndexOf(" ") + 1
                            autoCompleteModel = emojiModel.filterModel(autoCompletePrefix)
                            if (autoCompleteModel.length === 0) return
                            isAutoCompleting = true
                            autoCompleteEndPosition = cursorPosition
                        } else {
                            autoCompleteModel = currentRoom.getUsers(autoCompletePrefix)
                            if (autoCompleteModel.length === 0) return
                            isAutoCompleting = true
                            autoCompleteEndPosition = cursorPosition
                        }
                    }
                    replaceAutoComplete(autoCompleteListView.currentItem.autoCompleteText)
                }

                onTextChanged: {
                    timeoutTimer.restart()
                    repeatTimer.start()
                    currentRoom.cachedInput = text

                    if (cursorPosition !== autoCompleteBeginPosition && cursorPosition !== autoCompleteEndPosition) {
                        isAutoCompleting = false
                        autoCompleteListView.currentIndex = 0
                    }
                }

                function replaceAutoComplete(word) {
                    remove(autoCompleteBeginPosition, autoCompleteEndPosition)
                    autoCompleteEndPosition = autoCompleteBeginPosition + word.length
                    insert(cursorPosition, word)
                }

                function postMessage(text) {
                    if(!currentRoom) { return }

                    if (hasAttachment) {
                        currentRoom.uploadFile(attachmentPath, text)
                        clearAttachment()
                        return
                    }

                    if (text.trim().length === 0) { return }

                    var PREFIX_ME = '/me '
                    var PREFIX_NOTICE = '/notice '
                    var PREFIX_RAINBOW = '/rainbow '

                    var messageEventType = RoomMessageEvent.Text

                    if (text.indexOf(PREFIX_RAINBOW) === 0) {
                        text = text.substr(PREFIX_RAINBOW.length)

                        var parsedText = ""
                        var rainbowColor = ["#ff2b00", "#ff5500", "#ff8000", "#ffaa00", "#ffd500", "#ffff00", "#d4ff00", "#aaff00", "#80ff00", "#55ff00", "#2bff00", "#00ff00", "#00ff2b", "#00ff55", "#00ff80", "#00ffaa", "#00ffd5", "#00ffff", "#00d4ff", "#00aaff", "#007fff", "#0055ff", "#002bff", "#0000ff", "#2a00ff", "#5500ff", "#7f00ff", "#aa00ff", "#d400ff", "#ff00ff", "#ff00d4", "#ff00aa", "#ff0080", "#ff0055", "#ff002b", "#ff0000"]
                        for (var i = 0; i < text.length; i++) {
                            parsedText = parsedText + "<font color='" + rainbowColor[i % rainbowColor.length] + "'>" + text.charAt(i) + "</font>"
                        }
                        currentRoom.postHtmlMessage(text, parsedText, RoomMessageEvent.Text, replyEventID)
                        return
                    }

                    if (text.indexOf(PREFIX_ME) === 0) {
                        text = text.substr(PREFIX_ME.length)
                        messageEventType = RoomMessageEvent.Emote
                    } else if (text.indexOf(PREFIX_NOTICE) === 0) {
                        text = text.substr(PREFIX_NOTICE.length)
                        messageEventType = RoomMessageEvent.Notice
                    }

                    if (MSettings.markdownFormatting) {
                        currentRoom.postArbitaryMessage(text, messageEventType, replyEventID)
                    } else {
                        currentRoom.postPlainMessage(text, messageEventType, replyEventID)
                    }
                }
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter

                icon: "\ue165"
                font.pixelSize: 16
                color: MPalette.foreground
                opacity: MSettings.markdownFormatting ? 1 : 0.3

                MouseArea {
                    anchors.fill: parent

                    onClicked: MSettings.markdownFormatting = !MSettings.markdownFormatting
                }
            }

            ToolButton {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignBottom

                id: emojiButton

                contentItem: MaterialIcon {
                    icon: "\ue24e"
                }

                onClicked: emojiPicker.visible = !emojiPicker.visible
            }
        }
    }

    function insert(str) {
        inputField.insert(inputField.cursorPosition, str)
    }

    function clear() {
        inputField.clear()
    }

    function clearReply() {
        isReply = false
        replyModel = null
    }

    function focus() {
        inputField.forceActiveFocus()
    }

    function closeAll() {
        replyItem.visible = false
        autoCompleteListView.visible = false
        emojiPicker.visible = false
    }

    function attach(localPath) {
        hasAttachment = true
        attachmentPath = localPath
    }

    function clearAttachment() {
        hasAttachment = false
        attachmentPath = ""
    }
}
