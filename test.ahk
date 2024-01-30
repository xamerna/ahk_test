Table := 1

NumpadIns::{
    
    global Table
    If Table = 0
    {
        Send "{LWin Down}"
        Send "{LCtrl Down}"
        Send "{Right Down}"
        Sleep 50
        Send "{Right Up}"
        Send "{LCtrl Up}"
        Send "{LWin Up}"
        Table := 1
    }
    else
    {
        Send "{LWin Down}"
        Send "{LCtrl Down}"
        Send "{Left Down}"
        Sleep 50
        Send "{Left Up}"
        Send "{LCtrl Up}"
        Send "{LWin Up}"
        Table := 0
    }

    
}