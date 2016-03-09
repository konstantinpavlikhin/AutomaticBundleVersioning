# AutomaticBundleVersioning

## Installation

### 1. Add AutomaticBundleVersioning as a Git submodule

```bash
git submodule add git@github.com:konstantinpavlikhin/AutomaticBundleVersioning.git Submodules/AutomaticBundleVersioning
```

### 2. Add a new run script build phase

Select an application target in your Xcode project and navigate to 'Build Phases' tab. Press a '＋' button and choose a "New Run Script Phase". Rename the newly added phase to `Run AutomaticBundleVersioning Script`.

### 3. Expand the `Run AutomaticBundleVersioning Script` section and replace its contents with the following:

```bash
./Submodules/AutomaticBundleVersioning/AutomaticBundleVersioning.sh
```

### 4. Remove manual version definitions from the Info.plist file

Open your `Info.plist` file and remove "Bundle version" (`CFBundleVersion`) and "Bundle versions string, short" (`CFBundleShortVersionString`) key-values.

You're done.
