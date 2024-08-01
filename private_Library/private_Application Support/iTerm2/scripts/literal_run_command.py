#!/usr/bin/env python3

import iterm2
import sys
import os
from subprocess import run


async def isEmpty(session):
    line_info = await session.async_get_line_info()
    lines = await session.async_get_contents(
        first_line=line_info.scrollback_buffer_height,
        number_of_lines=line_info.mutable_area_height
    )
    lines = [line.string for line in lines if line.string != ""]
    if 0 < len(lines) <= 2 and lines[0].startswith("Last login: "):
        return True
    if len(lines) == 3 and lines[0].startswith("Last login: "):
        if lines[-1] != "❯ ":
            await session.async_send_text("\003")
        return True
    commandLine = await session.async_get_variable("commandLine")
    jobName = await session.async_get_variable("jobName")
    print(jobName, commandLine)
    if commandLine == "":
        return True
    if jobName == "tmux" and await checkTmux(session):
        return True
    isEmpty = jobName == "zsh"
    if isEmpty and len(lines) > 0 and lines[-1] != "❯ ":
        print(lines[-1])
        await session.async_send_text("\003")
    return isEmpty


async def isUsable(window):
    return window and \
        await window.async_get_variable('style') != "accessory" and \
        await window.async_get_variable(
            "titleOverrideFormat"
        ) != "Hotkey Window"


async def checkTmux(session):
    pid = await session.async_get_variable("jobPid")
    script = os.getenv("HOME") + "/.config/tmux/scripts/find_empty_shell.sh"
    return run([script, str(pid)]).returncode == 0


async def run_command(connection, input=""):
    app = await iterm2.async_get_app(connection)
    if len(app.windows) == 1 and not await isUsable(app.current_window):
        await iterm2.Window.async_create(connection)
        session = app.current_window.current_tab.current_session
        await session.async_send_text(input)
        await session.async_activate()
        await app.async_activate()
        print("No current window")
        return
    if len(app.windows) and \
            len(app.current_window.tabs) and \
            len(app.current_window.tabs) and \
            await isEmpty(app.current_window.current_tab.current_session):
        session = app.current_window.current_tab.current_session
        await session.async_send_text(input)
        await session.async_activate()
        await app.async_activate()
        print("Current session is empty")
        return
    if len(app.current_window.current_tab.sessions) > 1:
        print("Current tab has multiple sessions")
        for session in app.current_window.current_tab.sessions:
            if await isEmpty(session):
                await session.async_send_text(input)
                await session.async_activate()
                await app.async_activate()
                print("Current tab has empty session")
                return
    if len(app.current_window.tabs) > 1:
        print("Current window has multiple tabs")
        for tab in app.current_window.tabs:
            for session in tab.sessions:
                if await isEmpty(session):
                    await session.async_send_text(input)
                    await session.async_activate()
                    await app.async_activate()
                    print("Current window has empty tab")
                    return
    if len(app.windows) > 1:
        print("Multiple windows found")
        for window in app.windows:
            if window == app.current_window or not await isUsable(window):
                continue
            for tab in window.tabs:
                for session in tab.sessions:
                    if await isEmpty(session):
                        await session.async_send_text(input)
                        await session.async_activate()
                        await window.async_activate()
                        await app.async_activate()
                        print("Another window has empty session")
                        return
    tab = await app.current_window.async_create_tab()
    await tab.current_session.async_send_text(input)
    await tab.current_session.async_activate()
    await app.async_activate()
    print("No empty session found, creating new tab")
    return


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] != "":
        input = sys.argv[1]
        if input[-1] != "\n":
            input += "\n"
    iterm2.run_until_complete(lambda connection: run_command(connection, input))
