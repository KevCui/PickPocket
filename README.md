PickPocket
==========

> A highly customizable framework to pick any items in your Pocket list in order to automatize further actions

## Why

[Pocket](https://getpocket.com/) is a great service to collect all kinds of information. Sometimes, I need to automatize the action regarding certain specific item link in list, for instance: If it's a YouTube video link, then download video. However, [the official Pocket API](https://getpocket.com/developer/) is a bit overkilled to achieve this automation purpose, especially the authentication part... Therefore, this lightweight framework will do the "dirty work" to pick items in your Pocket list and perform any actions as you planned.

## Features

- No need to sign in Pocket account additionally
- No need to register Pocket API
- Easily hook up customizable function for individual item in the list
- No need brain to set up configuration for matches

## How it works

This framework needs cookies from `getpocket.com` to bypass authentication. So a signed-in account in local browser is mandatory. With this cookie data, `pickpocket.sh` will fire request to get JSON data of your Pocket list. By configuring `match.conf`, the pattern-matched item will be linked to a function in `custom-func.sh`, where the further actions will be executed.

### Pre-condition

- Sign in a Pocket account in local browser: Firefox, Chromium or Chrome.

- Create `match.conf` in script root directory. Copy and edit `match.conf.sample` to `match.conf` is recommended.

- Edit `match.conf`, put `<key> <pattern> <function name>` per line.
  - <key>: Here is [a list of available keys](https://getpocket.com/developer/docs/v3/retrieve) in response data. For example: `item_id`, `tags`, `resolved_url` or ...
  - <pattern>: regex
  - <function name>: The name of the function which is predefined in `custom-func.sh`.

- Prepare new functions in `custom-func.sh`. Pocket related API calls can be found in 'lib/pocket-api-call.sh'.

### Usage

```
Usage:
  ./pickpocket.sh <cookie_db>

Options:
   <cookie_db>     required, path to cookie db
   --help          display this help message
```

## Example

- Use Chromium cookie database:

```bash
~$ ./pickpocket.sh ~/.config/chromium/Default/Cookies
```

- Use Firefox cookie database:

```bash
~$ ./pickpocket.sh ~/.mozilla/firefox/<profile>/cookies.sqlite
```
