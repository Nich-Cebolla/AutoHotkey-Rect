
#include ..\src\Rect.ahk

test()

class test {
    static Call() {
        g1 := this.g1 := Gui('+Resize')
        g2 := this.g2 := Gui('+Resize')

        _Proc(g1)
        _Proc(g2)

        ctrls := []
        w := 0
        for name in [ 'Dimension',  'Prefer',  'Padding',  'InsufficientSpaceAction' ] {
            ctrls.Push(g1.Add('Text', 'Right v' name, name ':'))
            ctrls[-1].GetPos(, , &_w)
            w := Max(w, _w)
        }
        for ctrl in ctrls {
            ctrl.Move(, , w)
            ctrl.GetPos(&x, &y, , &h)
            x += w + g1.MarginX
            g1.Add('Edit', 'x' x ' y' y ' w100 h' h ' v' ctrl.Name '2')
        }
        g1['Dimension2'].Text := 'X'
        g1['Padding2'].Text := 5
        g1['InsufficientSpaceAction2'].Text := 0

        g1.Add('Button', 'Section', 'Call').OnEvent('Click', HClickButtonCall)
        g1.Add('Button', 'ys', 'Exit').OnEvent('Click', (*) => ExitApp())

        g1.Show('x100 y100')
        g2.Show('x600 y100')

        this.wh :=  WindowsHook(12, HOOKPROC, , , true) ; WH_CALLWNDPROCRET

        return

        _Proc(g) {
            g.SetFont('s12 q5', 'Segoe Ui')
            w := 0
            letters := [ 'X', 'Y', 'W', 'H' ]
            for c in letters {
                g.Add('Text', 'Right v' c, c ':').GetPos(, , &_w)
                w := Max(w, _w)
            }
            for c in letters {
                g[c].Move(, , w)
                g[c].GetPos(&x, &y)
                x += w + g.MarginX
                g.Add('Text', 'x' x ' y' y ' w75 v' c '2')
            }
        }
        HClickButtonCall(btn, *) {
            g1 := test.g1
            wrc1 := WinRect(g1.hwnd, 0)
            wrc2:= WinRect(test.g2.hwnd, 0)
            wrc2.MoveAdjacent(wrc1, , g1['Dimension2'].Text || unset, g1['Prefer2'].Text || unset, g1['Padding2'].Text || unset, g1['InsufficientSpaceAction2'].Text || unset)
            wrc2.Apply()
        }
    }
}

HOOKPROC(nCode, wParam, lParam) {
    if nCode >= 0 {
        Critical('On')
        cwpret := CWPRETSTRUCT(lParam)
        switch cwpret.Message {
        ; WM_WINDOWPOSCHANGED
        case 71:
            try {
                g := GuiFromHwnd(cwpret.hwnd)
            }
            if g {
                g.GetPos(&x, &y, &w, &h)
                g['x2'].Text := x
                g['y2'].Text := y
                g['w2'].Text := w
                g['h2'].Text := h
            }
        }
    }
    return DllCall(
        'CallNextHookEx'
      , 'ptr', 0
      , 'int', nCode
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}

class CWPRETSTRUCT {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Size :=
        ; Size      Type         Symbol     Offset               Padding
        A_PtrSize + ; LRESULT    lResult    0
        A_PtrSize + ; LPARAM     lParam     0 + A_PtrSize * 1
        A_PtrSize + ; WPARAM     wParam     0 + A_PtrSize * 2
        A_PtrSize + ; UINT       message    0 + A_PtrSize * 3    +4 on x64 only
        A_PtrSize   ; HWND       hwnd       0 + A_PtrSize * 4
        proto.offset_lResult  := 0
        proto.offset_lParam   := 0 + A_PtrSize * 1
        proto.offset_wParam   := 0 + A_PtrSize * 2
        proto.offset_message  := 0 + A_PtrSize * 3
        proto.offset_hwnd     := 0 + A_PtrSize * 4
    }
    __New(ptr) {
        this.ptr := ptr
    }
    lResult {
        Get => NumGet(this, this.offset_lResult, 'ptr')
        Set {
            NumPut('ptr', Value, this, this.offset_lResult)
        }
    }
    lParam {
        Get => NumGet(this, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this, this.offset_lParam)
        }
    }
    wParam {
        Get => NumGet(this, this.offset_wParam, 'ptr')
        Set {
            NumPut('ptr', Value, this, this.offset_wParam)
        }
    }
    message {
        Get => NumGet(this, this.offset_message, 'uint')
        Set {
            NumPut('uint', Value, this, this.offset_message)
        }
    }
    hwnd {
        Get => NumGet(this, this.offset_hwnd, 'ptr')
        Set {
            NumPut('ptr', Value, this, this.offset_hwnd)
        }
    }
}
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowsHook.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Calls `SetWindowsHookExW`.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
 */
