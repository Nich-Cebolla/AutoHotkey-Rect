
#include Rect.ahk

PtCursorPosToString(Pt) {
    DllCall(g_user32_GetCursorPos, 'ptr', pt, 'int')
    return '( ' Pt.X ', ' Pt.Y ' )'
}
PtGetCursorPos(pt) => DllCall(g_user32_GetCursorPos, 'ptr', pt, 'int')
PtGetDpi(pt) {
    if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_user32_MonitorFromPoint, 'int', pt.Value, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError('MonitorFomPoint received an invalid parameter.')
    } else {
        return DpiX
    }
}
PtGetMonitor(pt) {
    return DllCall(g_user32_MonitorFromPoint, 'int', pt.Value, 'uint', 0, 'ptr')
}
PtGetValue(Pt) => (pt.X & 0xFFFFFFFF) | (pt.Y << 32)
PtLogicalToPhysicalPoint(pt, Hwnd) {
    DllCall(g_user32_LogicalToPhysicalPoint, 'ptr', Hwnd, 'ptr', pt)
}
PtLogicalToPhysicalForPerMonitorDPI(pt, Hwnd) {
    return DllCall(g_user32_LogicalToPhysicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', pt, 'int')
}
PtPhysicalToLogicalPoint(pt, Hwnd) {
    DllCall(g_user32_PhysicalToLogicalPoint, 'ptr', Hwnd, 'ptr', pt)
}
PtPhysicalToLogicalForPerMonitorDPI(pt, Hwnd) {
    return DllCall(g_user32_PhysicalToLogicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', pt, 'int')
}
PtSetCaretPos(pt) {
    return DllCall(g_user32_SetCaretPos, 'int', pt.X, 'int', pt.Y, 'int')
}
/**
 * @description - Use this to convert screen coordinates (which should already be contained by
 * this {@link Point} object), to client coordinates.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
 * @param {Point} pt - The point.
 * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Point}
 */
PtScreenToClient(pt, Hwnd, InPlace := false) {
    if !InPlace {
        pt := Point(pt.X, pt.Y)
    }
    if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', pt, 'int') {
        throw OSError()
    }
    return pt
}
/**
 * @description - Use this to convert client coordinates (which should already be contained by
 * this {@link Point} object), to screen coordinates.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
 * @param {Point} pt - The point.
 * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Point}
 */
PtClientToScreen(Pt, Hwnd, InPlace := false) {
    if !InPlace {
        pt := Point(pt.X, pt.Y)
    }
    if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', pt, 'int') {
        throw OSError()
    }
    return pt
}
PtToString(Pt) {
    return '( ' Pt.X ', ' Pt.Y ' )'
}

RectEqual(rc1, rc2) => DllCall(g_user32_EqualRect, 'ptr', rc1, 'ptr', rc2, 'int')
RectGetCoordinate(Offset, rc) => NumGet(rc, Offset, 'int')
RectGetDpi(rc) {
    if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_shcore_MonitorFromRect, 'ptr', rc, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError('``MonitorFomPoint`` received an invalid parameter.')
    } else {
        return DpiX
    }
}
RectGetHeightSegment(rc, Divisor, DecimalPlaces := 0) => Round(rc.H / Divisor, DecimalPlaces)
RectGetLength(Offset, rc) => NumGet(rc, 8 + Offset, 'int') - NumGet(rc, Offset, 'int')
RectGetMonitor(rc) => DllCall(g_user32_MonitorFromRect, 'ptr', rc, 'UInt', 0, 'Uptr')
RectGetPoint(Offset1, Offset2, rc) => Point(NumGet(rc, Offset1, 'int'), NumGet(rc, Offset2, 'int'))
RectGetWidthSegment(rc, Divisor, DecimalPlaces := 0) => Round(rc.W / Divisor, DecimalPlaces)
RectInflate(rc, dx, dy) => DllCall(g_user32_InflateRect, 'ptr', rc, 'int', dx, 'int', dy, 'int')
/**
 * @returns {Rect} - If the rectangles intersect, a new `Rect` object is returned. If the rectangles
 * do not intersect, returns an empty string.
 */
