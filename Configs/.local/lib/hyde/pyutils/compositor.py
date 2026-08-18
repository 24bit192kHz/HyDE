import os
import json
import socket as _socket
from typing import Union, Any


class HyprctlWrapper:
    @staticmethod
    def _socket_path() -> str:
        his = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
        if not his:
            raise EnvironmentError(
                "HYPRLAND_INSTANCE_SIGNATURE is not set. Is Hyprland running?"
            )
        runtime_dir = os.getenv("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
        return os.path.join(runtime_dir, "hypr", his, ".socket.sock")

    @staticmethod
    def _send(command: str) -> str:
        """Send a command to the Hyprland IPC socket and return the response.

        Format: [flags]/command args  (e.g. 'j/getoption decoration:rounding')
        The socket is opened immediately before the request and closed right after,
        as required by Hyprland's synchronous socket model.
        """
        with _socket.socket(_socket.AF_UNIX, _socket.SOCK_STREAM) as sock:
            sock.connect(HyprctlWrapper._socket_path())
            sock.sendall(command.encode())
            sock.shutdown(_socket.SHUT_WR)
            chunks = []
            while chunk := sock.recv(4096):
                chunks.append(chunk)
        return b"".join(chunks).decode()

    @staticmethod
    def getoption(option: str, get_set: bool = False) -> Union[int, str, bool, Any]:
        """
        Get a Hyprland option value via the IPC socket.

        Args:
            option: Option name (e.g., 'decoration:rounding')
            get_set: If True, returns the 'set' value instead of the actual value

        Returns:
            The option value or set status depending on get_set parameter
        """
        output = HyprctlWrapper._send(f"j/getoption {option}")

        try:
            data = json.loads(output)
            if get_set:
                return data.get("set", False)

            # Try to get the value in order of preference
            for key in ["int", "float", "str", "bool"]:
                if key in data:
                    return data[key]

            return None

        except json.JSONDecodeError:
            raise ValueError(f"Failed to parse hyprctl output: {output}")

    @staticmethod
    def get_rofi_override_string() -> str:
        """
        Generate the rofi override string based on hyprctl options and environment variables.

        Returns:
            The formatted rofi override string.
        """
        font_scale = os.getenv("ROFI_CLIPHIST_SCALE", os.getenv("ROFI_SCALE", "10"))
        font_name = os.getenv("ROFI_CLIPHIST_FONT", os.getenv("ROFI_FONT"))
        # if not font_name:
        #     font_name = HyprctlWrapper.getoption("general:font_name")
        font_name = font_name or "JetBrainsMono Nerd Font"

        hypr_border = HyprctlWrapper.getoption("decoration:rounding")
        wind_border = hypr_border * 3 // 2 if hypr_border else 5
        elem_border = hypr_border if hypr_border else 5

        hypr_width = HyprctlWrapper.getoption("general:border_size")

        font_override = f'* {{font: "{font_name} {font_scale}";}}'
        r_override = (
            f"window{{border:{hypr_width}px;border-radius:{wind_border}px;}}"
            f"wallbox{{border-radius:{elem_border}px;}}"
            f"element{{border-radius:{elem_border}px;}}"
        )

        return f"{font_override} {r_override}"

    @staticmethod
    def get_rofi_pos() -> str:
        """
        Get the rofi position based on the cursor position and monitor configuration.

        Returns:
            The formatted rofi position string.
        """
        cursor_pos = json.loads(HyprctlWrapper._send("j/cursorpos"))
        monitors = json.loads(HyprctlWrapper._send("j/monitors"))

        def logical(mon):
            w, h = mon["width"], mon["height"]
            if int(mon.get("transform") or 0) % 2:
                w, h = h, w
            return w, h, mon["x"], mon["y"], mon.get("reserved") or [0, 0, 0, 0], mon["name"]

        cx, cy = cursor_pos["x"], cursor_pos["y"]
        chosen = None
        for monitor in monitors:
            w, h, mx, my, reserved, name = logical(monitor)
            if mx <= cx < mx + w and my <= cy < my + h:
                chosen = (w, h, mx, my, reserved, name, monitor["scale"])
                break
        if chosen is None:
            focused = next((m for m in monitors if m.get("focused")), None)
            if not focused:
                raise RuntimeError("No focused monitor found.")
            w, h, mx, my, reserved, name = logical(focused)
            chosen = (w, h, mx, my, reserved, name, focused["scale"])

        w, h, mx, my, off_res, name, scale = chosen
        scale_pct = int(float(scale) * 100 + 0.5) or 100
        w = w * 100 // scale_pct
        h = h * 100 // scale_pct
        rel_x = min(max(cx - mx, 0), w)
        rel_y = min(max(cy - my, 0), h)
        lft, top, rgt, bot = (off_res + [0, 0, 0, 0])[:4]

        if rel_x >= w // 2:
            x_pos, x_off = "east", rel_x - w + rgt
        else:
            x_pos, x_off = "west", rel_x - lft
        if rel_y >= h // 2:
            y_pos, y_off = "south", rel_y - h + bot
        else:
            y_pos, y_off = "north", rel_y - top

        return (
            f'configuration{{monitor:"{name}";}}'
            f"window{{location:{x_pos} {y_pos};"
            f"anchor:{x_pos} {y_pos};"
            f"x-offset:{int(x_off)}px;"
            f"y-offset:{int(y_off)}px;}}"
        )

    @staticmethod
    def is_hovered() -> bool:
        """
        Check if the cursor is hovered on a window.

        Returns:
            True if the cursor is hovered on a window, False otherwise.
        """
        cursor_pos = json.loads(HyprctlWrapper._send("j/cursorpos"))
        active_window = json.loads(HyprctlWrapper._send("j/activewindow"))

        cursor_x = cursor_pos.get("x", 0)
        cursor_y = cursor_pos.get("y", 0)
        window_x = active_window.get("at", [0, 0])[0]
        window_y = active_window.get("at", [0, 0])[1]
        window_size_x = active_window.get("size", [0, 0])[0]
        window_size_y = active_window.get("size", [0, 0])[1]

        if (
            window_x <= cursor_x <= window_x + window_size_x
            and window_y <= cursor_y <= window_y + window_size_y
        ):
            return True
        return False
