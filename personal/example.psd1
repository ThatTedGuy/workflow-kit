# A personal profile: your own answers for every project you install the kit
# into. Copy this file to personal/profile.psd1 and change the values.
# tools/install.ps1 and /setup read personal/profile.psd1 when it exists; Git
# ignores it, so it stays on your machine. An answers file wins where both set
# a key. See README.md, "Personal profile".
@{
    OWNER             = 'Sam'
    EXPLANATION_LEVEL = 'beginner'       # or 'experienced'
    TOKEN_USE         = 'strict'         # or 'normal'
    MULTIPLE_CHOICE   = 'on'             # or 'off'
    # Add-ons for every project. /setup asks about the others each time.
    AddOns            = @('creative-content')
}
