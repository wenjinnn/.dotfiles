import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import icons from '../../icons.js';
import PowerProfiles from 'resource:///com/github/Aylur/ags/service/powerprofiles.js';
import { ArrowToggleButton, Menu } from '../ToggleButton.js';

export const ProfileToggle = () => ArrowToggleButton({
    name: 'power-profile',
    icon: Widget.Icon({
        icon: PowerProfiles.bind('active-profile').transform(p => icons.power.profile[p]),
    }),
    label: Widget.Label({
        label: PowerProfiles.bind('active-profile').transform(p => p.substring(0, 1).toUpperCase() + p.substring(1))
    }),
    connection: [PowerProfiles, () => PowerProfiles.active_profile !== 'power-saver'],
    activate: () => PowerProfiles.active_profile = 'performance',
    deactivate: () => PowerProfiles.active_profile = 'power-saver',
    activateOnArrow: false,
});

export const ProfileSelector = () => Menu({
    name: 'power-profile',
    icon: Widget.Icon({
        icon: PowerProfiles.bind('active-profile').transform(p => icons.power.profile[p]),
    }),
    title: Widget.Label('Profile Selector'),
    content: [
        Widget.Box({
            vertical: true,
            hexpand: true,
            children: [
                Widget.Box({
                    vertical: true,
                    children: PowerProfiles.profiles.map(prof => {
                        return Widget.Button({
                            on_clicked: () => PowerProfiles.active_profile = prof.Profile,
                            child: Widget.Box({
                                children: [
                                    Widget.Icon(icons.power.profile[prof.Profile]),
                                    Widget.Label({
                                            label: prof.Profile.substring(0, 1).toUpperCase() + prof.Profile.substring(1)
                                        }
                                    ),
                                ],
                            }),
                        })
                    }
                    ),
                }),
            ],
        }),
        Widget.Separator(),
        Widget.Button({
            on_clicked: () => Utils.execAsync('env XDG_CURRENT_DESKTOP=gnome gnome-control-center power'),
            child: Widget.Box({
                children: [
                    Widget.Icon(icons.ui.settings),
                    Widget.Label('Power Mode'),
                ],
            }),
        }),
    ],
});
