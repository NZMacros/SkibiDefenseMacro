/*
ShellRun by Lexikos
	requires: AutoHotkey v1.1
	license: http://creativecommons.org/publicdomain/zero/1.0/
Credit for explaining this method goes to BrandonLive:
http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/

Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
; Note might have to use for deeplinking if we have roblox admin issues
ShellRun(prms*) {
	shellWindows := ComObject("Shell.Application").Windows
	desktop := shellWindows.FindWindowSW(0, 0, 8, 0, 1) ; SWC_DESKTOP, SWFO_NEEDDISPATCH

	; Retrieve top-level browser object.
	tlb := ComObjQuery(desktop,
		"{4C96BE40-915C-11CF-99D3-00AA004AE837}", ; SID_STopLevelBrowser
		"{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser

	; IShellBrowser.QueryActiveShellView -> IShellView
	ComCall(15, tlb, "ptr*", sv := ComValue(13, 0)) ; VT_UNKNOWN

	; Define IID_IDispatch.
	NumPut("int64", 0x20400, "int64", 0x46000000000000C0, IID_IDispatch := Buffer(16))

	; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
	ComCall(15, sv, "uint", 0, "ptr", IID_IDispatch, "ptr*", sfvd := ComValue(9, 0)) ; VT_DISPATCH

	; Get Shell object.
	shell := sfvd.Application

	; IShellDispatch2.ShellExecute
	shell.ShellExecute(prms*)
}
