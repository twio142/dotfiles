#!/usr/bin/env python3

import iterm2
import asyncio

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async def still_running(session, jobPid):
        if not jobPid:
            return False
        session = app.get_session_by_id(session_id)
        if not session:
            return False
        return jobPid == await session.async_get_variable("jobPid")

    async def notify(session, commandLine=""):
        await session.async_activate()
        alert = iterm2.Alert("Job finished", commandLine, session.window.window_id)
        await alert.async_run(connection)

    window = app.current_window
    if window is not None:
        tab = window.current_tab
        if tab is not None:
            session = tab.current_session
            if session is not None:
                commandLine = await session.async_get_variable("commandLine")
                if commandLine == "-zsh":
                    return
                jobPid = await session.async_get_variable("jobPid")
                session_id = session.session_id
                while True:
                    await asyncio.sleep(5)
                    if not await still_running(session, jobPid):
                        await notify(session, commandLine)
                        break

iterm2.run_until_complete(main)
