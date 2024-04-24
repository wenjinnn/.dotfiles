import icons from "lib/icons"
import options from "options"
import { dependencies } from "lib/utils"

import cliphist from "service/cliphist"


const iconVisible = Variable(false)

const { height } = options.launcher
const { max } = options.launcher.clip
function query(filter: string) {
    if (!dependencies("cliphist"))
        return [] as string[]

    const list = cliphist.query(filter)
    return list.slice(0, max.value)
}

function run(args: string) {
    cliphist.select(args)
}

function ClipItem(item: string) {
    return Widget.Box(
        {
            attribute: { item },
            vertical: true,
        },
        Widget.Separator(),
        Widget.Button({
            child: Widget.Label({
                label: item,
                wrap: true,
                xalign: 0,
                hpack: "start",
                justification: "left",
            }),
            class_name: "clip-item",
            on_clicked: () => {
                cliphist.select(item)
                App.closeWindow("launcher")
            },
        }),
    )
}

export function Icon() {
    const icon = Widget.Icon({
        icon: icons.clip.folder,
        class_name: "spinner",
    })

    return Widget.Revealer({
        transition: "slide_left",
        child: icon,
        reveal_child: iconVisible.bind(),
    })
}

export function ClipRun() {
    const list = Widget.Box<ReturnType<typeof ClipItem>>({
        vertical: true,
    })

    const revealer = Widget.Revealer({
        child: Widget.Scrollable({
            css: height.bind().as(v => `min-height: ${v}pt;`),
            child: list,
        }),
    })

    async function filter(term: string) {
        if (term === undefined) {
            revealer.reveal_child = false
            return
        }

        term = term.trim()

        iconVisible.value = Boolean(term)

        const found = query(term)
        list.children = found.map(ClipItem)
        revealer.reveal_child = true
    }

    return Object.assign(revealer, { filter, run })
}
