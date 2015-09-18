Capkin
======


* Upload your `Android Apps`  to `Google Play`
* Uploads your apks to Alpha, Beta or Production


## Install


    gem install capkin


## Use

Inside your project folder:


```
capkin production
capkin beta
capkin alpha
```


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


### Client/Secret

> APIs & auth > Credentials > Add credential > OAuth 2.0 client ID > Other


### TODO

* Move already uploaded apk from stages
