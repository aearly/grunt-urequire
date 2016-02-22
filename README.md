# grunt-urequire 0.7.3
==============

Grunt (>= 0.4.5 ) wrapper for [uRequire](https://github.com/anodynos/uRequire), (>= v0.7.0)

**Note: You 'll need `npm install urequire` (version >- 0.7.0) already installed with your project - it comes only as a `peerDependency` of `grunt-urequire`.**

### Introduction

uRequire [config objects](http://urequire.org/masterdefaultsconfig.coffee#config-usage) become grunt tasks as they are.

Using Grunt + uRequire saves you a huge amount of effort and the need for many grunt plugins + their tedious configuration. uRequire uses an in-memory conversion pipeline without the need for intermediate files and repetitive configurations listing the same source and destination paths all over again. Its like gulp on steroids.

You 'll keep it DRY (Dont Reapeat Yourself) and eliminate the need of many grunt plugins for tasks like compiling from coffee-script, coco, LiveScript etc, creating banners etc with `grunt-contrib-concat`, minimizing with `grunt-contrib-uglify`, watching with `grunt-contrib-watch`, running hand written specrunners with `grunt-mocha` and many many others.

All of these these features plus much more, become a single line of declarative uRequire config or the declarative invocation of a `ResourceConverter` such as [`inject-version`](https://github.com/anodynos/urequire-rc-inject-version) or [`import-keys`](https://github.com/anodynos/urequire-rc-import-keys) or invoking an `afterBuild`-er such as [`urequire-ab-specrunner`](https://github.com/anodynos/urequire-ab-specrunner) or [`urequire-ab-grunt-contrib-watch`](https://github.com/anodynos/urequire-ab-grunt-contrib-watch).

Plus you can do many module, dependencies & code manipulation related tasks that no other task runner allows you to do, such as `import`-ing, injecting or renaming dependencies, manipulating & merging common code and much more.

Ah, and did I mention full AMD, commonJS, UMD and combined (i.e all-in-one AMD, nodejs & `</script>`) module transformation? Well, this is the primary goal of uRequire and it does it better that any other tool out there.

### Simple example

```coffeescript

    urequire:

      _defaults:
        path: 'source/lib'
        main: 'myLibrary'
        dependencies: imports: {'lodash': '_'}
        resources: ['inject-version']
        template: banner: true

      UMD:
        template: 'UMDplain'
        dstPath: 'build/UMD'

      dev:
        template: 'combined'
        dstPath: 'build/myLibrary-dev.js'
```

### Features

#### `derive`-ing from parent configs

You can specify a `derive: ['configname1', 'configname2']` to derive (inherit) from one or more configs.

The **left most** derive subconfigs (eg `'configname1'`) **have precedence** over others on their right.

Note that you also recursively inherit from all declared derive parent's and grand-parents etc as well.

Finally you can omit the Array [], if you derive only from one, eg `derive: 'specs'`

##### `_defaults`

By default all sub-configs with an undefined `derive` key, derive from `_defaults` (if it exists) as in the example above.

If you _do_ specify a `derive` key (eg `derive: ['UMD', 'production']`), you derive only those specified, but NOT from `_defaults`.

If you want to NOT derive from an existing `_defaults` and no other config at all, just use an empty array, i.e `derive: []`.

Note that if you want to derive from one that implicitly derives fom `_defaults`, you need to add `_defaults` in its list of `derive`s as well.

##### `_all`

To solve the later situation, all configs irrespectively derive from `_all` (if that exists), as the last implicit `derive`.

As a summary, 2 + 1 rules:

  a) an undefined `derive` actually derives from `['_defaults', '_all']`, if any of those actually exist, in that order.

  b) a specified `derive` like `derive: ['config1', 'config2']` actually becomes `['config1', 'config2', '_all']` (it omits `_defaults`).

  b2) a specified but empty `derive` like `derive: []` actually becomes `derive: ['_all']`, if `_all` exists at all.

##### Full `derive`-ing example

Here's 3 different `library` & 3 different `spec` builds for the sake of the example:

```coffeescript

    urequire:

      _all:                          # used by all irrespectively
        dependencies: imports: { lodash: ['_'] }
        template: banner: true

      _defaults:                     # used only for lib
        path: 'source/lib'
        main: 'myLibrary'
        resources: ['inject-version']

      UMD:
        template: 'UMDplain'
        dstPath: 'build/UMD'

      dev:
        template: 'combined'
        dstPath: 'build/myLibrary-dev.js'

      min:
        derive: ['dev', '_defaults'] # need `_defaults` specifically if (for some reason) we want
                                     # to derive from 'dev', which implicitly derives from `_defaults`
        dstPath: 'build/myLibrary-min.js'
        optimize: 'uglify2'

      spec:
        derive: []                   # doesn't derive from `_defaults`, only `_all`
        path: 'source/specs'
        main: 'specs-index'
        dstPath: 'build/specs'
        dependencies: imports: {'chai': 'chai'}

      specDev:
        derive: 'spec'              # derive only from `spec` above and `_all` (not `_defaults`)
        dstPath: 'build/specs-dev.js'
        template: 'combined'

      specMin:
        derive: ['specDev']         # derive only from `specDev` (and consequently `spec`, followed by `_all`)
        optimize: true
```