RectIntersect(rc1, rc2, Offset := 0) {
    rc := Rect()
    if DllCall(g_user32_IntersectRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int') {
        return rc
    }
}
RectIsEmpty(rc) => DllCall(g_user32_IsRectEmpty, 'ptr', rc, 'int')
/**
 * @description - Calculates the optimal position to move one rectangle adjacent to another while
 * ensuring that the `Subject` rectangle stays within the monitor's work area. The properties
 * { L, T, R, B } of `Subject` are updated with the new values.
 *
 * @example
 * ; Assume I have Edge and VLC open
 * rcSub := WinRect(WinGetId("ahk_exe msedge.exe"))
 * rcTar := WinRect(WinGetId("ahk_exe vlc.exe"))
 * rcSub.MoveAdjacent(rcTar)
 * rcSub.Apply()
 * @
 *
 * @param {*} Subject - The object representing the rectangle that will be moved. This can be an
 * instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. Those four property values will be updated with the result of this function call.
 *
 * @param {*} [Target] - The object representing the rectangle that will be used as reference. This
 * can be an instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. If unset, the mouse's current position relative to the screen is used. To use
 * a point instead of a rectangle, set the properties "L" and "R" equivalent to one another, and
 * "T" and "B" equivalent to one another.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the rectangle is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, the work area of the monitor with the greatest area of
 * intersection with `Target` is used.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the rectangle is to be moved
 * adjacent to `Target` on either the X or Y axis. If "X", `Subject` is moved to the left or right
 * of `Target`, and `Subject`'s vertical center is aligned with `Target`'s vertical center. If "Y",
 * `Subject` is moved to the top or bottom of `Target`, and `Subject`'s horizontal center is aligned
 * with `Target`'s horizontal center.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the rectangle to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the rectangle will be moved to that side unless doing so would cause the the rectangle to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between `Subject` and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the rectangle adjacent to `Target` while also keeping the rectangle
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the rectangle to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the rectangle.
 * - 1 : The function will move the rectangle, allowing the rectangle's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the rectangle, keeping the rectangle's area within the monitor's work
 *   area by allowing the rectangle to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
RectMoveAdjacent(Subject, Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
    Result := 0
    if IsSet(Target) {
        tarL := Target.L
        tarT := Target.T
        tarR := Target.R
        tarB := Target.B
    } else {
        mode := CoordMode('Mouse', 'Screen')
        MouseGetPos(&tarL, &tarT)
        tarR := tarL
        tarB := tarT
        CoordMode('Mouse', mode)
    }
    tarW := tarR - tarL
    tarH := tarB - tarT
    if IsSet(ContainerRect) {
        monL := ContainerRect.L
        monT := ContainerRect.T
        monR := ContainerRect.R
        monB := ContainerRect.B
        monW := monR - monL
        monH := monB - monT
    } else {
        buf := Buffer(16)
        NumPut('int', tarL, 'int', tarT, 'int', tarR, 'int', tarB, buf)
        Hmon := DllCall('MonitorFromRect', 'ptr', buf, 'uint', 0x00000002, 'ptr')
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        monL := NumGet(mon, 20, 'int')
        monT := NumGet(mon, 24, 'int')
        monR := NumGet(mon, 28, 'int')
        monB := NumGet(mon, 32, 'int')
        monW := monR - monL
        monH := monB - monT
    }
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
    subW := subR - subL
    subH := subB - subT
    if Dimension = 'X' {
        if Prefer = 'L' {
            if tarL - subW - Padding >= monL {
                X := tarL - subW - Padding
            } else if tarL - subW >= monL {
                X := monL
            }
        } else if Prefer = 'R' {
            if tarR + subW + Padding <= monR {
                X := tarR + Padding
            } else if tarR + subW <= monR {
                X := monR - subW
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(X) {
            flag_nomove := false
            X := _Proc(subW, tarL, tarR, monL, monR)
            if flag_nomove {
                return Result
            }
        }
        Y := tarT + tarH / 2 - subH / 2
        if Y + subH > monB {
            Y := monB - subH
        } else if Y < monT {
            Y := monT
        }
    } else if Dimension = 'Y' {
        if Prefer = 'T' {
            if tarT - subH - Padding >= monT {
                Y := tarT - subH - Padding
            } else if tarT - subH >= monT {
                Y := monT
            }
        } else if Prefer = 'B' {
            if tarB + subH + Padding <= monB {
                Y := tarB + Padding
            } else if tarB + subH <= monB {
                Y := monB - subH
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(Y) {
            flag_nomove := false
            Y := _Proc(subH, tarT, tarB, monT, monB)
            if flag_nomove {
                return Result
            }
        }
        X := tarL + tarW / 2 - subW / 2
        if X + subW > monR {
            X := monR - subW
        } else if X < monL {
            X := monL
        }
    } else {
        throw _ValueError('Dimension', Dimension)
    }
    Subject.L := X
    Subject.T := Y
    Subject.R := X + subW
    Subject.B := Y + subH

    return Result

    _Proc(SubLen, TarMainSide, TarAltSide, MonMainSide, MonAltSide) {
        if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
            if TarMainSide - SubLen - Padding >= MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if TarMainSide - SubLen >= MonMainSide {
                return MonMainSide + TarMainSide - SubLen
            } else {
                Result := 1
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarMainSide - SubLen
                    case 2: return MonMainSide
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        } else if TarAltSide + SubLen + Padding <= MonAltSide {
            return TarAltSide + Padding
        } else if TarAltSide + SubLen <= MonAltSide {
            return MonAltSide - TarAltSide + SubLen
        } else {
            Result := 1
            switch InsufficientSpaceAction, 0 {
                case 0: flag_nomove := true
                case 1: return TarAltSide
                case 2: return MonAltSide - SubLen
                default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
            }
        }
    }
    _ValueError(name, Value) {
        if IsObject(Value) {
            return TypeError('Invalid type passed to ``' name '``.')
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', , Value)
        }
    }
}
RectOffset(rc, dx, dy) => DllCall(g_user32_OffsetRect, 'ptr', rc, 'int', dx, 'int', dy, 'int')
RectPtIn(rc, pt) => DllCall(g_user32_PtInRect, 'ptr', rc, 'ptr', pt, 'int')
RectSet(rc, X?, Y?, W?, H?) {
    if IsSet(X) {
        rc.L := X
    }
    if IsSet(Y) {
        rc.T := Y
    }
    if IsSet(W) {
        rc.R := rc.L + W
    }
    if IsSet(H) {
        rc.B := rc.T + H
    }
}
RectSetCoordinate(Offset, rc, Value) => NumPut('int', Value, rc.Ptr, Offset)
RectSetLength(Offset, rc, Value) => NumPut('int', NumGet(rc, Offset, 'int') + Value, rc, 8 + Offset)
RectSubtract(rc1, rc2) {
    rc := Rect()
    DllCall(g_user32_SubtractRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int')
    return rc
}
/**
 * Calls `ScreenToClient` for the the rectangle.
 * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
 * will be made relative.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Rect}
 */
