pragma Singleton
import QtQuick
import Quickshell.Io

// Polls todo.sh every 5 seconds and exposes:
//   count  – integer todo count
//   items  – list of { num, priority, text } objects
Item {
    id: root
    visible: false

    readonly property int count: _count
    readonly property var items: _items

    property int _count: 0
    property var _items: []

    // Poll count
    Process {
        id: countProc
        command: ["sh", "-c", "todo.sh | grep -o 'TODO: [0-9]\\+' | sed 's/TODO: //'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const n = parseInt(line.trim())
                if (!isNaN(n)) root._count = n
            }
        }
    }

    // Poll full item list (todo.sh ls outputs lines like: "1 (A) Buy milk +project @context")
    Process {
        id: listProc
        command: ["sh", "-c", "todo.sh ls 2>/dev/null"]
        running: false
        property var _buf: []
        stdout: SplitParser {
            onRead: (line) => {
                // Match numbered lines: "NN (PRIORITY) text" or "NN text"
                const m = line.match(/^\s*(\d+)\s+(?:\(([A-Z])\)\s+)?(.+)$/)
                if (m) {
                    listProc._buf.push({
                        num:      parseInt(m[1]),
                        priority: m[2] || "",
                        text:     m[3].trim()
                    })
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                root._items = _buf.slice()
                _buf = []
            }
        }
    }

    // Mark a todo item done: todo.sh done N
    function markDone(num) {
        doneProcCommand.command = ["sh", "-c", "todo.sh done " + num]
        doneProcCommand.running = true
    }

    Process {
        id: doneProcCommand
        command: []
        running: false
        onRunningChanged: if (!running) root.refresh()
    }

    // Add new todo item
    function addTodo(text) {
        if (text.trim().length === 0) return
        addProcCommand.command = ["sh", "-c", "todo.sh add " + JSON.stringify(text.trim())]
        addProcCommand.running = true
    }

    Process {
        id: addProcCommand
        command: []
        running: false
        onRunningChanged: if (!running) root.refresh()
    }

    function refresh() {
        countProc.running = true
        listProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
