# Hectoragent
<p>
    hectorapp.io is a SAAS application that allows you to keep an eye on the health of your servers and websites at all times.
</p>
<p>
  This software is a distributed agent written in Python, compatible with versions >= 3 which aims to collect information from the server so that it can be monitored. The latter has been optimized to consume as few resources (cpu, ram, etc.) as possible.
</p>
<p>
  <a href="https://github.com/hectorapp/hector-agent/issues/new">Report bug</a>
</p>

## Installation
The installation is done from the bash script named `hector-install.sh`.

In order for your server to communicate with our SAAS application, the bash script requires an authentication token as a parameter:

```
./hector-install.sh <token>
```

/!\ We invite you to go to your hectorapp.io dashboard and add a new server to get a token. Attention! It is important to run the script as `root` so that the agent can install correctly. Then a secure user used by the agent is created.

## Supported/Recommended OS
The versions listed below are the recommended versions. However, it is possible that the agent will work on older versions.

- [x] Ubuntu 16.04/18.04
- [x] Debian 9/10
- [x] Centos 7.5/7.6
- [x] Fedora 29/30
