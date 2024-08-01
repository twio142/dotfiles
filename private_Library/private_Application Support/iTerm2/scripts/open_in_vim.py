#!/usr/bin/env python3

import iterm2
import os
import sys
import shlex
from subprocess import run, PIPE
from run_command import isUsable, run_command

""" Open files in nvim in the active session
    or in nvim in the active tmux pane
    or open a new nvim session if none is found. """


async def findSession(app):
    win = app.current_window
    if not await isUsable(win):
        return
    tab = win.current_tab
    session = tab.current_session
    job = await session.async_get_variable("jobName")
    if job in ["nvim", "tmux"]:
        return session, job


def getChildren(pid):
    children = run([
        "pgrep",
        "-P",
        str(pid)
    ], stdout=PIPE, text=True).stdout
    children = children.strip().split("\n")
    return list(map(int, children))


async def findSocket(session):
    nvim = await session.async_get_variable("jobPid")
    nvim = getChildren(nvim)[0]
    tmpdir = os.getenv("TMPDIR")
    sockets = run([
        "find", tmpdir, "-type", "s", "-name", "nvim.*"
    ], stdout=PIPE, text=True).stdout
    sockets = sockets.strip().split("\n")
    for socket in sockets:
        if not socket:
            continue
        if nvim == int(socket.split("/")[-1].split(".")[1]):
            return socket


async def openInVim(connection, files):
    app = await iterm2.async_get_app(connection)
    session, job = await findSession(app)
    if not files:
        await session.async_activate()
        await app.async_activate()
        return
    if not session:
        raise Exception("No nvim or tmux session found")
    if job == "tmux":
        code = run([
            os.getenv("HOME") + "/.config/tmux/scripts/open_in_vim.sh",
            *files
        ]).returncode
        if code != 0:
            raise Exception("Error opening files in tmux")
    else:
        socket = await findSocket(session)
        if not socket:
            raise Exception("No socket found")
        run([
            "/opt/homebrew/bin/nvim",
            "--server",
            socket,
            "--remote-tab",
            *files
        ])
    await session.async_activate()
    await app.async_activate()


async def main(connection):
    files = sys.argv[1:]
    try:
        await openInVim(connection, files)
    except Exception:
        if not files:
            input = "vim\n"
        else:
            files = [shlex.quote(file) for file in files]
            input = "vim " + " ".join(files) + "\n"
        await run_command(connection, input)

iterm2.run_until_complete(main)
