#!/bin/bash

gdb -iex "set demangle-style none" --args /usr/bin/telegram-desktop "$@" << EOF
tbreak _ZN3App9initMediaEv
commands
    # Makes pin not notify all by default
    set {int}(_ZN13PinMessageBox7prepareEv+488) = 0x0
    # - b9 01 00 00 00    mov $0x1,%ecx
    # + b9 00 00 00 00    mov $0x0,%ecx



    # Makes deletion delete for everyone by default
    set {char}(_ZN17DeleteMessagesBox7prepareEv+3064) = 0xfe
    # - 31 c9   xor %ecx,%ecx
    # + fe c9   inc %ecx 



    # Remove conditional jumps in toggleTabbedSelectorMode to never put a sidebar
    set {char [2]}(_ZN13HistoryWidget24toggleTabbedSelectorModeEv+77) = { 0x90, 0x90 }
    # - 75 59                 jne 0x10b5468
    # + 90 90                 nop nop

    set {char [2]}(_ZN13HistoryWidget24toggleTabbedSelectorModeEv+89) = { 0x90, 0x90 }
    # - 74 45                 je 0x10b5460
    # + 90 90                 nop nop

    set {char [2]}(_ZN13HistoryWidget24toggleTabbedSelectorModeEv+96) = { 0x90, 0x90 }
    # - 74 3e                 je 0x10b5460
    # + 90 90                 nop nop

    # When hover over emoji button, dont do anything, just return
    set {char [5]}(_ZN11ChatHelpers11TabbedPanel10otherEnterEv+0) = { 0xc3, 0x90, 0x90, 0x90, 0x90 }
    # - e9 ab ff ff ff        jmp sym.ChatHelpers::TabbedPanel::showAnimated
    # + c3 90 90 90 90        ret; nop nop nop nop
end
run
detach
quit
EOF