class WindowsHook {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Handle := Proto.lpfn := Proto.OnExitCallback := 0
    }
    /**
     * @class
     *
     * @param {Integer} idHook - The type of hook to be installed.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}
     *
     * |  Hook Name           |  ID  |  Proc Type             |  lParam Points To       |  Use Case                                         |
     * |  --------------------|------|------------------------|-------------------------|-------------------------------------------------  |
     * |  WH_CALLWNDPROC      |  4   |  CallWndProc           |  CWPSTRUCT              |  Monitor before a message is processed            |
     * |  WH_CALLWNDPROCRET   |  12  |  CallWndRetProc        |  CWPRETSTRUCT           |  Monitor after a message is processed             |
     * |  WH_CBT              |  5   |  CBTProc               |  Varies by nnCode        |  Window activation, creation, move, resize, etc.  |
     * |  WH_DEBUG            |  9   |  DebugProc             |  DEBUGHOOKINFO          |  Debugging other hook procedures                  |
     * |  WH_FOREGROUNDIDLE   |  11  |  ForegroundIdleProc    |  lParam unused          |  Detect idle foreground thread                    |
     * |  WH_GETMESSAGE       |  3   |  GetMsgProc            |  MSG                    |  Intercept message queue on removal               |
     * |  WH_JOURNALPLAYBACK  |  1   |  JournalPlaybackProc   |  EVENTMSG               |  Replay input events (obsolete)                   |
     * |  WH_JOURNALRECORD    |  0   |  JournalRecordProc     |  EVENTMSG               |  Record input events (obsolete)                   |
     * |  WH_KEYBOARD         |  2   |  KeyboardProc          |  lParam = packed flags  |  Keyboard input (per-thread)                      |
     * |  WH_KEYBOARD_LL      |  13  |  LowLevelKeyboardProc  |  KBDLLHOOKSTRUCT        |  Global keyboard input                            |
     * |  WH_MOUSE            |  7   |  MouseProc             |  MOUSEHOOKSTRUCT        |  Mouse events (per-thread)                        |
     * |  WH_MOUSE_LL         |  14  |  LowLevelMouseProc     |  MSLLHOOKSTRUCT         |  Global mouse input                               |
     * |  WH_MSGFILTER        |  -1  |  MessageProc           |  MSG                    |  Pre-translate messages in modal loops            |
     * |  WH_SHELL            |  10  |  ShellProc             |  Varies by nnCode        |  Shell events (task switch, window create, etc.)  |
     * |  WH_SYSMSGFILTER     |  6   |  MessageProc           |  MSG                    |  Like WH_MSGFILTER, but system-wide               |
     *
     * @param {Func|BoundFunc} HookProc - The function that will be registered as the hook procedure.
     * You should read {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-HookProc}
     * before proceeding. Below is an example that uses the helper class `MouseHookStruct`. You can
     * run this example in the file "test-files\demo-MouseHookStruct.ahk".
     * @example
     *  #include <WindowsHook>
     *  #include <MouseHookStruct>
     *
     *  MouseProc(nCode, wParam, lParam) {
     *      if nCode == 0 {
     *          _mouseHookStruct := MouseHookStruct(lParam)
     *          OutputDebug('The mouse moved to ( ' _mouseHookStruct.X ', ' _mouseHookStruct.Y ' )`n')
     *      }
     *      return DllCall(
     *          'CallNextHookEx'
     *        , 'ptr', 0
     *        , 'int', nCode
     *        , 'uptr', wParam
     *        , 'ptr', lParam
     *        , 'ptr'
     *      )
     *  }
     *
     * @param {Integer} [Hmod = 0] - The handle to the module that contains the dll. Leave 0 unless
     * you are specifically using this with an external dll.
     *
     * @param {Integer} [dwThreadId] - The identifier of the thread with which the hook procedure is to
     * be associated. You cannot set this to zero when calling `SetWindowsHookExW` from AHK.
     * If unset, the return value from `GetWindowThreadProcessId` for `A_ScriptHwnd` is used. Leave
     * unset unless you are calling this function for a different process.
     *
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     *
     * If `DeferActivation` is true, `SetOnExit` is ignored.
     *
     * @param {Boolean} [DeferActivation = false] - If true, `SetWindowsHookExW` is not called, your
     * nCode must call `WindowsHook.Prototype.Hook`.
     */
    __New(idHook, HookProc, Hmod := 0, dwThreadId?, SetOnExit := true, DeferActivation := false) {
        this.idHook := idHook
        this.HookProc := HookProc
        this.Hmod := Hmod
        this.dwThreadId := dwThreadId ?? DllCall('GetWindowThreadProcessId', 'ptr', A_ScriptHwnd, 'ptr', 0, 'uint')
        if !DeferActivation {
            this.Hook(SetOnExit)
        }
    }

    Dispose(*) {
        if this.lpfn {
            CallbackFree(this.lpfn)
            this.lpfn := 0
        }
        this.HookProc := 0
        if this.Handle {
            return this.__UnhookWindowsEx()
        }
    }

    /**
     * @param {Boolean} [SetOnExit = true] - If true, sets an `OnExit` callback to call
     * `UnhookWindowsHookEx`. This is recommended by Microsoft:
     * "Before terminating, an application must call the UnhookWindowsHookEx function function to
     * free system resources associated with the hook."
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexw}.
     */
    Hook(SetOnExit := true) {
        if this.Handle {
            throw Error('The hook is already active.', -1)
        }
        if !this.lpfn {
            this.lpfn := CallbackCreate(this.HookProc)
        }
        if this.Handle := DllCall(
            'SetWindowsHookExW'
          , 'int', this.idHook
          , 'ptr', this.lpfn
          , 'ptr', this.Hmod
          , 'uint', this.dwThreadId
          , 'int'
        ) {
            if SetOnExit {
                if !this.OnExitCallback {
                    this.OnExitCallback := ObjBindMethod(this, 'Unhook')
                }
                OnExit(this.OnExitCallback, 1)
            }
        } else {
            CallbackFree(this.lpfn)
            throw OSError()
        }
    }

    /**
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-unhookwindowshookex}
     * @returns {Boolean} - If the function succeeds, the return value is nonzero.
     * If the function fails, the return value is zero. To get extended error information, call `OSError`.
     * @throws {Error} - The hook is not currently active.
     */
    Unhook(*) {
        if this.Handle {
            return this.__UnhookWindowsEx()
        } else {
            throw Error('The hook is not currently active.', -1)
        }
    }
    __UnhookWindowsEx() {
        handle := this.Handle
        this.Handle := 0
        if this.OnExitCallback {
            OnExit(this.OnExitCallback, 0)
            this.OnExitCallback := 0
        }
        return DllCall('UnhookWindowsHookEx', 'ptr', Handle, 'int')
    }

    __Delete() {
        this.Dispose()
    }
}
