# Bashlet

Simple git based script registry

## Install

```bash
curl -sSL https://github.com/audacioustux/bashlets/raw/refs/heads/main/bashlet.sh | bash -s install bashlet
```

> **Make sure $HOME/.local/bin is in $PATH**

## Update

```bash
bashlet install bashlet
```

## Usage

### Install a script

```bash
# retries to run a command with exponential backoff (max-delay 5s)
bashlet install util/ebort
```

### Execute a script without installing

```bash
# print help / usage / man
bashlet exec util/ebort -h

# retries to run a command with exponential backoff (max-delay 5s)
bashlet exec util/ebort -v -u 5 bash -c 'rand=$(( RANDOM % 5 )); echo "Random number: $rand"; (( rand == 0 ))'
```
