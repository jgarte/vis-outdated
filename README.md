# vis-outdated

Keep up-to-date with a list of git repos using [vis](https://github.com/martanne/vis).

> It might be a simpler solution for keeping up to date with a set of `vis` plugins, instead of using e.g. [vis-plug](https://github.com/erf/vis-plug)

## How

Given a list of git repos, we fetch the latest commit hashes using `git ls-remote` and store them in a local cache `~/.vis-outdated`. Now we can compare the local hashes with the latest to see if they are up-to-date.

Note: Once you notice any repos are outdated, you need to update them yourself, `out-up` only updates the local hashes.

## Commands

**out-ls** - list current + latest repo hashes

**out-df** - check if current repos are lagging behind

**out-up** - update local hashes to latest

**out-in** - git clone (shallow) repos to **vis** `plugins` folder

## Example


Example configuration:

```
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
	'https://github.com/erf/vis-highlight',
}
```

## Local cache file

A list of *repos* and *commit hashes* are stored in the file `.vis-outdated`, 
which is stored in either `XDG_CACHE_HOME` or in your `HOME` folder.

File format:

| url | hash |
|-----|------|
| https://github.com/erf/vis-title.git | 98c037f444b12f7cfaba25be954a582861f09990 |
| https://github.com/erf/vis-cursors.git |a9c615d16cbb8b0203cce9d988f72ae7dd327cf3 |
