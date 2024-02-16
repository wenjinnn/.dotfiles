import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import GLib from 'gi://GLib';
import { dependencies } from '../utils.js';

class Cliphist extends Service {
    static {
        Service.register(
            this,
            {
                'cliphist-changed': ['jsobject']
            },
            {
                'cliphist-value': ['jsobject']
            }
        )
    }

    #history = [];

    #proc;

    get history() {
        return this.#history;
    };

    get proc() {
        return this.#proc;
    };

    constructor() {
        super();
        if (dependencies(['wl-paste', 'cliphist'])) {
            this.#proc = Utils.subprocess(['bash', '-c', 'wl-paste --watch bash -c \'cliphist store && echo "cliphist changed"\''],
                (out) => { this.#onChange() },
                (err) => logError(err)
            );
            
        }
        this.#onChange();
    }

    #onChange() {
        this.#history = Utils.exec('cliphist list').split('\n');
        
        this.emit('changed'); // emits "changed"
        this.notify('cliphist-value'); // emits "notify::screen-value"

        this.emit('cliphist-changed', this.#history);
    }

    connect(event = 'cliphist-changed', callback) {
        return super.connect(event, callback);
    }

    /** @param {string} selected 
    */
    select(selected) {
        Utils.execAsync(['bash', '-c', `echo '${selected}' | cliphist decode | wl-copy`])
        .then(out => print(out))
        .catch(err => print(err));

    }

    query(str) {
        return this.#history.filter(item => item.match(str));
    }

}

export default new Cliphist;
