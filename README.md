# elm-shared-header


### About:


### Install:

Install all dependencies using the handy `reinstall` script:
```
npm run reinstall
```
*This does a clean (re)install of all npm and elm packages, plus a global elm install.*


### Serve locally:
```
npm start
```
* Access app at `http://localhost:8080/`


### Build & bundle for prod:
```
npm run build
```

* Files are saved into the `/dist` folder
* To check it, open `dist/index.html`


### Dynamically Load Script

```
(function(){var script = document.createElement("script");script.src = "https://intl.rakuten-static.com/b/gb/image/eucwd-testing/shared-header/main-f5763145aaf26b35b32a.js";document.head.appendChild(script);})();
```

### Changelog

**Ver 0.1.0**
