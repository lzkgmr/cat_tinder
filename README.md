# pussycats - Cat Tinder

An app for searching cat photos and learning about breeds.  
[Download APK](https://github.com/lzkgmr/cat_tinder/releases/download/meow/app-release.apk)

## What's in the app?

### 1. Pretty icon and funny loading animation with cats>
<img src="assets/images/animation.png" height="400"> <img src="assets/icons/cat_icon.png" width=200 style="vertical-align: top;">


### 2. Tinder mechanics
Tinder mechanics with cat selection. Information is loaded from `TheCatAPI.com`. There are lots of cat photos.

User can **swipe right and left** or **use buttons**. If user likes the cat, he can mark it and likes counter will increase. 

<img src="assets/images/tinder.png" height="400">

### 3. Breed list
If user taps on `Pow Button` on main screen, he will see **Breed list**. 

<img src="assets/images/breed_list.png" height="400">

### 4. Liked cats screen
If user taps on `Heart Button` on main screen, he will see **Liked cats**.
Breeds in this list are unique. User can *open details*, *remove particular cat* or *clean all of them*. Like counter on the main screen will update. 

<img src="assets/images/liked_cats.png" height="400"> <img src="assets/images/alert.png" height="400"> <img src="assets/images/no_liked_cats.png" height="400">

### 5. Last, but not least! Breed details.
User can open breed details from the `main screen` (tap to picture of the cat), from the `breed list` and from the `liked cats`.
There is an information about breed:
1. Picture 
2. Temperament
3. Origin
4. Short description
5. Adaptability (5-point scale)
6. Intelligence
7. Life span
8. Weight (metric)

<img src="assets/images/details1.png" height="400"> <img src="assets/images/details2.png" height="400"> 

### Some important details 
- The list of liked cats and their number is saved between app launches.
- All functional requirements are met.
- An additional feature has been implemented: a list of liked cats.
- Design of the app is adorable.
- The code is formatted using `dart format`.
- `flutter_lints` is enabled and used (2 rules).
- The flutter analyze command runs successfully.
- The `http package` and `TheCatApi.com' were used.
- The `Image` and `CachedNetworkImage` widget is used to display images.