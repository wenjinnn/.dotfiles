import options from "options"
const { messageAsync } = await Service.import("hyprland")

const {
    hyprland,
    theme: {
        spacing,
        radius,
        border: { width },
        blur,
        shadows,
        dark: {
            primary: { bg: darkActive },
        },
        light: {
            primary: { bg: lightActive },
        },
        scheme,
    },
} = options

const deps = [
    "hyprland",
    spacing.id,
    radius.id,
    blur.id,
    width.id,
    shadows.id,
    darkActive.id,
    lightActive.id,
    scheme.id,
]

function primary() {
    return scheme.value === "dark"
        ? darkActive.value
        : lightActive.value
}

function rgba(color: string) {
    return `rgba(${color}ff)`.replace("#", "")
}

function sendBatch(batch: string[]) {
    const cmd = batch
        .filter(x => !!x)
        .map(x => `keyword ${x}`)
        .join("; ")

    return messageAsync(`[[BATCH]]/${cmd}`)
}

async function setupHyprland() {
    const wm_gaps = Math.floor(hyprland.gaps.value * spacing.value)

    sendBatch([
        `general:border_size ${width}`,
        `general:gaps_out ${wm_gaps}`,
        `general:gaps_in ${Math.floor(wm_gaps / 2)}`,
        `general:col.active_border ${rgba(primary())}`,
        `general:col.inactive_border ${rgba(hyprland.inactiveBorder.value)}`,
        `decoration:rounding ${radius}`,
        `decoration:shadow:enabled ${shadows.value}`,
        `workspace w[tv1], gapsout:${hyprland.gapsWhenOnly.value ? 0 : wm_gaps}, gapsin:${Math.floor(wm_gaps / 2)}`,
        `workspace w[f1], gapsout:${hyprland.gapsWhenOnly.value ? 0 : wm_gaps}, gapsin:${Math.floor(wm_gaps / 2)}`,
        `windowrulev2 bordersize ${hyprland.gapsWhenOnly.value ? 0 : width}, floating:${hyprland.gapsWhenOnly.value ? 0 : 1}, onworkspace:w[tv1]`,
        `windowrulev2 rounding ${hyprland.gapsWhenOnly.value ? radius : 0}, floating:${hyprland.gapsWhenOnly.value ? 0 : 1}, onworkspace:w[tv1]`,
        `windowrulev2 bordersize ${hyprland.gapsWhenOnly.value ? 0 : width}, floating:${hyprland.gapsWhenOnly.value ? 0 : 1}, onworkspace:w[f1]`,
        `windowrulev2 rounding ${hyprland.gapsWhenOnly.value ? radius : 0}, floating:${hyprland.gapsWhenOnly.value ? 0 : 1}, onworkspace:w[f1]`,
    ])

    await sendBatch(App.windows.map(({ name }) => `layerrule unset, ${name}`))

    if (blur.value > 0) {
        sendBatch(App.windows.flatMap(({ name }) => [
            `layerrule unset, ${name}`,
            `layerrule blur, ${name}`,
            `layerrule ignorealpha ${/* based on shadow color */.29}, ${name}`,
        ]))
    }
}

export default function init() {
    options.handler(deps, setupHyprland)
    setupHyprland()
}
