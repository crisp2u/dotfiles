#!/usr/bin/env python3

import asyncio
import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)
    new_tab = await app.current_terminal_window.async_create_tab()
    await new_tab.async_activate()
    await new_tab.async_set_variable("user.title", "🍁 release staging local")
    await new_tab.async_set_title("\\(user.title)")

    commands = [["bs", "ks"], ["sas", "bps"], ["jos", "zs"], ["lphs", "lids", "lmxs"]]

    tabs = [[None for _ in range(len(t))] for t in commands]

    # Create four split panes and make the bottom left one active.
    tabs[0][0] = app.current_terminal_window.current_tab.current_session
    tabs[1][0] = await tabs[0][0].async_split_pane(vertical=True)
    tabs[2][0] = await tabs[1][0].async_split_pane(vertical=True)
    tabs[3][0] = await tabs[2][0].async_split_pane(vertical=True)
    tabs[0][1] = await tabs[0][0].async_split_pane(vertical=False)
    tabs[1][1] = await tabs[1][0].async_split_pane(vertical=False)
    tabs[2][1] = await tabs[2][0].async_split_pane(vertical=False)
    tabs[3][1] = await tabs[3][0].async_split_pane(vertical=False)
    tabs[3][2] = await tabs[3][1].async_split_pane(vertical=False)

    # Change the size of the panels
    for col in tabs:
        for tab in col:
            tab.preferred_size = iterm2.util.Size(1400, 600)
    await app.current_terminal_window.current_tab.async_update_layout()

    for i, col in enumerate(tabs):
        for j, tab in enumerate(col):
            await tab.async_activate()
            await tab.async_send_text(f"cd workspace/maple\n")
            await tab.async_send_text(f"sl release {commands[i][j]} -d -l\n")


iterm2.run_until_complete(main)
