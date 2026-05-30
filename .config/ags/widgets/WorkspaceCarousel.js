import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"

export default function WorkspaceCarousel() {
    const hypr = Hyprland.get_default()
    
    return <window
        name="workspace-carousel"
        application={App}
        visible={false}
        keymode={Astal.Keymode.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        exclusivity={Astal.Exclusivity.IGNORE}
        layer={Astal.Layer.OVERLAY}
        onKeyPressEvent={(self, event) => {
            const key = event.get_keyval()[1]
            if (key === Gdk.KEY_Escape) {
                self.hide()
            }
        }}>
        <box cssClasses={["window-content", "workspace-carousel"]} vertical={true} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label label="Workspaces" cssClasses={["workspace-name"]} margin-bottom={32} />
            <scrollable widthRequest={800} heightRequest={300} vscrollbarPolicy={Gtk.PolicyType.NEVER} hscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}>
                <box cssClasses={["carousel-container"]} spacing={24} halign={Gtk.Align.CENTER}>
                    {/* Placeholder for workspaces. Astal bindings would map hypr.workspaces here */}
                    <box cssClasses={["workspace-card", "active"]}>
                        <label label="1" cssClasses={["workspace-name"]} />
                    </box>
                    <box cssClasses={["workspace-card"]}>
                        <label label="2" cssClasses={["workspace-name"]} />
                    </box>
                    <box cssClasses={["workspace-card"]}>
                        <label label="3" cssClasses={["workspace-name"]} />
                    </box>
                </box>
            </scrollable>
        </box>
    </window>
}
