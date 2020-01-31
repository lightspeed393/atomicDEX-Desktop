import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    onClosed: if(stack_layout.currentIndex === 2) closeAndReset()
    width: 365

    // Local
    property string tx_hex
    property string tx_hash

    function prepareSendCoin(address, amount) {
        let result = API.get().prepare_send_coin(address, amount, parseFloat(API.get().current_coin_info.balance) === parseFloat(amount))

        if(result.has_error) {
            text_error.text = result.error_message
        }
        else {
            text_error.text = ""

            // Change page
            tx_hex = result.tx_hex
            stack_layout.currentIndex = 1
        }
    }

    function sendCoin() {
        tx_hash = API.get().send(tx_hex)
        stack_layout.currentIndex = 2
    }

    function closeAndReset() {
        tx_hex = ""
        tx_hash = ""
        input_address.field.text = ""
        input_amount.field.text = ""
        text_error.text = ""

        root.close()
        stack_layout.currentIndex = 0
    }

    // Inside modal
    StackLayout {
        id: stack_layout
        width: parent.width

        // Prepare Page
        ColumnLayout {
            // Title
            DefaultText {
                text: qsTr("Prepare to Send")
                font.pointSize: Style.textSize2
            }

            // Send address
            AddressField {
                id: input_address
                title: qsTr("Recipient's address")
                field.placeholderText: qsTr("Enter address of the recipient")
            }

            // Amount input
            AmountField {
                id: input_amount
                title: qsTr("Amount to send")
                field.placeholderText: qsTr("Enter the amount to send")
            }

            DefaultText {
                id: text_error
                color: Style.colorRed
                visible: text !== ''
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Close")
                    Layout.fillWidth: true
                    onClicked: root.close()
                }
                Button {
                    text: qsTr("Prepare")
                    Layout.fillWidth: true

                    enabled: input_address.field.text != "" &&
                             input_amount.field.text != "" &&
                             input_address.field.acceptableInput &&
                             input_amount.field.acceptableInput

                    onClicked: prepareSendCoin(input_address.field.text, input_amount.field.text)
                }
            }
        }

        // Send Page
        ColumnLayout {
            // Title
            DefaultText {
                text: qsTr("Send")
                font.pointSize: Style.textSize2
            }

            // Address title
            DefaultText {
                text: qsTr("Recipient's address:")
            }
            // Address value
            DefaultText {
                text: input_address.field.text
            }

            // Amount title
            DefaultText {
                text: qsTr("Amount:")
            }
            // Amount value
            DefaultText {
                text: input_amount.field.text + " " + API.get().current_coin_info.ticker
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Back")
                    Layout.fillWidth: true
                    onClicked: stack_layout.currentIndex = 0
                }
                Button {
                    text: qsTr("Send")
                    Layout.fillWidth: true
                    onClicked: sendCoin()
                }
            }
        }

        // Result Page
        ColumnLayout {
            // Title
            DefaultText {
                text: qsTr("Transaction Complete!")
                font.pointSize: Style.textSize2
            }

            // Address title
            DefaultText {
                text: qsTr("Recipient's address:")
            }
            // Address value
            DefaultText {
                text: input_address.field.text
            }

            // Amount title
            DefaultText {
                text: qsTr("Amount:")
            }
            // Amount value
            DefaultText {
                text: input_amount.field.text + " " + API.get().current_coin_info.ticker
            }

            // Transaction Hash title
            DefaultText {
                text: qsTr("Transaction Hash:")
            }
            // Transaction Hash value
            DefaultText {
                text: tx_hash
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Close")
                    Layout.fillWidth: true
                    onClicked: closeAndReset()
                }
                Button {
                    text: qsTr("View at Explorer")
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally(API.get().current_coin_info.explorer_url + "tx/" + tx_hash)
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/