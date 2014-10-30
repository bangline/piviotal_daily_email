# Daily Pivotal Emailer

## Getting started

Create a template in the `mails` folder. The template should be ERB with a YAML front matter (YFM).

```
---
name: Project Name <string>
id: Pivotal Project id <integer>
subject: Daily Email <string>
from: Sending Address <string>
to:
  - Reciever1 <string>
  - Reciever2 <string>
debug: true <bool>
---
Hi All,

Here is some erb
```

## Dry Runs

You can add a `debug` attribute to the YFM that will `puts` to STDOUT.

## ENVIRONMENT VARS

A few environment variables are needed before running:

* `PIVOTAL_KEY` - Your personal api key from pivotal
* `MANDRILL_USER` - MandrillApp user name
* `MANDRILL_PASS` - MandrillApp api key

## Running

```
bin/daily_emails
```
