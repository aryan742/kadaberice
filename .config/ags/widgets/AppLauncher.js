import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import Apps from "gi://AstalApps"

export default function AppLauncher() {
    const apps = new Apps.Apps()
    
    // Create a window that acts as an overlay
    return <window
        name="app-launcher"
        application={App}
        visible={false}
        keymode={Astal.Keymode.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        exclusivity={Astal.Exclusivity.IGNORE}
        layer={Astal.Layer.OVERLAY}
        onKeyPressEvent={(self, event) => {
            if (event.get_keyval()[1] === Gdk.KEY_Escape) {
                self.hide()
            }
        }}>
        <box cssClasses={["window-content", "app-launcher"]} vertical={true} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <entry 
                cssClasses={["search-entry"]}
                placeholderText="Search Applications..."
                widthRequest={500}
                onChanged={(self) => {
                    // Search logic here updating the flowbox
                }}
                onActivate={() => {
                    // Launch top result
                }}
            />
            <scrollable widthRequest={1000} heightRequest={400} vscrollbarPolicy={Gtk.PolicyType.NEVER} hscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}>
                <box cssClasses={["carousel-container"]} spacing={16} halign={Gtk.Align.CENTER}>
                    {/* Placeholder for apps. Query Apps and map to buttons */}
                    <label label="Apps will dynamically load here when AstalApps is initialized." />
                </box>
            </scrollable>
        </box>
    </window>
}