RectToClient(rc, Hwnd, InPlace := false) {
    if !InPlace {
        rc := rc.Clone()
    }
    if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc, 'int') {
        throw OSError()
    }
    if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc.Ptr + 8, 'int') {
        throw OSError()
    }
    return rc
}
/**
 * Calls `ClientToScreen` for the the rectangle.
 * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
 * are currently relative.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Rect}
 */
RectToScreen(rc, Hwnd, InPlace := false) {
    if !InPlace {
        rc := rc.Clone()
    }
    if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr, 'int') {
        throw OSError()
    }
    if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
        throw OSError()
    }
    return rc
}
RectToString(rc, DimensionLen := '-6') {
    return (
        'TL: ' Format('( {}, {} )', rc.L, rc.T)
        '`r`nBR: ' Format('( {}, {} )', rc.R, rc.B)
        '`r`nW: ' Format('{:' DimensionLen '}', rc.W) '  H: ' Format('{:' DimensionLen '}', rc.H)
    )
}
RectToStringDeconstructed(rc, DimensionLen := '-6') {
    return {
        TL: Format('( {}, {} )', rc.L, rc.T)
      , BR: Format('( {}, {} )', rc.R, rc.B)
      , W: Format('{:' DimensionLen '}', rc.W)
      , H: Format('{:' DimensionLen '}', rc.H)
    }
}
/**
 * @returns {Rect} - If the specified structure contains a nonempty rectangle, a new `Rect` is created
 * and retured. If the specified structure does not contain a nonempty rectangle, returns an empty
 * string.
 */
