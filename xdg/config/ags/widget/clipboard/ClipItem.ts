import cliphist from "service/cliphist"

/** @param {string} clipItem */
export default clipItem => {
    const title = Widget.Label({
        class_name: "title",
        label: clipItem,
        xalign: 0,
        vpack: "center",
        truncate: "end",
    })

    const textBox = Widget.Box({
        vertical: true,
        vpack: "center",
        children: [title],
    })

    return Widget.Button({
        class_name: "clip-item",
        attribute: { name: clipItem },
        child: Widget.Box({
            children: [textBox],
        }),
        on_clicked: () => {
            App.closeWindow("clipboard")
            cliphist.select(clipItem)
        },
    })
}
