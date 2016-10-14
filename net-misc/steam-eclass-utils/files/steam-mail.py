#!/usr/bin/env python

# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

from __future__ import print_function

from imaplib import IMAP4_SSL
import re
import sys


SERVER = sys.stdin.readline().strip()
USER = sys.stdin.readline().strip()
PASS = sys.stdin.readline().strip()

if len(SERVER) * len(USER) * len(PASS) <= 0:
    print('server, username, and password separated by newlines must be '
          'supplied on stdin', file=sys.stderr)
    sys.exit(1)

print('conncting to "{}"'.format(SERVER), file=sys.stderr)
M = IMAP4_SSL(SERVER)
# M.enable('UTF8=ACCEPT')
# print(M.capabilities)
print('authenticating', file=sys.stderr)
M.authenticate('PLAIN', lambda response: b'\0' + USER.encode() + b'\0' +
               PASS.encode())
M.select('INBOX')
typ, data = M.search(None, '(FROM "Steam Support")')
index = data[0].split()[-1]
print('found message "{}"'.format(index.decode()), file=sys.stderr)
typ, data = M.fetch(index, '(RFC822)')
message = data[0][1].splitlines()
# print(message)

r = re.compile(b'Date: ')
date = [l.decode('utf8') for l in message if r.match(l)]
print('message date: "{}"'.format(date[0][6:]), file=sys.stderr)

r = re.compile(b'[A-Z1-9]{5}$')
keys = [l.decode('utf8') for l in message if r.match(l)]
print(keys[0])

M.logout()
