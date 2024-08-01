#!/usr/bin/env python3

import iterm2
import sys
from run_command import isEmpty


async def main(connection):
    if len(sys.argv) > 1 and sys.argv[1] != "":
        input = sys.argv[1]
        if input[-1] != "\n":
            input += "\n"
    else:
        input = ""
    app = await iterm2.async_get_app(connection)
    for window in app.windows:
        if await window.async_get_variable("titleOverrideFormat") != \
                "Hotkey Window":
            continue
        if window.current_tab:
            session = window.current_tab.current_session
            if not await isEmpty(session):
                raise Exception("Hotkey window is not empty")
        else:
            tab = await window.async_create_tab()
            session = tab.current_session
        await window.async_activate()
        await session.async_activate()
        await session.async_send_text(input)
        return

iterm2.run_until_complete(main)
