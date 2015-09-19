Capkin
======

[![Gem Version](https://badge.fury.io/rb/capkin.svg)](http://badge.fury.io/rb/capkin)
[![Dependency Status](https://gemnasium.com/fireho/capkin.svg)](https://gemnasium.com/fireho/capkin)


* Uploads your `Android Apps` ➔ `Google Play`
* Choose upload to Alpha, Beta or Production stage.
* Promote apk from stages.


## Install


    gem install capkin


## Use

To upload a **new** `.apk`:

**TODO**


To upload a **new version** `.apk`:


    capkin production
    capkin beta
    capkin # defaults to 'alpha'



To move current version to another stage:


**TODO**


## Capkin

Config file (just run `capkin` to generate):


```
app: 'Foo'             # App name
name: 'com.your.app'   # App namespace
build: 'build/'        # App apk folder
```


## Login/Auth

On Google Developer:

> Create a new project

On Play:

> Settings > API access > Link your developer project


### JSON Key

> APIs & auth > Credentials > Add credential > Service Account > JSON


```sh
export GOOGLE_APPLICATION_CREDENTIALS='/path/to/googs.json'
```


### Client/Secret

> APIs & auth > Credentials > Add credential > OAuth 2.0 client ID > Other


**TODO**


## Cordova Rake

If you're using cordova/phonegap/ionic, also check out:

https://github.com/nofxx/cordova-rake
