Capkin
======

* Upload your `Android Apps` ➔ `Google Play`
* Uploads your `.apk` to Alpha, Beta or Production stages.
* Promote apk from stages.


## Install


    gem install capkin


## Use

To upload a new `.apk`:

```sh
capkin production
capkin beta
capkin alpha
```

To move current version to another stage:

**TODO**

## Capkin

Config file:

```
name: 'Foo'
app: 'com.your.app'
build: 'build/'
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


## Capkin
