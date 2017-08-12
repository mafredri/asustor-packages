# ASUSTOR Packages

This is a repository for ASUSTOR packages. The downloads for all packages that aren't submodules can be found in the package directory. Submodules usually have their own releases available on the release page of the repository.

Download: [Package directory](https://app.box.com/s/nw45lg0w0y5jzh1529gkqs52j1hct5zq)

## Error code table (for app developers)

| Code | Possible conditions |
| ---: | :------------------ |
| -192 | Unsupported APK format or the APK is corrupt |
|   -2 | `config.json` is missing or corrupt |
|  -61 | `config.json` is missing or corrupt |
| -423 | This APK architecture is not supported on this NAS |
| -424 | This APK version is too old |
| -184 | The ADM version is too old for this APK |
| -154 | There is an error when running `pre-install.sh` or `post-install.sh` (return code ≠0) |
|  -75 | The registered port number has reached the max limitation |
| -318 | The port has been taken |
| -319 | The port is reserved by ADM |
|   -7 | The port is illegal |
| -161 | Icon file is corrupt or the port has been taken |
