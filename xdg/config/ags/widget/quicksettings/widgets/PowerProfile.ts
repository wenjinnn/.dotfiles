import icons from "lib/icons"
import { ArrowToggleButton, Menu } from "../ToggleButton"

const powerprofiles = await Service.import("powerprofiles")

export const ProfileToggle = () => ArrowToggleButton({
    name: "power-profile",
    icon: powerprofiles.bind("active-profile").as(p => icons.power.profile[p]),
    label: powerprofiles.bind("active-profile").as(p => p.substring(0, 1).toUpperCase() + p.substring(1)),
    connection: [powerprofiles, () => powerprofiles.active_profile !== "power-saver"],
    activate: () => powerprofiles.active_profile = "performance",
    deactivate: () => powerprofiles.active_profile = "power-saver",
    activateOnArrow: false,
})

export const ProfileSelector = () => Menu({
    name: "power-profile",
    icon: powerprofiles.bind("active-profile").as(p => icons.power.profile[p]),
    title: "Profile Selector",
    content: [
        Widget.Box({
            vertical: true,
            hexpand: true,
            children: [
                Widget.Box({
                    vertical: true,
                    children: powerprofiles.profiles.map(prof =>
                        Widget.Button({
                            on_clicked: () => powerprofiles.active_profile = prof.Profile,
                            child: Widget.Box({
                                children: [
                                    Widget.Icon(icons.power.profile[prof.Profile]),
                                    Widget.Label({
                                        label: prof.Profile.substring(0, 1).toUpperCase() + prof.Profile.substring(1),
                                    },
                                    ),
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
