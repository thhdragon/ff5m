#!/bin/sh

# This script will close "Printing Cancelled" or "Printing Finished"
# dialogs shown on FlashForge Adventurer 5M(Pro) screen by
# original QT factory application.
##
## This script needs working GDB for operation.
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
## Copyright (c) 2024, Dark Simpson
##
## This file may be distributed under the terms of the GNU GPLv3 license

unset LD_LIBRARY_PATH
unset LD_PRELOAD
export PATH="$PATH:/opt/bin:/opt/sbin"

pid=$(ps | grep "[f]irmwareExe" | awk '{print $1}')

if [ -n "$pid" ]; then
    echo Screen executable PID is "$pid", calling GDB to perform manipulations...

    exec gdb -q <<EOF
# All black magic is done in this GDB script.
# Do not modify anything if you don't understand it!!!

# Do not load all symbold from shared libraries, we do not need them all
set auto-solib-add off

# Attach to our process to perform manipulations
attach $pid

# Check CancelDialog is opened
if (_ZN12CancelDialog16instCancelDialogE != 0)
  if (_ZN12CancelDialog13setStateClearEv != 0)
    call _ZN12CancelDialog13setStateClearEv(_ZN12CancelDialog16instCancelDialogE)
  else
    echo "Error: Failed to dismiss Cancel dialog!\n"  
  end
else
  echo "Cancel dialog not found!\n"
end

# Check CompletePrintDialog is opened
if (_ZN19CompletePrintDialog23instCompletePrintDialogE != 0)
  if (_ZN19CompletePrintDialog13setStateClearEv != 0)
    call _ZN19CompletePrintDialog13setStateClearEv(_ZN19CompletePrintDialog23instCompletePrintDialogE)
  else
    echo "Error: Failed to dismiss Complete dialog!\n"  
  end
else
  echo "Complete print dialog not found!\n"
end

# Check ConfirmDialog is opened
if (_ZN13ConfirmDialog17instConfirmDialogE != 0)
  if (_ZN13ConfirmDialog16on_close_clickedEv != 0)
    call _ZN13ConfirmDialog16on_close_clickedEv(_ZN13ConfirmDialog17instConfirmDialogE)
  else
    echo "Error: Failed to dismiss Confirm dialog!\n"  
  end
else
  echo "Confirm dialog not found!\n"
end

# Detach from our process, leave it run freely
detach

# Quit debugger
quit
EOF

fi
