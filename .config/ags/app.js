import { App } from "astal/gtk3"
import style from "./styles/main.css"
import AppLauncher from "./widgets/AppLauncher.js"
import WorkspaceCarousel from "./widgets/WorkspaceCarousel.js"
import WallpaperCarousel from "./widgets/WallpaperCarousel.js"

App.start({
    css: style,
    main() {
        // Initialize windows
        AppLauncher()
        WorkspaceCarousel()
        WallpaperCarousel()
    },
})
