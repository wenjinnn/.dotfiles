import options from "options"
import { dependencies, bash, sh, randomNum } from "lib/utils"
import GLib from "gi://GLib"

export type Resolution = 1920 | 1366 | 3840 | "UHD"
export type Market =
    | "random"
    | "en-US"
    | "ja-JP"
    | "en-AU"
    | "en-GB"
    | "de-DE"
    | "en-NZ"
    | "en-CA"

const BING_URL = "https://www.bing.com"
const WP = `${Utils.HOME}/.config/background`
const Cache = `${Utils.HOME}/Pictures/BingWallpaper`

class Wallpaper extends Service {
    static {
        Service.register(this, {}, {
            "wallpaper": ["string"],
        })
    }

    #blockMonitor = false

    async #wallpaper(path = WP) {
        if (!dependencies("hyprpaper"))
            return

        const old = await sh(`readlink ${WP}`)
        await sh(`hyprctl hyprpaper preload '${path}'`)
        await sh(`hyprctl hyprpaper wallpaper ',${path}'`)
        await sh(`hyprctl hyprpaper unload '${old}'`)
        this.changed("wallpaper")
    }

    async #setWallpaper(path: string) {
        this.#blockMonitor = true

        this.#wallpaper(path)
        await sh(`ln -sf ${path} ${WP}`)

        this.#blockMonitor = false
    }

    async #fetchBing(idx = 0) {
        const resolutionValue = options.wallpaper.resolution.value
        const res = await Utils.fetch(`${BING_URL}/HPImageArchive.aspx`, {
            params: {
                resolution: resolutionValue,
                format: "js",
                image_format: "jpg",
                mbl: 1,
                n: 10,
                mkt: options.wallpaper.market.value,
            },
        }).then(res => res.text())

        if (!res.startsWith("{"))
            return console.warn("bing api", res)

        const { images } = JSON.parse(res)
        if (images.length === 0)
            return console.warn("bing api images", res)

        const latest = images[idx]
        const url = `${BING_URL}${latest.urlbase}_${resolutionValue}.jpg`
        const imageName = latest.urlbase.replace("/th?id=OHR.", "")
        const file = `${Cache}/${latest.startdate}-${imageName}_${resolutionValue}.jpg`

        if (dependencies("curl") && !GLib.file_test(file, GLib.FileTest.EXISTS)) {
            Utils.ensureDirectory(Cache)
            await sh(`curl "${url}" --output ${file}`)
            this.#setWallpaper(file)
        } else {
            const randomPic = await bash(`find ${Cache}/*.jpg -maxdepth 1 -type f | shuf -n 1`)
            this.#setWallpaper(randomPic)
        }
    }

    readonly random = () => { this.#fetchBing(randomNum(0, 7)) }
    readonly set = (path: string) => { this.#setWallpaper(path) }
    get wallpaper() { return WP }

    constructor() {
        super()

        if (!dependencies("hyprpaper"))
            return this

        // gtk portal
        Utils.monitorFile(WP, () => {
            if (!this.#blockMonitor)
                this.#wallpaper()
        })

        Utils.interval(3_600_000, () => this.#fetchBing(0).catch(err => logError(err)))
    }
}

export default new Wallpaper
