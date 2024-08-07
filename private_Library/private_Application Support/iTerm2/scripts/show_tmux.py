#!/usr/bin/env python3

# Show the tmux session with the given name

import iterm2
import sys
from subprocess import run, PIPE
from run_command import run_command


def getClients(session_name):
    clients = run([
        'tmux',
        'list-clients',
        '-F',
        '#{client_pid},#{client_session}'
    ], stdout=PIPE, text=True).stdout.split("\n")
    clients = list(filter(
        lambda x: x and x.split(",")[1] == session_name, clients
    ))
    return list(map(lambda x: int(x.split(",")[0]), clients))


def showHotkeyWindow():
    run([
        "/opt/homebrew/bin/cliclick",
        "kd:cmd,alt,shift",
        "t:-",
        "ku:cmd,alt,shift"
    ])


async def findSession(app, clients):
    for window in app.windows:
        for tab in window.tabs:
            for session in tab.sessions:
                if await session.async_get_variable("jobPid") in clients:
                    await session.async_activate()
                    if await window.async_get_variable("titleOverrideFormat") \
                            == "Hotkey Window":
                        showHotkeyWindow()
                        await window.async_activate()
                    else:
                        await tab.async_activate()
                        await window.async_activate()
                    return
    raise Exception("No session found")


async def main(connection):
    app = await iterm2.async_get_app(connection)
    session_name = sys.argv[1]
    clients = getClients(session_name)
    try:
        await findSession(app, clients)
    except Exception:
        cmd = f"""
tmux a -t {session_name} || {{ _t=$(tmux display-message -p '#{session_name}');
tmux switchc -t {session_name}; tmux kill-session -t $_t; }}\n
        """
        await run_command(connection, cmd)


iterm2.run_until_complete(main)
