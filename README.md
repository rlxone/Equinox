<div><br></div>

<div align="center">
  <img alt="GitHub Workflow Status (branch)" src="https://img.shields.io/github/actions/workflow/status/rlxone/Equinox/workspace.yml"> <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/rlxone/Equinox"> <img alt="GitHub" src="https://img.shields.io/github/license/rlxone/Equinox">
</div>

<div><h1></h1></div>

<div align="center">
  <a href="https://equinoxmac.com/">
    <img src="repo/logo.png" width="200" height="200"/>
  </a>
  <h1>Equinox</h1>
  <p>Create dynamic wallpapers for macOS</p>
  <br>
</div>
<div align="center">
  <a href="https://apps.apple.com/us/app/equinox-create-wallpaper/id1591510203">
    <img src="repo/mac_store_button.png" height="48" />
  </a>
  <img width="4" />
  <a href="https://github.com/rlxone/Equinox/releases">
    <img src="repo/github_button.png" height="48" />
  </a>
  <img width="4" />
  <a href="https://equinoxmac.com">
    <img src="repo/website_button.png" height="48" />
  </a>
  <img width="4" />
  <a href="https://www.producthunt.com/posts/equinox-2?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-equinox-2" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=320600&theme=dark" alt="Equinox - Create dynamic wallpapers for macOS | Product Hunt" style="width: 222px; height: 48px;" width="222" height="48" /></a>
</div>

<div><h1></h1></div>

<div aligh="center">
  <img src="repo/screen.png" />
</div>

## Description
**[Equinox](https://equinoxmac.com)** is an application that allows you to create macOS native wallpapers. Starting macOS Mojave we have such cool things as `«Dynamic Desktop»`, `«Light and Dark Desktop»` types of wallpapers. With the help of the **`Equinox`** application, you can easily create those with a few clicks in seconds. Just select a suitable type, drag and drop your images and create your wallpaper.

## Features

There are `three` types of wallpapers that you can create:
1. **[Solar](#solar-wallpaper)**
3. **[Time](#time-wallpaper)**
4. **[Appearance](#appearance-wallpaper)**

<div><h1></h1></div>

### Solar wallpaper
<img src="repo/solar.png" width="300"/>

- The main feature of this type of wallpaper is that it takes the position of the sun into account. Depending on the time of year you will see the most relevant image on your desktop. Don't worry about calculations for sun positions. With the help of the **[«Solar calculator»](#solar-calculator)** you only need to know where and when you took a photo.

### Time wallpaper
<img src="repo/time.png" width="300"/>

- Time is the key to this type of wallpaper. The desktop picture changes throughout the day, based on the time you choose.

### Appearance wallpaper

<img src="repo/appearance.png" width="300"/>

- This type of wallpaper is as simple as it is. The desktop picture changes throughout the day, based on system appearance change. You need two images: one for light and one for dark mode.

<div><h1></h1></div>

### Solar calculator

<div align="center">
  <img src="repo/calculator.png" width="600" />
</div>

It will help you to calculate the position of the sun in the sky. 
1. Choose the `place`, `date`, and `time` on the `«Sun timeline»` when you took a photo. If you don't know the exact time you can use the sun timeline to see how high or low the position of the sun in the sky is and match it with the photos you have.
2. Drag and drop or copy the result over your image.

## Shots
<div align="center">
   <img src="repo/screen1.jpg" />
</div>

## FAQ
- Q: How to set the wallpaper after saving?
- A: Right click on your wallpaper, then `«Services»` -> `«Set Desktop Picture»`

<br>

- Q: I set up my wallpaper, but it won't change over time. Looks like it doesn't work.
- A: Due to macOS bug you need to set `«Dynamic»` type in your `«Desktop & Screen Saver»` macOS Preferences before you set the wallpaper. 
    1. Open `«Desktop & Screen Saver»` macOS Preferences.
    2. Choose any `«Dynamic Desktop»` wallpaper and set it’s type to `«Dynamic»`.
    3. Right click on your wallpaper, then `«Services»` -> `«Set Desktop Picture»`

<br>

- Q: How to test that my wallpaper works correctly?
- A: Open `«Preferences»` -> `«Date & Time»`, change the time to see how wallpaper works over time.

## Requirements
- macOS 10.14 (Mojave) and later

## Libraries
- **[SolarNOAA](https://github.com/rlxone/SolarNOAA)**

## Thanks
Many thanks to the macOS community and special thanks to [mczachurski](https://github.com/mczachurski) and his awesome articles.

## License
[MIT](LICENSE)

## Translation

Equinox is translated to:
- English
- French, by [W1W1-M](https://github.com/W1W1-M)
- Türkçe, by [furkanipek](https://github.com/furkanipek)
- Chinese (Simplified), by [Chuan Hu](https://github.com/GaiZhenbiao), [DevLiuSir](https://github.com/DevLiuSir)
- Chinese (Traditional), by [5idereal](https://github.com/5idereal)
- Chinese (Traditional, Hong Kong), by [changanmoon](https://github.com/changanmoon)

To translate Equinox to another language:
- Fork the main branch 
- Make a branch for the new translation as follows: `translation-xx` where xx is the language code (ex: en, fr, es, de, ...)
- Add the new language to the Xcode `Equinox` & `EquinoxAssets` projects
- Add the new language to `Localizable.strings` localization languages in `EquinoxAssets`
- Update `Localizable.strings` for the new language with your translated strings
- Update this part of the README with the new language
- Write a pull request on GitHub
