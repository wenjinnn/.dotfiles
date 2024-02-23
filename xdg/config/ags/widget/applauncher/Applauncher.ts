import PopupWindow, { Padding } from "widget/PopupWindow"
import { AppItem } from "./AppItem"
import icons from "lib/icons"
import options from "options"
import type Gtk from "gi://Gtk?version=3.0"
import { launchApp } from "lib/utils"

const apps = await Service.import("applications")
const { query } = apps
const { width, margin } = options.applauncher

const SeparatedAppItem = (app: Parameters<typeof AppItem>[0]) => Widget.Revealer(
    { attribute: { app }, reveal_child: true },
    Widget.Box<Gtk.Widget>(
        { vertical: true },
        Widget.Separator(),
        AppItem(app),
    ),
)

const Applauncher = () => {
    const applist = Variable(query(""))
    let first = applist.value[0]

    const list = Widget.Box({
        vertical: true,
        children: applist.bind().as(list => list.map(SeparatedAppItem)),
    })

    list.hook(apps, () => applist.value = query(""), "notify::frequents")

    const entry = Widget.Entry({
        hexpand: true,
        primary_icon_name: icons.ui.search,
        on_accept: () => {
            entry.text !== "" && launchApp(first)
            App.toggleWindow("applauncher")
        },
        on_change: ({ text }) => {
            first = query(text || "")[0]
            list.children.reduce((i, item) => {
                if (!text) {
                    item.reveal_child = true
                    return i
                }
                if (item.attribute.app.match(text)) {
                    item.reveal_child = true
                    return ++i
                }
                item.reveal_child = false
                return i
            }, 0)
        },
    })

    function focus() {
        entry.text = ""
        entry.set_position(-1)
        entry.select_region(0, -1)
        entry.grab_focus()
    }

    const layout = Widget.Box({
        css: width.bind().as(v => `min-width: ${v}pt;`),
        class_name: "applauncher",
        vertical: true,
        vpack: "start",
        setup: self => self.hook(App, (_, win, visible) => {
            if (win !== "applauncher")
                return

            entry.text = ""
            if (visible)
                focus()
        }),
        children: [
            entry,
            Widget.Scrollable({
                hscroll: "never",
                child: list,
            }),
        ],
    })

    return Widget.Box<Gtk.Widget>(
        { vertical: true, css: "padding: 1px" },
        Padding("applauncher", {
            css: margin.bind().as(v => `min-height: ${v}pt;`),
            vexpand: false,
        }),
        layout,
    )
}

export default () => PopupWindow({
    name: "applauncher",
    layout: "top",
    child: Applauncher(),
})