RectUnion(rc1, rc2) {
    rc := Rect()
    if DllCall(g_user32_UnionRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int') {
        return rc
    }
}
SetCaretPos(X, Y) {
    return DllCall(g_user32_SetCaretPos, 'int', X, 'int', Y, 'int')
}

/**
 * @description - Input the desired client area and `AdjustWindowRectEx` will update the object
 * on the property `Rect` to the position and size that will accommodate the client area. This
 * does not update the window's display; call `Window32Obj.Rect.Apply()`
 */
Window32AdjustRectEx(win, X?, Y?, W?, H?, HasMenuBar := false) {
    rc := win.Rect
    if IsSet(X) {
        rc.X := X
    }
    if IsSet(Y) {
        rc.Y := Y
    }
    if IsSet(W) {
        rc.R := rc.X + W
    }
    if IsSet(H) {
        rc.B := rc.T + H
    }
    if !DllCall(g_user32_AdjustWindowRectEx, 'ptr', rc, 'uint', win.Style, 'int', HasMenuBar, 'uint', win.ExStyle, 'int') {
        throw OSError()
    }
}

Window32BringToTop(win) {
    return DllCall(g_user32_BringWindowToTop, 'ptr', IsObject(win) ? win.Hwnd : win, 'int')
}
Window32CallbackFromDesktop(*) {
    if hwnd := DllCall(g_user32_GetDesktopWindow, 'ptr') {
        return hwnd
    }
}
Window32CallbackFromForeground(*) {
    return DllCall(g_user32_GetForegroundWindow, 'ptr')
}
/**
 * @description - To use this as a callback with `Window32.Prototype.SetCallback`, you must
 * define it as a `BoundFunc` defining the "Cmd" value.
 * @example
 *  hwnd := DllCall(g_user32_GetDesktopWindow, 'ptr')
 *  win := Window32(hwnd)
 *  win.SetCallback(Window32CallbackFromNext.Bind(3))
 *  win()
 * @
 */
