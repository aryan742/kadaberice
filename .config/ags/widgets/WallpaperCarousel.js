import { App, Astal, Gtk, Gdk } from "astal/gtk3"

export default function WallpaperCarousel() {
    return <window
        name="wallpaper-carousel"
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
        <box cssClasses={["window-content", "wallpaper-carousel"]} vertical={true} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label label="Wallpaper Gallery" cssClasses={["workspace-name"]} margin-bottom={24} />
            
            {/* Categories */}
            <box spacing={12} halign={Gtk.Align.CENTER} margin-bottom={24}>
                <button label="Shiva" />
                <button label="Krishna" />
                <button label="Hanuman" />
                <button label="Rajput" />
                <button label="Nature" />
                <button label="Minimal" />
            </box>

            {/* Gallery Carousel */}
            <scrollable widthRequest={1000} heightRequest={400} vscrollbarPolicy={Gtk.PolicyType.NEVER} hscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}>
                <box cssClasses={["carousel-container"]} spacing={16} halign={Gtk.Align.CENTER}>
                    {/* Placeholder for images. In real implementation, bind to Gio.File enumeration */}
                    <box cssClasses={["wallpaper-card", "active"]}>
                        <label label="[Image 1]" widthRequest={300} heightRequest={200} />
                    </box>
                    <box cssClasses={["wallpaper-card"]}>
                        <label label="[Image 2]" widthRequest={300} heightRequest={200} />
                    </box>
                    <box cssClasses={["wallpaper-card"]}>
                        <label label="[Image 3]" widthRequest={300} heightRequest={200} />
                    </box>
                </box>
            </scrollable>
        </box>
    </window>
}
