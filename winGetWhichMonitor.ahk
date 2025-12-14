#Requires AutoHotkey v1.1.35+
#Include %A_ScriptDir%
#Include .\lib\MonitorExGetUtils.ahk
;==============================================================
; WinGetWhichMonitor — Determine the monitor index for a window
;
; GitHub: https://github.com/SevenKeyboard/win-get-which-monitor
; Author: SevenKeyboard Ltd. (2025)
; License: MIT License
;==============================================================
class VersionManager_winGetWhichMonitor
{
    static _ := VersionManager_winGetWhichMonitor._init()
    _init()    {
        global
        WINGETWHICHMONITOR_VERSION := "1.0.1"
        if (!this._verCheck(MONITOREXGETUTILS_VERSION, "1.0.0"))
            throw exception("MonitorExGetUtils version 1.x is required (minimum 1.0.0).")
        return true
    }
    _verCheck(byRef actual, required)    {
        if !isSet(actual)
            return false
        actualMajor     := strSplit(actual, ".",, 2)[1]
        requiredMajor   := strSplit(required, ".",, 2)[1]
        if (actualMajor !== requiredMajor)
            return false
        return verCompare(actual, ">=" required)
    }
}
winGetWhichMonitor(winTitle:="", winText:="", dwFlags:="", excludeTitle:="", excludeText:="")    {
    local
    static MONITOR_DEFAULTTONULL:=0x00000000
        ,MONITOR_DEFAULTTOPRIMARY:=0x00000001
        ,MONITOR_DEFAULTTONEAREST:=0x00000002
    if (winTitle!==""
        && winTitle~="D)^-?(?:[[:digit:]]+|(0[Xx][[:xdigit:]]+))$"
        && dllCall("User32.dll\IsWindow", "Ptr",winTitle))    {
        hwnd:=winTitle
    }  else if !(hwnd:=winExist(winTitle, winText, excludeTitle, excludeText))    {
        return 0
    }
    if (dwFlags!=="")    {
        dwFlags:=(dwFlags==MONITOR_DEFAULTTONULL || dwFlags==MONITOR_DEFAULTTOPRIMARY || dwFlags==MONITOR_DEFAULTTONEAREST)?dwFlags
                :(dwFlags~="iD)^MONITOR_DEFAULTTO(NULL|PRIMARY|NEAREST)$")?%dwFlags%
                :(dwFlags~="iD)^(NULL|PRIMARY|NEAREST)$")?MONITOR_DEFAULTTO%dwFlags%
                :dwFlags
    }  else  {
        dwFlags:=MONITOR_DEFAULTTONULL
    }
    if (hMonitor:=dllCall("User32.dll\MonitorFromWindow", "Ptr",hwnd, "UInt",dwFlags))    {
        for n,info in monitorExGetInfoList()    {
            if (hMonitor==info.hMonitor)
                return n
        }
    }
    return 0
}