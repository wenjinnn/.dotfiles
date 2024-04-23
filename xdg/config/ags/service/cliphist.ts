import { dependencies } from "lib/utils"

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
            this.#proc = Utils.subprocess([
                "bash",
                "-c",
                'wl-paste --no-newline --watch bash -c \'cliphist store && echo "cliphist changed"\'',
            ],
            _ => { this.#onChange() },
            err => logError(err),
            )
        }
        this.#onChange()
    }

    #onChange() {
        this.#history = Utils.exec("cliphist list").split(/\n/)
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
