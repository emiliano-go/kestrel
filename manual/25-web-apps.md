# Web Apps

You can add your own web apps using _Install > Web App_ in the Kestrel menu (`Super + Space`). It'll ask you for the app name, app URL, and the icon URL, if it can't retrieve it via favicon. You can get great PNG icons for many popular web apps on [Dashboard Icons](https://dashboardicons.com).

They'll then be accessible through the app launcher (`Super + Space`), and use the beautiful frameless web-app window.

If you wish to remove a web app, just go to _Remove > Web App_ in the Kestrel menu.

It's best if you log into all your accounts using a regular browser before using the web app shortcuts. The thin wrapper frame doesn't work well with 1password, so just easier to be logged in directly first.

All the keyboard hotkeys for these web apps can be changed in `~/.config/hypr/bindings.lua`.

When you're in a web app, you can copy the current URL to the clipboard using `Shift + Alt + L`.

## Microsoft apps

Select _Install > Service > Microsoft_ to add Outlook, Word, Excel, PowerPoint, Teams, and OneDrive as web apps. Each app has its own launcher and opens directly, using the commercial Microsoft 365 URLs and your existing browser profile. They open in the same browser app windows as Kestrel's other web apps; they do not install the separate Teams for Linux client.

Remove the bundle with _Remove > Service > Microsoft_, or remove individual apps with _Remove > Web App_. You can also install just the apps you want through _Install > Web App_.

For a government or sovereign cloud, edit the URL on the `Exec=` line in the relevant launcher under `~/.local/share/applications/`, such as `Microsoft Teams.desktop`, using the URL supplied by your organization. Write any literal `%` in that line as `%%`. Changes apply on the next launch. Running the bundle installer again replaces its launchers with the default URLs.

To keep work sign-ins separate, append a browser data directory to each launcher's `Exec=` line:

```ini
Exec=kestrel-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Replace the example directory with an absolute path of your choice and use the same path for all six launchers to share work sign-ins between them. The web apps use Kestrel's selected supported browser, falling back to Chromium when the default browser is unsupported.
