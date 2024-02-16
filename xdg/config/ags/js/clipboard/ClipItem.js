import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Cliphist from '../services/cliphist.js';

/** @param {string} clipItem */
export default clipItem => {
    const title = Widget.Label({
        class_name: 'title',
        label: clipItem,
        xalign: 0,
        vpack: 'center',
        truncate: 'end',
    });

    const textBox = Widget.Box({
        vertical: true,
        vpack: 'center',
        children: [title],
    });

    return Widget.Button({
        class_name: 'clip-item',
        attribute: {name:clipItem},
        child: Widget.Box({
            children: [textBox],
        }),
        on_clicked: () => {
            App.closeWindow('clipboard');
            Cliphist.select(clipItem);
        },
    });
};
