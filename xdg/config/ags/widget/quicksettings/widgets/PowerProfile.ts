import icons from "lib/icons"
import { ArrowToggleButton, Menu } from "../ToggleButton"


const pp = await Service.import("powerprofiles")
const profile = pp.bind("active_profile")
const profiles = pp.profiles.map(p => p.Profile)

const pertty = (str: string) => str
    .split("-")
    .map(str => `${str.at(0)?.toUpperCase()}${str.slice(1)}`)
    .join(" ")

export const ProfileToggle = () => ArrowToggleButton({
    name: "power-profile",
    icon: profile.as(p => icons.powerprofile[p]),
    label: profile.as(pertty),
    connection: [pp, () => pp.active_profile !== profiles[1]],
    activate: () => pp.active_profile = profiles[0],
    deactivate: () => pp.active_profile = profiles[1],
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
                            on_clicked: () => pp.active_profile = prof,
                            child: Widget.Box({
                                children: [
                                    Widget.Icon(icons.powerprofile[prof]),
                                    Widget.Label(pertty(prof)),
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
