#!/usr/bin/env python3

# This hooks script syncs task warrior to the configured task server.
# The on-exit event is triggered once, after all processing is complete.

# Make sure hooks are enabled and this hook script is executable. 
# Run `task diag` for diagnostics on the hook.

import sys
import json
import subprocess

try:
    tasks = json.loads(sys.stdin.readline())
except:
    # No input
    pass

import asyncio, asyncssh, sys

async def sync_server():
    async with asyncssh.connect(
            '127.0.0.1',
            username='$USERNAME',
            password='$PASSWORD') as conn:
        pass

        result = await conn.run('/usr/bin/task sync', check=True)
        print(result.stdout, end='')

async def sync_mac():
    async with asyncssh.connect(
            '127.0.0.1',
            username='$USERNAME',
            password='$PASSWORD') as conn:
        pass

        result = await conn.run('/usr/local/bin/task sync', check=True)
        print(result.stdout, end='')

# Call the `sync` command
# hooks=0 ensures that the sync command doesn't call the on-exit hook
# verbose=nothing sets the verbosity to print nothing at all
subprocess.call(["task", "rc.hooks=0", "rc.verbose=nothing", "sync"])

# sync the server
try:
    asyncio.get_event_loop().run_until_complete(sync_server())
except (OSError, asyncssh.Error) as exc:
    sys.exit('SSH connection failed: ' + str(exc))

# sync the mac computer
try:
    asyncio.get_event_loop().run_until_complete(sync_mac())
except (OSError, asyncssh.Error) as exc:
    sys.exit('SSH connection failed: ' + str(exc))
  
sys.exit(0)