Window32CallbackFromNext(Cmd, win) {
    if hwnd := DllCall(g_user32_GetNextWindow, 'ptr', win.Hwnd, 'uint', Cmd, 'ptr') {
        return hwnd
    }
}
Window32CallbackFromParent(win) {
    if hwnd := DllCall(g_user32_GetParent, 'ptr', win.Hwnd, 'ptr') {
        return hwnd
    }
}
Window32CallbackFromShell(*) {
    return DllCall(g_user32_GetShellWindow, 'ptr')
}
Window32CallbackFromTop(win) {
    return DllCall(g_user32_GetTopWindow, 'ptr', win.Hwnd, 'ptr')
}
Window32ChildFromPoint(win, X, Y) {
    return DllCall(g_user32_ChildWindowFromPoint, 'ptr', IsObject(win) ? win.Hwnd : win, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
/**
 * @param {Integer} [flag = 0] -
 * - CWP_ALL - 0x0000 : Does not skip any child windows
 * - CWP_SKIPDISABLED - 0x0002 : Skips disabled child windows
 * - CWP_SKIPINVISIBLE - 0x0001 : Skips invisible child windows
 * - CWP_SKIPTRANSPARENT - 0x0004 : Skips transparent child windows
 */
Window32ChildFromPointEx(win, X, Y, Flag := 0) {
    return DllCall(g_user32_ChildWindowFromPointEx, 'ptr', IsObject(win) ? win.Hwnd : win, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', Flag, 'ptr')
}
Window32EnumChildWindows(win, Callback, lParam := 0) {
    cb := CallbackCreate(Callback, 'fast', 1)
    result := DllCall(g_user32_EnumChildWindows, 'ptr', IsObject(win) ? win.Hwnd : win, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}
/**
 * @description - Gets the bounding rectangle of all child windows of a given window.
 * @param {Integer} Hwnd - The handle to the parent window.
 * @returns {Rect} - The bounding rectangle of all child windows, specifically the smallest
 * rectangle that contains all child windows.
 */
Window32GetChildBoundingRect(win) {
    rects := [Rect(), Rect(), Rect()]
    cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1)
    DllCall(g_user32_EnumChildWindows, 'ptr', IsObject(win) ? win.Hwnd : win, 'ptr', cb, 'int', 0, 'int')
    CallbackFree(cb)
    return rects[1]

    _EnumChildWindowsProc(hwnd) {
        DllCall(g_user32_GetWindowRect, 'ptr', Hwnd, 'ptr', rects[3], 'int')
        DllCall(g_user32_UnionRect, 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
        rects.Push(rects.RemoveAt(1))
        return 1
    }
}
Window32GetClientRect(win) {
    return WinRect(IsObject(win) ? win.Hwnd : win, true)
}
Window32GetDpi(win) {
    return DllCall(g_user32_GetDpiForWindow, 'ptr', IsObject(win) ? win.Hwnd : win, 'int')
}
Window32GetMonitor(win) {
    return DllCall(g_user32_MonitorFromWindow, 'ptr', IsObject(win) ? win.Hwnd : win, 'int', 0, 'ptr')
}
/**
 * @param {String|Integer} Id - The extended style value.
 * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles}.
 */
Window32HasExStyle(win, Id) {
    return win.ExStyle & Id
}
/**
 * @param {String|Integer} Id - The style value.
 * {@link https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles}.
 */
Window32HasStyle(win, Id) {
    return win.Style & Id
}
Window32IsChild(win, HwndChild) {
    return DllCall(g_user32_IsChild, 'ptr', IsObject(win) ? win.Hwnd : win, 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'int')
}
Window32IsParent(win, HwndParent) {
    return DllCall(g_user32_IsChild, 'ptr', HwndParent, 'ptr', IsObject(win) ? win.Hwnd : win, 'int')
}
Window32IsVisible(wrc) {
    return DllCall(g_user32_IsWindowVisible, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
Window32RealChildFromPoint(win, X, Y) {
    return DllCall(g_user32_RealChildWindowFromPoint, 'ptr', IsObject(win) ? win.Hwnd : win, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
Window32SetActive(win) {
    return DllCall(g_user32_SetActiveWindow, 'ptr', IsObject(win) ? win.Hwnd : win, 'int')
}
Window32SetForeground(win) {
    return DllCall(g_user32_SetForegroundWindow, 'ptr', IsObject(win) ? win.Hwnd : win, 'int')
}
Window32SetParent(win, HwndNewParent := 0) {
    return DllCall(g_user32_SetParent, 'ptr', IsObject(win) ? win.Hwnd : win, 'ptr', IsObject(HwndNewParent) ? HwndNewParent.Hwnd : HwndNewParent, 'ptr')
}
Window32SetPosKeepAspectRatio(win, Width, Height, AspectRatio?) {
    if !IsSet(AspectRatio) {
        AspectRatio := win.W / win.H
    }
    WidthFromHeight := Height / AspectRatio
    HeightFromWidth := Width * AspectRatio
    if WidthFromHeight > Width {
        win.H := HeightFromWidth
        win.W := Width
    } else {
        win.W := WidthFromHeight
        win.H := Height
    }
}
/**
 * @description - Shows the window.
 * @param {Integer} [Flag = 0] - One of the following.
 * - SW_HIDE - 0 - Hides the window and activates another window.
 * - SW_SHOWNORMAL / SW_NORMAL - 1 - Activates and displays a window. If the window is
 *   minimized, maximized, or arranged, the system restores it to its original size and position.
 *   An application should specify this flag when displaying the window for the first time.
 * - SW_SHOWMINIMIZED - 2 - Activates the window and displays it as a minimized window.
 * - SW_SHOWMAXIMIZED / SW_MAXIMIZE - 3 - Activates the window and displays it as a maximized
 *   window.
 * - SW_SHOWNOACTIVATE - 4 - Displays a window in its most recent size and position. This value
 *   is similar to SW_SHOWNORMAL, except that the window is not activated.
 * - SW_SHOW - 5 - Activates the window and displays it in its current size and position.
 * - SW_MINIMIZE - 6 - Minimizes the specified window and activates the next top-level window in
 *   the Z order.
 * - SW_SHOWMINNOACTIVE - 7 - Displays the window as a minimized window. This value is similar
 *   to SW_SHOWMINIMIZED, except the window is not activated.
 * - SW_SHOWNA - 8 - Displays the window in its current size and position. This value is similar
 *   to SW_SHOW, except that the window is not activated.
 * - SW_RESTORE - 9 - Activates and displays the window. If the window is minimized, maximized,
 *   or arranged, the system restores it to its original size and position. An application should
 *   specify this flag when restoring a minimized window.
 * - SW_SHOWDEFAULT - 10 - Sets the show state based on the SW_ value specified
 *   in the structure passed to the function by the program that started the application.
 * - SW_FORCEMINIMIZE - 11 - Minimizes a window, even if the thread that owns the window is not
 *   responding. This flag should only be used when minimizing windows from a different thread.
 * @returns {Boolean} - If the window was previously visible, the return value is nonzero. If
 * the window was previously hidden, the return value is zero.
 */
Window32Show(win, Flag := 9) {
    return DllCall(g_user32_ShowWindow, 'ptr', IsObject(win) ? win.Hwnd : win, 'uint', Flag, 'int')
}

WinFromDesktop() {
    return DllCall(g_user32_GetDesktopWindow, 'ptr')
}
WinFromForeground() {
    return DllCall(g_user32_GetForegroundWindow, 'ptr')
}
WinFromCursor() {
    return DllCall(g_user32_WindowFromPoint, 'int', Point.FromCursor().Value, 'ptr')
}
WinFromParent(Hwnd) {
    return DllCall(g_user32_GetParent, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}
WinFromPoint(X, Y) {
    return DllCall(g_user32_WindowFromPoint, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
WinFromShell() {
    return DllCall(g_user32_GetShellWindow, 'ptr')
}
WinFromTop(Hwnd := 0) {
    return DllCall(g_user32_GetTopWindow, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr')
}
/**
 * @param Cmd -
 * - GW_CHILD - 5 - The retrieved handle identifies the child window at the top of the Z order,
 *  if the specified window is a parent window; otherwise, the retrieved handle is NULL. The
 *  function examines only child windows of the specified window. It does not examine descendant
 *  windows.
 *
 * - GW_ENABLEDPOPUP - 6 - The retrieved handle identifies the enabled popup window owned by the
 *  specified window (the search uses the first such window found using GW_HwndNEXT); otherwise,
 *  if there are no enabled popup windows, the retrieved handle is that of the specified window.
 *
 * - GW_HwndFIRST - 0 - The retrieved handle identifies the window of the same type that is highest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndLAST - 1 - The retrieved handle identifies the window of the same type that is lowest
 *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level window.
 *  If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndNEXT - 2 - The retrieved handle identifies the window below the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_HwndPREV - 3 - The retrieved handle identifies the window above the specified window in
 *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
 *  window. If the specified window is a top-level window, the handle identifies a top-level
 *  window. If the specified window is a child window, the handle identifies a sibling window.
 *
 * - GW_OWNER - 4 - The retrieved handle identifies the specified window's owner window, if any.
 *  For more information, see Owned Windows.
 */
WinGet(Hwnd, Cmd) {
    return DllCall(g_user32_GetWindow, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr')
}
WinRectMapPoints(wrc1, wrc2, points) {
    return DllCall(g_user32_MapWindowPoints, 'ptr', IsObject(wrc1) ? wrc1.Hwnd : wrc1, 'ptr', IsObject(wrc2) ? wrc2.Hwnd : wrc2, 'ptr', points, 'uint', points.Size / 8, 'int')
}

/**
 * @description - Reorders the objects in an array according to the input options.
 * @example
 * List := [
 *     { L: 100, T: 100, Name: 1 }
 *   , { L: 100, T: 150, Name: 2 }
 *   , { L: 200, T: 100, Name: 3 }
 *   , { L: 200, T: 150, Name: 4 }
 * ]
 * OrderRects(List, L2R := true, T2B := true, 'H')
 * OutputDebug(_GetOrder() "`n") ; 1 2 3 4
 * OrderRects(List, L2R := true, T2B := true, 'V')
 * OutputDebug(_GetOrder() "`n") ; 1 3 2 4
 * OrderRects(List, L2R := false, T2B := true, 'H')
 * OutputDebug(_GetOrder() "`n") ; 3 4 1 2
 * OrderRects(List, L2R := false, T2B := false, 'H')
 * OutputDebug(_GetOrder() "`n") ; 4 3 2 1
 *
 * _GetOrder() {
 *     for item in List {
 *         Str .= item.Name ' '
 *     }
 *     return Trim(Str, ' ')
 * }
 * @
 * @param {Array} List - The array containing the objects to be ordered.
 * @param {String} [Primary = "X"] - Determines which axis is primarily considered when ordering
 * the objects. When comparing two objects, if their positions along the Primary axis are
 * equal, then the alternate axis is compared and used to break the tie. Otherwise, the alternate
 * axis is ignored for that pair.
 * - X: Check horizontal first.
 * - Y: Check vertical first.
 * @param {Boolean} [LeftToRight = true] - If true, the objects are ordered in ascending order
 * along the X axis when the X axis is compared.
 * @param {Boolean} [TopToBottom = true] - If true, the objects are ordered in ascending order
 * along the Y axis when the Y axis is compared.
 */
OrderRects(List, Primary := 'X', LeftToRight := true, TopToBottom := true) {
    ConditionH := LeftToRight ? (a, b) => a.L < b.L : (a, b) => a.L > b.L
    ConditionV := TopToBottom ? (a, b) => a.T < b.T : (a, b) => a.T > b.T
    if Primary = 'X' {
        _InsertionSort(List, _ConditionFnH)
    } else if Primary = 'Y' {
        _InsertionSort(List, _ConditionFnV)
    } else {
        throw ValueError('Unexpected ``Primary`` value.', , Primary)
    }

    return List

    _InsertionSort(Arr, CompareFn) {
        i := 1
        loop Arr.Length - 1 {
            Current := Arr[++i]
            j := i - 1
            loop j {
                if CompareFn(Arr[j], Current) < 0
                    break
                Arr[j + 1] := Arr[j--]
            }
            Arr[j + 1] := Current
        }
    }
    _ConditionFnH(a, b) {
        if a.L == b.L {
            if ConditionV(a, b) {
                return -1
            }
        } else if ConditionH(a, b) {
            return -1
        }
        return 1
    }
    _ConditionFnV(a, b) {
        if a.T == b.T {
            if ConditionH(a, b) {
                return -1
            }
        } else if ConditionV(a, b) {
            return -1
        }
        return 1
    }
}
