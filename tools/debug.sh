#!/bin/bash

# Debug RethinkDB queries

tcpdump -nl -w - -i lo0 -c 500 port 28015|strings
