import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string valueSearchEngine: cfg.search_engine ?? defaults.search_engine
    property bool valueShowSuggestions: cfg.show_suggestions ?? defaults.show_suggestions
    property int valueMaxResults: cfg.max_results ?? defaults.max_results

    spacing: Style.marginL

    Component.onCompleted: {
        Logger.d("WebSearch", "Settings UI loaded");
    }

    ColumnLayout {
        spacing: Style.marginM
        Layout.fillWidth: true

        NComboBox {
            Layout.fillWidth: true
            label: "Search Engine"
            description: "Default search engine to open when searching the web"
            model: ["Google", "DuckDuckGo", "Bing", "Brave", "Yandex"].map(function(n) {
                return { key: n, name: n };
            })
            
            currentKey: root.valueSearchEngine
            onSelected: key => root.valueSearchEngine = key
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                NText {
                    text: "Show Search Suggestions"
                    font.pointSize: Style.fontSizeL
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                    Layout.fillWidth: true
                }
                
                NText {
                    text: "Fetch real-time suggestions while typing"
                    font.pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            NToggle {
                checked: root.valueShowSuggestions
                onToggled: root.valueShowSuggestions = checked
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        RowLayout {
            Layout.fillWidth: true

            NText {
                text: "Maximum Results"
                font.pointSize: Style.fontSizeL
                font.weight: Font.Medium
                color: Color.mOnSurface
                Layout.fillWidth: true
            }

            NText {
                text: root.valueMaxResults.toString()
                font.pointSize: Style.fontSizeM
                font.weight: Font.Medium
                color: Color.mPrimary
            }
        }

        NText {
            text: "Limit the number of suggestions displayed"
            font.pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        NSlider {
            Layout.fillWidth: true
            from: 1
            to: 10
            stepSize: 1
            value: root.valueMaxResults
            onMoved: root.valueMaxResults = Math.round(value)
        }
    }

    function saveSettings() {
        if (!pluginApi) {
            Logger.e("WebSearch", "Cannot save settings: pluginApi is null");
            return;
        }

        pluginApi.pluginSettings.search_engine = root.valueSearchEngine;
        pluginApi.pluginSettings.show_suggestions = root.valueShowSuggestions;
        pluginApi.pluginSettings.max_results = root.valueMaxResults;
        pluginApi.saveSettings();

        Logger.d("WebSearch", "Settings saved successfully");
    }
}