Note that urequire configs starting with a `'_'` are ignored as grunt tasks - they are considered _abstract_ configs and wont execute.

See the uRequire docs for deriving for more info.

#### Watching & Auto-watching

You can use `grunt-contrib-watch` v0.5.x that invokes a urequire:task target, issuing a partial build of changed files only.

You can do it in two ways:

##### Define your own watch task

The grand daddy way & boring way is to manually write it __(DRY warning: with information already in your urequire config)__:

    ```coffeescript
        watch:
          UMD:
            files: ['source/lib/**/*']
            tasks: ['urequire:UMD']
          options: spawn: false
    ```

*Important note*: Use `watch: xxx: {options: spawn: false}` to allow uRequire to use the the already loaded bundle/modules information for rapid rebuilds of only changed files.

#### Use the auto configuring [`urequire-ab-grunt-contrib-watch`](https://github.com/anodynos/urequire-ab-grunt-contrib-watch)

The simpler way is to have `grunt-urequire` auto configure and invoke a watch task, since the paths & tasks information is already in your urequire config. Just use the special `'grunt-urequire'` keyword instead of `true` for urequire's watch:

    ```
    urequire:
      UMD:
         ...
         watch: 'grunt-urequire'
         ...
    ```
that auto configures and runs the above.

##### Passing options

Is you want to pass [`grunt-contrib-watch` *options*](https://github.com/gruntjs/grunt-contrib-watch#watch-task) use this syntax:

    ```
      watch:
        info: 'grunt-urequire'
        debounceDelay: 1439
        someOtherGruntContribOption: 'value'
    ```
but be warned that `atBegin: true` and `spawn: true` should not be set.

##### Other options

You can pass more options to [`urequire-ab-grunt-contrib-watch`](https://github.com/anodynos/urequire-ab-grunt-contrib-watch), like any grunt (or grunt-urequire) tasks that run `before` or `after` the current task at each watch cycle, or other `files` to be watched and trigger a watch cycle if they change:

    ```
    urequire:
        UMD:
          path: 'source/code'
          watch:
            info: 'grunt-urequire'
            before: ['clean:cache', 'concat:useless'] # an `Array` of grunt tasks
            after: 'urequire:spec zip:UMD email:me'   # a `String` with space separated grunt task is also fine
            files: ['some/path/files/**/*', ...]

        spec: ....

    ```

If the task is a `urequire:someTask`, then its `bundle.path` as a files pattern is added to `grunt-contrib-watch` files automatically.

For more information see [`urequire-ab-grunt-contrib-watch`](https://github.com/anodynos/urequire-ab-grunt-contrib-watch) that is powering the auto `grunt-contrib-watch` feature.

#### Automagically run `specs` against `libs`

Manually configuring `watch`, `mocha` tasks and phantomjs, requirejs/AMD & all their relative paths, configs, shims, HTMLs etc against each different build, can be a huge pain. You 'll find repeating your self too much, fiddling with what paths work and what breaks, instead of writing awesome libs and specs.

So do check out the [urequire-ab-specrunner](https://github.com/anodynos/urequire-ab-specrunner) `afterBuild`-er which uses the uRequire `bundle` & `build` information already in your urequire config, auto discovers the bower paths and automagically generates, configures and runs your specs against a lib.

It works perfectly with watching through `grunt-contrib-watch`, which __you dont__ need to configure at all. And it knows if your bundle sources really changed or if build failed, so it wont run the specs until resolved or really changed.

All with a single declaration, no other configuration! It even auto generates the SpecRunner HTML, the RequireJs config & paths (or depending on the templates used the <script src='../../../tedious/paths/to/somedep.js'/> that still respect the requirejs config's `shim`) and runs them!

All you 'll need is:

    ```coffeescript
       specRun:
         derive: ['spec']
         dependencies: paths: bower: true
         afterBuild: require('urequire-ab-specrunner')
    ```

or just add the `afterBuild: require('urequire-ab-specrunner')` to `spec` so that all `specXXX` inherit it, and hit `$ grunt UMD specMin`.

Add a `watch: true` to your config, and `watch`-ing starts automatically after the first build (it actually auto configures and invokes `grunt-contrib-watch`) through [`urequire-ab-grunt-contrib-watch`](https://github.com/anodynos/urequire-ab-grunt-contrib-watch) just like `grunt-require` does with `'watch: 'grunt-urequire'`).

### More

For all config options check out [the documentation at uRequire.org](http://uRequire.org).

#### More examples

Check out [urequire-example](https://github.com/anodynos/urequire-example) & [uBerscore](https://github.com/anodynos/uberscore) for a full working examples.
