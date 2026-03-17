import QtQuick
import qs.Commons

Item {
    id: root
    
    property var pluginApi: null
    property var launcher: null
    property string name: "Web Search"

    property bool handleSearch: true 
    property string supportedLayouts: "list"

    property var suggestions: []
    property string lastQuery: ""

    readonly property var defaultEngine: {
        "search": "https://www.google.com/search?q=",
        "suggest": "https://suggestqueries.google.com/complete/search?client=chrome&q="
    }

    function getResults(searchText) {
        let engine = defaultEngine;
        let engineName = "Google";
        let showSuggestions = true;
        let maxResults = 5;
        let results = [];
        let rawText = searchText.trim();
        let isCommand = rawText.startsWith(">web");
        let query = rawText;
        
        try {
            if (pluginApi && pluginApi.pluginSettings) {
                engineName = pluginApi.pluginSettings.search_engine ?? (pluginApi.manifest?.metadata?.defaultSettings?.search_engine || "Google");
                showSuggestions = pluginApi.pluginSettings.show_suggestions ?? (pluginApi.manifest?.metadata?.defaultSettings?.show_suggestions ?? true);
                maxResults = pluginApi.pluginSettings.max_results ?? (pluginApi.manifest?.metadata?.defaultSettings?.max_results ?? 5);

                if (engineName === "DuckDuckGo") {
                    engine = { "search": "https://duckduckgo.com/?q=", "suggest": "https://duckduckgo.com/ac/?q=" };
                } else if (engineName === "Bing") {
                    engine = { "search": "https://www.bing.com/search?q=", "suggest": "https://www.bing.com/osjson.aspx?query=" };
                } else if (engineName === "Brave") {
                    engine = { "search": "https://search.brave.com/search?q=", "suggest": "https://search.brave.com/api/suggest?q=" };
                } else if (engineName === "Yandex") {
                    engine = { "search": "https://yandex.com/search/?text=", "suggest": "https://suggest.yandex.com/suggest-ya.cgi?v=4&part=" };
                }
            }
        } catch (e) { }

        if (isCommand) {
            query = rawText.slice(5).trim();
        }

        if (query === "" && !isCommand) return [];
        if (rawText.startsWith(">") && !isCommand) return [];
        
        if (isCommand && query === "") {
            return [{
                "name": "Type Something...",
                "description": "Search internet from " + engineName,
                "icon": "search",
                "isTablerIcon": true
            }];
        }

        results.push({
            "name": "Search \"" + query + "\"",
            "description": "Open in " + engineName,
            "icon": "world",
            "isTablerIcon": true,
            "_score": isCommand ? 999 : -5,
            "onActivate": function() {
                Qt.openUrlExternally(engine.search + encodeURIComponent(query));
                if (launcher) launcher.close();
            }
        });

        if (showSuggestions && query !== lastQuery && query.length > 1) {
            lastQuery = query;
            suggestions = [];
            if (launcher) launcher.updateResults();
            fetchSuggestions(query, engine.suggest, maxResults);
        }

        if (suggestions.length > 0) {
            for (let i = 0; i < suggestions.length; i++) {
                let s = suggestions[i];
                results.push({
                    "name": s,
                    "description": "Suggestion " + engineName,
                    "icon": "search",
                    "isTablerIcon": true,
                    "_score": isCommand ? (900 - i) : (-10 - i),
                    "onActivate": function() {
                        Qt.openUrlExternally(engine.search + encodeURIComponent(s));
                        if (launcher) launcher.close();
                    }
                });
            }
        }

        return results;
    }

    function fetchSuggestions(query, url, maxResults) {
        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    if (query !== lastQuery) return;
                    try {
                        let data = JSON.parse(xhr.responseText);
                        
                        if (Array.isArray(data) && data.length > 0) {
                            // Format DDG: [{"phrase": "s1"}, ...]
                            if (typeof data[0] === 'object' && data[0].phrase !== undefined) {
                                suggestions = data.map(item => item.phrase).slice(0, maxResults);
                                if (launcher) launcher.updateResults();
                            }
                            // Format Others: ["keyword", ["s1", "s2"]]
                            else if (data.length > 1 && Array.isArray(data[1])) {
                                suggestions = data[1].slice(0, maxResults);
                                if (launcher) launcher.updateResults();
                            }
                        }
                    } catch (e) {
                        console.log("WebSearch: JSON Parse error");
                    }
                }
            }
        }
        xhr.open("GET", url + encodeURIComponent(query));
        xhr.send();
    }

    function handleCommand(searchText) {
        return searchText.startsWith(">web");
    }

    function commands() {
        return [{
            "name": ">web",
            "description": "Search something from the internet",
            "icon": "world",
            "isTablerIcon": true,
            "onActivate": function() {
                launcher.setSearchText(">web "); 
            }
        }];
    }
}