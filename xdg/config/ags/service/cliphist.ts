import { dependencies, bash } from "lib/utils"

const MAX_ITEM = 200

class Cliphist extends Service {
    static {
        Service.register(
            this,
            {
                "cliphist-changed": ["jsobject"],
            },
            {
                "cliphist-value": ["jsobject"],
            },
        )
    }

    #history = []

    #proc

    get history() {
        return this.#history
    }

    get proc() {
        return this.#proc
    }

    constructor() {
        super()
        if (dependencies("wl-paste", "cliphist")) {
            const initCommand = [
                "wl-paste",
                "--no-newline",
                "--watch",
                "bash",
                "-c",
                `cliphist -max-items ${MAX_ITEM} store && cliphist list | head -n 1`,
            ]
            // kill all subprocess that started by previous ags process since ags will not kill subprocess when quit
            Utils.exec(`pkill -f "${initCommand.join(" ")}"`)
            this.#proc = Utils.subprocess(initCommand,
                item => this.#onChange(item),
                err => logError(err),
            )
            Utils.subprocess([
                "cliphist",
                "list",
            ],
            item => this.#history.push(item),
            err => logError(err),
            )
        }
    }

    #onChange(item) {
        if (this.history[0] === item)
            return

        this.#history.unshift(item)
        if (this.#history.length > MAX_ITEM)
            this.#history.pop()

        this.emit("changed")
        this.notify("cliphist-value")
        this.emit("cliphist-changed", this.#history)
    }

    connect(event = "cliphist-changed", callback) {
        return super.connect(event, callback)
    }

    /** @param {string} selected
    */
    select(selected) {
        Utils.execAsync(["bash", "-c", `echo '${selected}' | cliphist decode | wl-copy`])
            .then(out => print(out))
            .catch(err => print(err))
    }

    readonly query = (term: string) => {
        term = term.trim()
        if (!term)
            return this.#history

        return this.#history.filter(item => item.match(term))
    }
}

const cliphist = new Cliphist
export default cliphist
