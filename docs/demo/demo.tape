# Records the code explorer demo. Run docs/demo/build.sh, which also turns the video into demo.gif.
Output demo.mp4
Set Shell "bash"
Set Framerate 12
Set FontFamily "JetBrainsMono Nerd Font"
Set FontSize 14
Set Width 1280
Set Height 740
Set Padding 8
Set Theme "rose-pine-moon"
Set TypingSpeed 0.25s

# start nvim off camera, with the key overlay (docs/demo/keys.lua) loaded
Hide
Type "cd /work-billing && nvim -c 'luafile /root/.config/nvim/docs/demo/keys.lua' billing/invoice.py"
Enter
Sleep 7s
Type ":call cursor(13,13)"
Enter
Sleep 1s
Show
Sleep 2s

# 1. explorer mode on apply_tax: map, code, callers/callees/tests
Type " kk"
Sleep 5s

# 2. Tab to the context panel, jump to a callee
Tab
Sleep 1.5s
Type@400ms "jjjjjjjjjjj"
Sleep 1.5s
Enter
Sleep 3s

# 3. import graph: round_money sits in a cycle
Type " kg"
Sleep 4s
Type "d"
Sleep 3s
Type "q"
Sleep 1s

# 4. breakpoint in round_money, then go to the tests through the project map
Type@400ms "jjjj"
Type " db"
Sleep 2s
Tab
Sleep 0.5s
Tab
Sleep 1s
Type "/tests"
Enter
Sleep 1s
Enter
Sleep 1s
Type@400ms "j"
Sleep 0.5s
Enter
Sleep 2s

# 5. run the tests, then debug the failure
Type " tf"
Sleep 10s
Type " kd"
Sleep 12s
Type " du"
Sleep 2s
Type " dc"
Sleep 6s
