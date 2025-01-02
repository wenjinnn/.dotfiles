import icons from "lib/icons"
import { bash } from "lib/utils"
import { ArrowToggleButton, Menu } from "../ToggleButton"
import { tlpmode } from "lib/variables"


const profile = tlpmode.bind()
const profiles = ["AC", "battery"]

export const ProfileToggle = () => ArrowToggleButton({
    name: "power-profile",
    icon: profile.as(p => icons.powerprofile[p]),
    label: profile,
    connection: [tlpmode, () => tlpmode.value === profiles[0]],
    activate: () => bash("pkexec tlp ac"),
    deactivate: () => bash("pkexec tlp bat"),
    activateOnArrow: false,
})

export const ProfileSelector = () => Menu({
    name: "power-profile",
    icon: profile.as(p => icons.powerprofile[p]),
    title: "Profile Selector",
    content: [
        Widget.Box({
            vertical: true,
            hexpand: true,
            children: [
                Widget.Box({
                    vertical: true,
                    children: profiles.map(prof =>
                        Widget.Button({
                            on_clicked: () => bash(`pkexec tlp ${prof}`),
                            child: Widget.Box({
                                children: [
                                    Widget.Icon(icons.powerprofile[prof]),
                                    Widget.Label(prof),
                                ],
                            }),
                        }),
                    ),
                }),
            ],
        }),
        Widget.Separator(),
        Widget.Button({
            on_clicked: () => Utils.execAsync("env XDG_CURRENT_DESKTOP=gnome gnome-control-center power"),
            child: Widget.Box({
                children: [
                    Widget.Icon(icons.ui.settings),
                    Widget.Label("Power Mode"),
                ],
            }),
        }),
    ],
})
