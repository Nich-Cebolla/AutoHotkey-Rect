
class Point {
    static __New() {
        this.DeleteProp('__New')
        Rect_SetConstants()
        this.Prototype.DefineProp('Clone', { Call: Rect_Clone })
    }
    /**
     * @description - Creates a {@link Point} object with the client position of the caret.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcaretpos}.
     * @returns {Point}
     */
    static FromCaret() {
        pt := this()
        DllCall(g_user32_GetCaretPos, 'ptr', pt, 'int')
        return pt
    }
    /**
     * @description - Creates a {@link Point} object with the cursor position in screen coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos}.
     * @returns {Point}
     */
    static FromCursor() {
        pt := this()
        DllCall(g_user32_GetCursorPos, 'ptr', pt, 'int')
        return pt
    }
    /**
     * @description - Creates a new {@link Point} object.
     * @param {Integer} [X] - The X-coordinate.
     * @param {Integer} [Y] - The Y-coordinate.
     */
    __New(X?, Y?) {
        this.Buffer := Buffer(8, 0)
        if IsSet(X) {
            this.X := X
        }
        if IsSet(Y) {
            this.Y := Y
        }
    }
    /**
     * @description - Use this to convert client coordinates (which should already be contained by
     * this {@link Point} object), to screen coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}.
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the current object is modified. If false, a new
     * {@link Point} is created.
     * @returns {Point}
     */
    ClientToScreen(Hwnd, InPlace := false) {
        if InPlace {
            pt := this
        } else {
            pt := Point(this.X, this.Y)
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @description - Creates a copy of the {@link Point} object. The buffer on property
     * {@link Point#Buffer} is different, so changes to one will not affect the other.
     */
    Clone() {
        ; this is overridden
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getcursorpos}.
     * @returns {Boolean} - True if successful.
     */
    GetCursorPos() => DllCall(g_user32_GetCursorPos, 'ptr', this, 'int')
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-logicaltophysicalpointforpermonitordpi}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * @returns {Boolean} - True if successful.
     */
    LogicalToPhysicalForPerMonitorDPI(Hwnd) {
        return DllCall(g_user32_LogicalToPhysicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', this, 'int')
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-logicaltophysicalpoint}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * Top level windows are fully supported. In the case of child windows, only the area of overlap
     * between the parent and the child window is converted.
     */
    LogicalToPhysicalPoint(Hwnd) {
        DllCall(g_user32_LogicalToPhysicalPoint, 'ptr', Hwnd, 'ptr', this)
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-physicaltologicalpointforpermonitordpi}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * @returns {Boolean} - True if successful.
     */
    PhysicalToLogicalForPerMonitorDPI(Hwnd) {
        return DllCall(g_user32_PhysicalToLogicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', this, 'int')
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-physicaltologicalpoint}.
     * @param {Integer} Hwnd - A handle to the window whose transform is used for the conversion.
     * Top level windows are fully supported. In the case of child windows, only the area of overlap
     * between the parent and the child window is converted.
     */
    PhysicalToLogicalPoint(Hwnd) {
        DllCall(g_user32_PhysicalToLogicalPoint, 'ptr', Hwnd, 'ptr', this)
    }
    /**
     * @description - Use this to convert screen coordinates (which should already be contained by
     * this {@link Point} object), to client coordinates.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
     * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
     * @param {Boolean} [InPlace = false] - If true, the current object is modified. If false, a new
     * {@link Point} is created.
     * @returns {Point}
     */
    ScreenToClient(Hwnd, InPlace := false) {
        if InPlace {
            pt := this
        } else {
            pt := Point(this.X, this.Y)
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', pt, 'int') {
            throw OSError()
        }
        return pt
    }
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setcaretpos}.
     * @returns {Boolean} - Nonzero if successful.
     */
    SetCaretPos() {
        return DllCall(g_user32_SetCaretPos, 'int', this.X, 'int', this.Y, 'int')
    }
    /**
     * @desc - Calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setcursorpos SetCursorPos}
     * using this object's {@link Point#x} and {@link Point#y} values.
     */
    SetCursorPos() {
        if !DllCall(g_user32_SetCursorPos, 'int', this.x, 'int', this.y, 'int') {
            throw OSError()
        }
    }

    /**
     * @returns {Integer} - The dpi of the monitor containing the point.
     */
    Dpi {
        Get {
            if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_user32_MonitorFromPoint, 'int', this.Value, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
                throw OSError('``MonitorFomPoint`` received an invalid parameter.')
            } else {
                return DpiX
            }
        }
    }
    /**
     * @returns {Integer} - The handle to the monitor that contains the point.
     */
    Monitor  => DllCall(g_user32_MonitorFromPoint, 'int', this.Value, 'uint', 0, 'ptr')
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    /**
     * @returns {Integer} - Returns a 64-bit value containing the x-coordinate in the low word and
     * the y-coordinate in the high word.
     */
    Value => (this.X & 0xFFFFFFFF) | (this.Y << 32)
    /**
     * @descriptions - Gets or sets the X coordinate value.
     * @returns {Integer}
     */
    X {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    /**
     * @descriptions - Gets or sets the Y coordinate value.
     * @returns {Integer}
     */
    Y {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}
class Rect {
    static __New() {
        this.DeleteProp('__New')
        Rect_SetConstants()
        this.Prototype.DefineProp('Clone', { Call: Rect_Clone })
    }
    static FromDimensions(X, Y, W, H) => this(X, Y, X + W, Y + H)
    static FromCursor() {
        rc := this()
        DllCall(g_user32_GetCursorPos, 'ptr', rc, 'int')
        rc.R := rc.L
        rc.B := rc.T
        return rc
    }
    static FromPtr(ptr) {
        rc := { buffer: { ptr: ptr, size: 16 } }
        rc.base := this.Prototype
        return rc
    }
    /**
     * @description - Creates a new {@link Rect} object.
     * @param {Integer} [L] - The left coordinate.
     * @param {Integer} [T] - The top coordinate.
     * @param {Integer} [R] - The right coordinate.
     * @param {Integer} [B] - The bottom coordinate.
     */
    __New(L?, T?, R?, B?) {
        this.Buffer := Buffer(16, 0)
        if IsSet(L) {
            this.L := L
        }
        if IsSet(T) {
            this.T := T
        }
        if IsSet(R) {
            this.R := R
        }
        if IsSet(B) {
            this.B := B
        }
    }
    Clone() {
        ; this is overridden
    }
    Equal(rc) => DllCall(g_user32_EqualRect, 'ptr', this, 'ptr', rc, 'int')
    GetHeightSegment(Divisor, DecimalPlaces := 0) => Round(this.H / Divisor, DecimalPlaces)
    GetWidthSegment(Divisor, DecimalPlaces := 0) => Round(this.W / Divisor, DecimalPlaces)
    Inflate(dx, dy) => DllCall(g_user32_InflateRect, 'ptr', this, 'int', dx, 'int', dy, 'int')
    Intersect(rc) {
        out := Rect()
        if DllCall(g_user32_IntersectRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int') {
            return out
        }
    }
    IsEmpty() => DllCall(g_user32_IsRectEmpty, 'ptr', this, 'int')
    MoveAdjacent(Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
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
        subL := this.L
        subT := this.T
        subR := this.R
        subB := this.B
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
        this.L := X
        this.T := Y
        this.R := X + subW
        this.B := Y + subH

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
    Offset(dx, dy) => DllCall(g_user32_OffsetRect, 'ptr', this, 'int', dx, 'int', dy, 'int')
    PtIn(pt) => DllCall(g_user32_PtInRect, 'ptr', this, 'ptr', pt, 'int')
    Set(X?, Y?, W?, H?) {
        if IsSet(X) {
            this.L := X
        }
        if IsSet(Y) {
            this.T := Y
        }
        if IsSet(W) {
            this.R := this.L + W
        }
        if IsSet(H) {
            this.B := this.T + H
        }
    }
    Subtract(rc) {
        out := Rect()
        DllCall(g_user32_SubtractRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int')
        return out
    }
    ToClient(Hwnd, InPlace := false) {
        if InPlace {
            rc := this
        } else {
            rc := this.Clone()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ScreenToClient, 'ptr', Hwnd, 'ptr', rc.Ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    ToScreen(Hwnd, InPlace := false) {
        if InPlace {
            rc := this
        } else {
            rc := this.Clone()
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
            throw OSError()
        }
        return rc
    }
    Union(rc) {
        out := Rect()
        if DllCall(g_user32_UnionRect, 'ptr', out, 'ptr', this, 'ptr', rc, 'int') {
            return out
        }
    }

    B {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    BL => Point(NumGet(this, 0, 'int'), NumGet(this, 12, 'int'))
    BR => Point(NumGet(this, 8, 'int'), NumGet(this, 12, 'int'))
    Dpi {
        Get {
            if DllCall(g_shcore_GetDpiForMonitor, 'ptr', DllCall(g_user32_MonitorFromRect, 'ptr', this, 'uint', 0, 'ptr'), 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
                throw OSError('``MonitorFomPoint`` received an invalid parameter.')
            } else {
                return DpiX
            }
        }
    }
    H {
        Get => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
        Set => NumPut('int', NumGet(this, 4, 'int') + Value, this, 12)
    }
    L {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this)
    }
    Monitor => DllCall(g_user32_MonitorFromRect, 'ptr', this, 'uint', 0, 'uptr')
    Ptr => this.Buffer.Ptr
    R {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    Size => this.Buffer.Size
    T {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    TL {
        Get => Point(NumGet(this, 0, 'int'), NumGet(this, 4, 'int'))
    }
    TR {
        Get => Point(NumGet(this, 8, 'int'), NumGet(this, 4, 'int'))
    }
    W {
        Get => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
        Set => NumPut('int', NumGet(this, 0, 'int') + Value, this, 8)
    }
}
class Window32 {
    static __New() {
        this.DeleteProp('__New')
        Rect_SetConstants()
        this.Prototype.DefineProp('Clone', { Call: Rect_Clone })
    }
    static FromDesktop() => this(DllCall(g_user32_GetDesktopWindow, 'ptr'))
    static FromForeground() => this(DllCall(g_user32_GetForegroundWindow, 'ptr'))
    static FromCursor() {
        pt := Point()
        if !DllCall(g_user32_GetCursorPos, 'ptr', pt, 'int') {
            throw OSError()
        }
        return this(DllCall(g_user32_WindowFromPoint, 'int', pt.Value, 'ptr'))
    }
    static FromParent(Hwnd) => this(DllCall(g_user32_GetParent, 'ptr', Hwnd, 'ptr'))
    static FromPoint(X, Y) => this(DllCall(g_user32_WindowFromPoint, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr'))
    static FromShell() => this(DllCall(g_user32_GetShellWindow, 'ptr'))
    static FromTop(Hwnd := 0) => this(DllCall(g_user32_GetTopWindow, 'ptr', Hwnd, 'ptr'))
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindow GetWindow}.
     *
     * @param {Integer} Hwnd - A handle to a window. The window handle retrieved is relative to this
     * window, based on the value of the Cmd parameter.
     *
     * @param {Integer} Cmd - One of the following:
     * - GW_CHILD - 5 - The retrieved handle identifies the child window at the top of the Z order,
     *  if the specified window is a parent window; otherwise, the retrieved handle is NULL. The
     *  function examines only child windows of the specified window. It does not examine descendant
     *  windows.
     *
     * - GW_ENABLEDPOPUP - 6 - The retrieved handle identifies the enabled popup window owned by the
     *  specified window (the search uses the first such window found using GW_HWNDNEXT); otherwise,
     *  if there are no enabled popup windows, the retrieved handle is that of the specified window.
     *
     * - GW_HWNDFIRST - 0 - The retrieved handle identifies the window of the same type that is highest
     *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HWNDLAST - 1 - The retrieved handle identifies the window of the same type that is lowest
     *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level window.
     *  If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HWNDNEXT - 2 - The retrieved handle identifies the window below the specified window in
     *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HWNDPREV - 3 - The retrieved handle identifies the window above the specified window in
     *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_OWNER - 4 - The retrieved handle identifies the specified window's owner window, if any.
     *  For more information, see Owned Windows.
     *
     * @returns {Window32}
     */
    static Get(Hwnd, Cmd) => this(DllCall(g_user32_GetWindow, 'ptr', Hwnd, 'uint', Cmd, 'ptr'))

    /**
     * @description - {@link Window32} enables the usage of object-oriented syntax and style to
     * obtain and manipulate the properties of a window. Each {@link Window32} object has a buffer
     * that represents a {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-windowinfo WINDOWINFO}
     * structure. This structure is filled by calling
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowinfo}.
     *
     * `Hwnd` is cached on property {@link Window32#Hwnd}, and the methods act upon that hwnd.
     *
     * WINDOWINFO has two members that are RECT structures, rcWindow and rcClient. {@link Window32}
     * methods that interact with a RECT structure interact with the rcWindow structure, unless
     * otherwise noted.
     *
     * @param {Integer} [Hwnd = 0] - The window handle.
     */
    __New(Hwnd := 0) {
        this.Buffer := Buffer(60, 0)
        this.Hwnd := Hwnd
        NumPut('uint', 60, this.Buffer)
    }

    Activate() => WinActivate(this.Hwnd)
    AdjustRectEx(X?, Y?, W?, H?) {
        this()
        rc := Rect.FromDimensions(
            X ?? NumGet(this, 4, 'int'),
            Y ?? NumGet(this, 8, 'int'),
            W ?? NumGet(this, 12, 'int') - NumGet(this, 4, 'int'),
            H ?? NumGet(this, 16, 'int') - NumGet(this, 8, 'int')
        )
        if !DllCall(g_user32_AdjustWindowRectEx, 'ptr', rc, 'uint', this.Style, 'int', this.Menu ? 1 : 0, 'uint', this.ExStyle, 'int') {
            throw OSError()
        }
        this()
    }
    BringToTop() => DllCall(g_user32_BringWindowToTop, 'ptr', this.Hwnd, 'int')
    Call(*) {
        if !DllCall(g_user32_GetWindowInfo, 'ptr', this.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    ChildFromPoint(X, Y) => DllCall(g_user32_ChildWindowFromPoint, 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    ChildFromPointEx(X, Y, Flag := 0) => DllCall(g_user32_ChildWindowFromPointEx, 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', Flag, 'ptr')
    Clone() {
        ; this is overridden
    }
    Close() => WinClose(this.Hwnd)
    EnumChildWindows(Callback, lParam := 0) {
        if IsObject(callback) {
            cb := CallbackCreate(Callback, 'fast',  1)
            result := DllCall(g_user32_EnumChildWindows, 'ptr', this.Hwnd, 'ptr', cb, 'ptr', lParam, 'int')
            CallbackFree(cb)
            return result
        } else {
            return DllCall(g_user32_EnumChildWindows, 'ptr', this.Hwnd, 'ptr', callback, 'ptr', lParam, 'int')
        }
    }
    GetChildBoundingRect() {
        rects := [WinRect(, 3), WinRect(, 3), WinRect(, 3)]
        cb := CallbackCreate(_EnumChildWindowsProc, 'fast')
        DllCall(g_user32_EnumChildWindows, 'ptr', this.hwnd, 'ptr', cb, 'ptr', ObjPtr(rects), 'int')
        CallbackFree(cb)
        return rects[1]

        _EnumChildWindowsProc(hwnd, lparam) {
            rects := ObjFromPtrAddRef(lparam)
            rects[3].hwnd := hwnd
            rects[3]()
            DllCall(g_user32_UnionRect, 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
            rects.Push(rects.RemoveAt(1))
            return 1
        }
    }
    GetClientRect() => WinRect(this.Hwnd, 1)
    GetControls() => WinGetControls(this.Hwnd)
    GetControlsHwnd() => WinGetControlsHwnd(this.Hwnd)
    GetWindowRect() => WinRect(this.Hwnd, 0)
    HasExStyle(Id) => this.ExStyle & Id
    HasStyle(Id) => this.Style & Id
    Hide() => WinHide(this.Hwnd)
    IsChild(Hwnd) => DllCall(g_user32_IsChild, 'ptr', this.Hwnd, 'ptr', Hwnd, 'int')
    IsParent(Hwnd) => DllCall(g_user32_IsChild, 'ptr', Hwnd, 'ptr', this.Hwnd, 'int')
    Kill() => WinKill(this.Hwnd)
    Maximize() => WinMaximize(this.Hwnd)
    Minimize() => WinMinimize(this.Hwnd)
    MoveBottom() => WinMoveBottom(this.Hwnd)
    MoveClient(X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
        this()
        rc := Rect.FromDimensions(
            X ?? NumGet(this, 20, 'int'),
            Y ?? NumGet(this, 24, 'int'),
            W ?? NumGet(this, 28, 'int') - NumGet(this, 20, 'int'),
            H ?? NumGet(this, 32, 'int') - NumGet(this, 24, 'int')
        )
        if !DllCall(g_user32_AdjustWindowRectEx, 'ptr', rc, 'uint', this.Style, 'int', this.Menu ? 1 : 0, 'uint', this.ExStyle, 'int') {
            throw OSError()
        }
        if !DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', rc.X, 'int', rc.Y, 'int', rc.W, 'int', rc.H, 'uint', Flags, 'int') {
            throw OSError()
        }
        this()
    }
    MoveTop() => WinMoveTop(this.Hwnd)
    RealChildFromPoint(X, Y) => DllCall(g_user32_RealChildWindowFromPoint, 'ptr', this.Hwnd, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
    Redraw() => WinRedraw(this.Hwnd)
    Restore() => WinRestore(this.Hwnd)
    SetActive() => DllCall(g_user32_SetActiveWindow, 'ptr', this.Hwnd, 'int')
    SetAlwaysOnTop() => WinSetAlwaysOnTop(this.Hwnd)
    /**
     * @description - Sets a callback that updates the object's property {@link Window32#Hwnd} when
     * {@link Window32.Prototype.Call} is called. By default, {@link Window32.Prototype.Call} does not
     * update the {@link Window32#Hwnd} property, and instead calls `GetWindowRect` with the current
     * {@link Window32#Hwnd}. When {@link Window32.Prototype.SetCallback} is called, a new method
     * {@link Window32#Call} is defined that calls the callback function and uses the return value
     * to update the property {@link Window32#Hwnd}, then calls `GetWindowRect` using that new
     * handle. To remove the callback and return the {@link Window32#Call} method
     * to its original functionality, pass zero or an empty string to `Callback`.
     *
     * This library includes a number of functions that are useful for this, each beginning with
     * "Window32Callback". However, your code will likely benefit from knowing when no window handle
     * is returned by one of the functions, so your code can respond in some type of way, as seen
     * in the examples below.
     *
     * @example
     * MyHelperFunc(*) {
     *     hwnd := Window32CallbackFromForeground()
     *     if hwnd {
     *         return hwnd
     *     } else {
     *         ; do something
     *     }
     * }
     *
     * win := Window32()
     * win.SetCallback(MyHelperFunc)
     * win()
     * @
     *
     * @example
     * MyHelperFunc(win) {
     *     hwnd := Window32CallbackFromParent(win)
     *     if hwnd {
     *         return hwnd
     *     } else {
     *         ; do something
     *     }
     * }
     *
     * hwnd := WinExist('A')
     * if !hwnd {
     *     throw Error('Window not found.')
     * }
     * win := Window32(hwnd)
     * win.SetCallback(MyHelperFunc)
     * win()
     * MsgBox(win.Hwnd == hwnd) ; 0 or 1 depending if a parent window exists
     * @
     *
     * @param {*} Callback - A `Func` or callable object that accepts the `Window32` object as its
     * only parameter, and that returns a new "Hwnd" value. If the callback returns zero or an empty
     * string, the property "Hwnd" will not be updated and `GetWindowInfo` will not be called.
     * If the callback returns an integer, the property "Hwnd" is updated and `GetWindowInfo` is
     * called. If the callback returns another type of value, a TypeError is thrown.
     */
    SetCallback(Callback) {
        if Callback {
            this.DefineProp('Callback', { Call: Callback })
            this.DefineProp('Call', Window32.Prototype.GetOwnPropDesc('__CallWithCallback'))
        } else {
            if this.HasOwnProp('Callback') {
                this.DeleteProp('Callback')
            }
            if this.HasOwnProp('Call') {
                this.DeleteProp('Call')
            }
        }
    }
    SetEnabled(NewSetting) => WinSetEnabled(NewSetting, this.Hwnd)
    SetExStyle(Value) => WinSetExStyle(Value, this.Hwnd)
    SetForeground() {
        return DllCall(g_user32_SetForegroundWindow, 'ptr', this.Hwnd, 'int')
    }
    SetHeightKeepAspectRatio(Height, AspectRatio?) {
        this.H := Height
        return this.W := Height / (AspectRatio ?? this.W / this.H)
    }
    SetParent(Hwnd := 0) {
        return DllCall(g_user32_SetParent, 'ptr', this.Hwnd, 'ptr', Hwnd, 'ptr')
    }
    SetWidthKeepAspectRatio(Width, AspectRatio?) {
        this.W := Width
        return this.H := Width * (AspectRatio ?? this.W / this.H)
    }
    SetRegion(Options?) => WinSetRegion(Options ?? unset, this.Hwnd)
    SetStyle(Value) => WinSetStyle(Value, this.Hwnd)
    SetTransparent(N) => WinSetTransparent(N, this.Hwnd)
    /**
     * @description - Calls {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow}.
     *
     * @param {Integer} [Flag = 0] -
     * - SW_HIDE 0 - Hides the window and activates another window.
     * - SW_SHOWNORMAL / SW_NORMAL 1 - Activates and displays a window. If the window is minimized,
     *   maximized, or arranged, the system restores it to its original size and position. An
     *   application should specify this flag when displaying the window for the first time.
     * - SW_SHOWMINIMIZED 2 - Activates the window and displays it as a minimized window.
     * - SW_SHOWMAXIMIZED / SW_MAXIMIZE 3 - Activates the window and displays it as a maximized window.
     * - SW_SHOWNOACTIVATE 4 - Displays a window in its most recent size and position. This value is
     *   similar to SW_SHOWNORMAL, except that the window is not activated.
     * - SW_SHOW 5 - Activates the window and displays it in its current size and position.
     * - SW_MINIMIZE 6 - Minimizes the specified window and activates the next top-level window in
     *   the Z order.
     * - SW_SHOWMINNOACTIVE 7 - Displays the window as a minimized window. This value is similar to
     *   SW_SHOWMINIMIZED, except the window is not activated.
     * - SW_SHOWNA 8 - Displays the window in its current size and position. This value is similar
     *   to SW_SHOW, except that the window is not activated.
     * - SW_RESTORE 9 - Activates and displays the window. If the window is minimized, maximized, or
     *   arranged, the system restores it to its original size and position. An application should
     *   specify this flag when restoring a minimized window.
     * - SW_SHOWDEFAULT 10 - Sets the show state based on the SW_ value specified in the STARTUPINFO
     *   structure passed to the CreateProcess function by the program that started the application.
     * - SW_FORCEMINIMIZE 11 - Minimizes a window, even if the thread that owns the window is not
     *   responding. This flag should only be used when minimizing windows from a different thread.
     */
    Show(Flag := 9) => DllCall(g_user32_ShowWindow, 'ptr', this.Hwnd, 'uint', Flag, 'int')
    WaitActive(Timeout?) => WinWaitActive(this.Hwnd, , Timeout ?? Unset)
    WaitClose(Timeout?) => WinWaitClose(this.Hwnd, , Timeout ?? unset)
    WaitNotActive(Timeout?) => WinWaitNotActive(this.Hwnd, , Timeout ?? unset)
    /**
     * @description - See {@link Window32.Prototype.SetCallback}.
     */
    __CallWithCallback() {
        if hwnd := this.Callback() {
            if !DllCall(g_user32_GetWindowInfo, 'ptr', this.Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
            return this.Hwnd := hwnd
        }
    }

    Active {
        Get => WinActive(this.Hwnd)
        Set {
            if Value {
                WinActivate(this.Hwnd)
            } else {
                WinMinimize(this.Hwnd)
            }
        }
    }
    Atom => NumGet(this, 56, 'short')
    BorderHeight => NumGet(this, 52, 'int')
    BorderWidth => NumGet(this, 48, 'int')
    Class => WinGetClass(this.Hwnd)
    CreatorVersion => NumGet(this, 58, 'short')
    Dpi => DllCall(g_user32_GetDpiForWindow, 'ptr', this.Hwnd, 'int')
    Exist => WinExist(this.Hwnd)
    ExStyle => NumGet(this, 40, 'uint')
    Maximized => WinGetMinMax(this.Hwnd) == 1
    Menu => DllCall(g_user32_GetMenu, 'ptr', this.Hwnd, 'ptr')
    Minimized => WinGetMinMax(this.Hwnd) == -1
    Monitor => DllCall(g_user32_MonitorFromWindow, 'ptr', this.Hwnd, 'int', 0, 'ptr')
    PID => WinGetPid(this.Hwnd)
    ProcessName => WinGetProcessName(this.Hwnd)
    ProcessPath => WinGetProcessPath(this.Hwnd)
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    Status => NumGet(this, 44, 'int')
    Style => NumGet(this, 36, 'uint')
    Text => WinGetText(this.Hwnd)
    Title {
        Get => WinGetTitle(this.Hwnd)
        Set => WinSetTitle(Value, this.Hwnd)
    }
    TransColor {
        Get => WinGetTransColor(this.Hwnd)
        Set => WinSetTransColor(Value, this.Hwnd)
    }
    Visible {
        Get => DllCall(g_user32_IsWindowVisible, 'ptr', this.Hwnd, 'int')
        Set => this.Show(Value ? 9 : 0)
    }
}

class WinRect extends Rect {
    /**
     * @param {Integer} [Hwnd = 0] - The window handle.
     * @param {Integer} [Flag = 0] - A flag that determines what function is called when
     * measuring the window's dimensions.
     * - 0 : `GetWindowRect`
     * - 1 : `GetClientRect`
     * - 2 : `DwmGetWindowAttribute` passing DWMWA_EXTENDED_FRAME_BOUNDS to dwAttribute.
     *   See {@link https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetwindowattribute}.
     * - 3 : `GetWindowRect` is called, then `ScreenToClient` is called for both coordinates using
     *   the parent window's client area for the conversion. If `Hwnd` is a control's window handle,
     *   this would be the same as calling
     *   {@link https://www.autohotkey.com/docs/v2/lib/GuiControl.htm#GetPos Gui.Control.Prototype.GetPos}.
     * - 4 : `GetWindowRect` is called for both the window and its parent window, then it calculates
     *   the position of the window relative to the top-left corner of the parent window's display
     *   area (including non-client area).
     *
     * Some controls / windows will cause `DwmGetWindowAttribute` to throw an error.
     *
     * For more information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect}.
     */
    __New(Hwnd := 0, Flag := 0) {
        this.Buffer := Buffer(16)
        this.Flag := Flag
        if this.Hwnd := Hwnd {
            this()
        }
    }
    Call(*) {
        switch this.Flag, 0 {
            case 0:
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 1:
                if !DllCall(g_user32_GetClientRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
            case 2:
                if HRESULT := DllCall(g_dwmapi_DwmGetWindowAttribute, 'ptr', this.Hwnd, 'uint', 9, 'ptr', this.Ptr, 'uint', 16, 'uint') {
                    throw OSError('``DwmGetWindowAttribute`` failed.', , 'HRESULT: ' Format('{:X}', HRESULT))
                }
            case 3:
                hwndParent := DllCall(g_user32_GetParent, 'ptr', this.Hwnd, 'ptr') || this.Hwnd
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                if !DllCall(g_user32_ScreenToClient, 'ptr', hwndParent, 'ptr', this.Ptr + 8, 'int') {
                    throw OSError()
                }
            case 4:
                hwndParent := DllCall(g_user32_GetParent, 'ptr', this.Hwnd, 'ptr') || this.Hwnd
                if !DllCall(g_user32_GetWindowRect, 'ptr', this.Hwnd, 'ptr', this.Ptr, 'int') {
                    throw OSError()
                }
                wrc := WinRect(hwndParent, 0)
                this.l -= wrc.l
                this.r -= wrc.l
                this.t -= wrc.t
                this.b -= wrc.t
        }
    }
    Apply(InsertAfter := 0, Flags := 0) {
        return DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int')
    }
    GetPos(&X?, &Y?, &W?, &H?) {
        this()
        X := this.L
        Y := this.T
        W := this.W
        H := this.H
    }
    MapPoints(wrc, points) {
        return DllCall(g_user32_MapWindowPoints, 'ptr', this.Hwnd, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', points, 'uint', points.Size / 8, 'int')
    }
    Move(X?, Y?, W?, H?, InsertAfter := 0, Flags := 0) {
        this()
        if IsSet(X) {
            this.L := X
        }
        if IsSet(Y) {
            this.T := Y
        }
        if IsSet(W) {
            this.W := W
        }
        if IsSet(H) {
            this.H := H
        }
        if !DllCall(g_user32_SetWindowPos, 'ptr', this.Hwnd, 'ptr', InsertAfter, 'int', this.L, 'int', this.T, 'int', this.W, 'int', this.H, 'uint', Flags, 'int') {
            throw OSError()
        }
    }
}

Rect_Clone(Self) {
    obj := Object.Prototype.Clone.Call(Self)
    obj.Buffer := Buffer(Self.Size)
    ObjSetBase(obj, %Self.__Class%.Prototype)
    DllCall(
        g_msvcrt_memmove
      , 'ptr', obj.Ptr
      , 'ptr', Self.Ptr
      , 'int', Self.Size
      , 'cdecl'
    )
    return obj
}

Rect_SetConstants(force := false) {
    global
    if IsSet(Rect_constants_set) {
        if !force {
            return
        }
    } else {
        if !IsSet(g_dwmapi_DwmGetWindowAttribute) {
            g_dwmapi_DwmGetWindowAttribute := 0
        }
        if !IsSet(g_msvcrt_memmove) {
            g_msvcrt_memmove := 0
        }
        if !IsSet(g_shcore_GetDpiForMonitor) {
            g_shcore_GetDpiForMonitor := 0
        }
        if !IsSet(g_user32_AdjustWindowRectEx) {
            g_user32_AdjustWindowRectEx := 0
        }
        if !IsSet(g_user32_BringWindowToTop) {
            g_user32_BringWindowToTop := 0
        }
        if !IsSet(g_user32_ChildWindowFromPoint) {
            g_user32_ChildWindowFromPoint := 0
        }
        if !IsSet(g_user32_ChildWindowFromPointEx) {
            g_user32_ChildWindowFromPointEx := 0
        }
        if !IsSet(g_user32_ClientToScreen) {
            g_user32_ClientToScreen := 0
        }
        if !IsSet(g_user32_EnumChildWindows) {
            g_user32_EnumChildWindows := 0
        }
        if !IsSet(g_user32_EqualRect) {
            g_user32_EqualRect := 0
        }
        if !IsSet(g_user32_GetCaretPos) {
            g_user32_GetCaretPos := 0
        }
        if !IsSet(g_user32_GetClientRect) {
            g_user32_GetClientRect := 0
        }
        if !IsSet(g_user32_GetCursorPos) {
            g_user32_GetCursorPos := 0
        }
        if !IsSet(g_user32_GetDesktopWindow) {
            g_user32_GetDesktopWindow := 0
        }
        if !IsSet(g_user32_GetDpiForWindow) {
            g_user32_GetDpiForWindow := 0
        }
        if !IsSet(g_user32_GetForegroundWindow) {
            g_user32_GetForegroundWindow := 0
        }
        if !IsSet(g_user32_GetMenu) {
            g_user32_GetMenu := 0
        }
        if !IsSet(g_user32_GetParent) {
            g_user32_GetParent := 0
        }
        if !IsSet(g_user32_GetShellWindow) {
            g_user32_GetShellWindow := 0
        }
        if !IsSet(g_user32_GetTopWindow) {
            g_user32_GetTopWindow := 0
        }
        if !IsSet(g_user32_GetWindow) {
            g_user32_GetWindow := 0
        }
        if !IsSet(g_user32_GetWindowInfo) {
            g_user32_GetWindowInfo := 0
        }
        if !IsSet(g_user32_GetWindowRect) {
            g_user32_GetWindowRect := 0
        }
        if !IsSet(g_user32_InflateRect) {
            g_user32_InflateRect := 0
        }
        if !IsSet(g_user32_IntersectRect) {
            g_user32_IntersectRect := 0
        }
        if !IsSet(g_user32_IsChild) {
            g_user32_IsChild := 0
        }
        if !IsSet(g_user32_IsRectEmpty) {
            g_user32_IsRectEmpty := 0
        }
        if !IsSet(g_user32_IsWindowVisible) {
            g_user32_IsWindowVisible := 0
        }
        if !IsSet(g_user32_LogicalToPhysicalPoint) {
            g_user32_LogicalToPhysicalPoint := 0
        }
        if !IsSet(g_user32_LogicalToPhysicalPointForPerMonitorDPI) {
            g_user32_LogicalToPhysicalPointForPerMonitorDPI := 0
        }
        if !IsSet(g_user32_MapWindowPoints) {
            g_user32_MapWindowPoints := 0
        }
        if !IsSet(g_user32_MonitorFromPoint) {
            g_user32_MonitorFromPoint := 0
        }
        if !IsSet(g_user32_MonitorFromRect) {
            g_user32_MonitorFromRect := 0
        }
        if !IsSet(g_user32_MonitorFromWindow) {
            g_user32_MonitorFromWindow := 0
        }
        if !IsSet(g_user32_OffsetRect) {
            g_user32_OffsetRect := 0
        }
        if !IsSet(g_user32_PhysicalToLogicalPoint) {
            g_user32_PhysicalToLogicalPoint := 0
        }
        if !IsSet(g_user32_PhysicalToLogicalPointForPerMonitorDPI) {
            g_user32_PhysicalToLogicalPointForPerMonitorDPI := 0
        }
        if !IsSet(g_user32_PtInRect) {
            g_user32_PtInRect := 0
        }
        if !IsSet(g_user32_RealChildWindowFromPoint) {
            g_user32_RealChildWindowFromPoint := 0
        }
        if !IsSet(g_user32_ScreenToClient) {
            g_user32_ScreenToClient := 0
        }
        if !IsSet(g_user32_SetActiveWindow) {
            g_user32_SetActiveWindow := 0
        }
        if !IsSet(g_user32_SetCaretPos) {
            g_user32_SetCaretPos := 0
        }
        if !IsSet(g_user32_SetCursorPos) {
            g_user32_SetCursorPos := 0
        }
        if !IsSet(g_user32_SetForegroundWindow) {
            g_user32_SetForegroundWindow := 0
        }
        if !IsSet(g_user32_SetParent) {
            g_user32_SetParent := 0
        }
        if !IsSet(g_user32_SetThreadDpiAwarenessContext) {
            g_user32_SetThreadDpiAwarenessContext := 0
        }
        if !IsSet(g_user32_SetWindowPos) {
            g_user32_SetWindowPos := 0
        }
        if !IsSet(g_user32_ShowWindow) {
            g_user32_ShowWindow := 0
        }
        if !IsSet(g_user32_SubtractRect) {
            g_user32_SubtractRect := 0
        }
        if !IsSet(g_user32_UnionRect) {
            g_user32_UnionRect := 0
        }
        if !IsSet(g_user32_WindowFromPoint) {
            g_user32_WindowFromPoint := 0
        }
    }

    ; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
    if IsSet(LibraryManager) {
        Rect_LibraryToken := LibraryManager(
            'dwmapi', [
                'DwmGetWindowAttribute'
            ],
            'msvcrt', [
                'memmove'
            ],
            'shcore', [
                'GetDpiForMonitor'
            ],
            'user32', [
                'AdjustWindowRectEx',
                'BringWindowToTop',
                'ChildWindowFromPoint',
                'ChildWindowFromPointEx',
                'ClientToScreen',
                'EnumChildWindows',
                'EqualRect',
                'GetCaretPos',
                'GetClientRect',
                'GetCursorPos',
                'GetDesktopWindow',
                'GetDpiForWindow',
                'GetForegroundWindow',
                'GetMenu',
                'GetParent',
                'GetShellWindow',
                'GetTopWindow',
                'GetWindow',
                'GetWindowInfo',
                'GetWindowRect',
                'InflateRect',
                'IntersectRect',
                'IsChild',
                'IsRectEmpty',
                'IsWindowVisible',
                'LogicalToPhysicalPoint',
                'LogicalToPhysicalPointForPerMonitorDPI',
                'MapWindowPoints',
                'MonitorFromPoint',
                'MonitorFromRect',
                'MonitorFromWindow',
                'OffsetRect',
                'PhysicalToLogicalPoint',
                'PhysicalToLogicalPointForPerMonitorDPI',
                'PtInRect',
                'RealChildWindowFromPoint',
                'ScreenToClient',
                'SetActiveWindow',
                'SetCaretPos',
                'SetCursorPos',
                'SetForegroundWindow',
                'SetParent',
                'SetThreadDpiAwarenessContext',
                'SetWindowPos',
                'ShowWindow',
                'SubtractRect',
                'UnionRect',
                'WindowFromPoint'
            ]
        )
    } else {
        local hmod := DllCall('LoadLibrary', 'str', 'Dwmapi', 'ptr')
        g_dwmapi_DwmGetWindowAttribute := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'DwmGetWindowAttribute', 'ptr')
        hmod := DllCall('LoadLibrary', 'str', 'msvcrt', 'ptr')
        g_msvcrt_memmove := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'memmove', 'ptr')
        hmod := DllCall('LoadLibrary', 'str', 'Shcore', 'ptr')
        g_shcore_GetDpiForMonitor := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDpiForMonitor', 'ptr')
        hmod := DllCall('GetModuleHandle', 'str', 'User32', 'ptr')
        g_user32_AdjustWindowRectEx := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'AdjustWindowRectEx', 'ptr')
        g_user32_BringWindowToTop := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'BringWindowToTop', 'ptr')
        g_user32_ChildWindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ChildWindowFromPoint', 'ptr')
        g_user32_ChildWindowFromPointEx := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ChildWindowFromPointEx', 'ptr')
        g_user32_ClientToScreen := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ClientToScreen', 'ptr')
        g_user32_EnumChildWindows := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'EnumChildWindows', 'ptr')
        g_user32_EqualRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'EqualRect', 'ptr')
        g_user32_GetCaretPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetCaretPos', 'ptr')
        g_user32_GetClientRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetClientRect', 'ptr')
        g_user32_GetCursorPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetCursorPos', 'ptr')
        g_user32_GetDesktopWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDesktopWindow', 'ptr')
        g_user32_GetDpiForWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetDpiForWindow', 'ptr')
        g_user32_GetForegroundWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetForegroundWindow', 'ptr')
        g_user32_GetMenu := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetMenu', 'ptr')
        g_user32_GetParent := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetParent', 'ptr')
        g_user32_GetShellWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetShellWindow', 'ptr')
        g_user32_GetTopWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetTopWindow', 'ptr')
        g_user32_GetWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindow', 'ptr')
        g_user32_GetWindowInfo := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindowInfo', 'ptr')
        g_user32_GetWindowRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetWindowRect', 'ptr')
        g_user32_InflateRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'InflateRect', 'ptr')
        g_user32_IntersectRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IntersectRect', 'ptr')
        g_user32_IsChild := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsChild', 'ptr')
        g_user32_IsRectEmpty := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsRectEmpty', 'ptr')
        g_user32_IsWindowVisible := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'IsWindowVisible', 'ptr')
        g_user32_LogicalToPhysicalPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'LogicalToPhysicalPoint', 'ptr')
        g_user32_LogicalToPhysicalPointForPerMonitorDPI := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'LogicalToPhysicalPointForPerMonitorDPI', 'ptr')
        g_user32_MapWindowPoints := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MapWindowPoints', 'ptr')
        g_user32_MonitorFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromPoint', 'ptr')
        g_user32_MonitorFromRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromRect', 'ptr')
        g_user32_MonitorFromWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'MonitorFromWindow', 'ptr')
        g_user32_OffsetRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'OffsetRect', 'ptr')
        g_user32_PhysicalToLogicalPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PhysicalToLogicalPoint', 'ptr')
        g_user32_PhysicalToLogicalPointForPerMonitorDPI := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PhysicalToLogicalPointForPerMonitorDPI', 'ptr')
        g_user32_PtInRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'PtInRect', 'ptr')
        g_user32_RealChildWindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'RealChildWindowFromPoint', 'ptr')
        g_user32_ScreenToClient := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ScreenToClient', 'ptr')
        g_user32_SetActiveWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetActiveWindow', 'ptr')
        g_user32_SetCaretPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetCaretPos', 'ptr')
        g_user32_SetCursorPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetCursorPos', 'ptr')
        g_user32_SetForegroundWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetForegroundWindow', 'ptr')
        g_user32_SetParent := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetParent', 'ptr')
        g_user32_SetThreadDpiAwarenessContext := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetThreadDpiAwarenessContext', 'ptr')
        g_user32_SetWindowPos := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SetWindowPos', 'ptr')
        g_user32_ShowWindow := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'ShowWindow', 'ptr')
        g_user32_SubtractRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'SubtractRect', 'ptr')
        g_user32_UnionRect := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'UnionRect', 'ptr')
        g_user32_WindowFromPoint := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'WindowFromPoint', 'ptr')
    }


    Rect_constants_set := true
}
