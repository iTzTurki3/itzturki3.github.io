--[[

               
                
                 
             ██████╗░░█████╗░██████╗░░██████╗
             ██╔══██╗██╔══██╗██╔══██╗██╔════╝
             ██████╔╝███████║██████╔╝╚█████╗░
             ██╔═══╝░██╔══██║██╔══██╗░╚═══██╗
             ██║░░░░░██║░░██║██║░░██║██████╔╝
             ╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░


                ========================
                   Made By LEO STORY
                   discord.gg/7N6SFEBaaS
                ========================

]] 

config = {
    General = {
        --[[
            ~ اعدادات عامة ~
            LauncherWebsite : رابط مشغل السينما ! يفضل تخليه مثل ماهو
            ObjectName : اسم اوبجكت السينما
            TextureName : اسم Texture الخاص باوبجكت السينما
            Permission : صلاحية الوصول لاعدادات الشاشة
            TabletCommand : امر اظهار الايباد
            ControlDistance : المسافة المطلوبة للتحكم بالشاشة
            VisualDistance : المسافة المطلوبة لمشاهدة الفيديو
            StopBackground : خلفية توقف الشاشة
        ]]
        LauncherWebsite = "https://Pars.github.io/Pars_cinema.github.io/",
        ObjectName = "v_ilev_cin_screen",
        TextureName = "script_rt_cinscreen",
        Permission = "admin.revive",
        TabletCommand = "PA",
        ControlDistance = 50.0,
        VisualDistance = 100.0,
        StopBackground = "",
    },
    Statics = {
        --[[
            ~ اعدادات الشاشة الثابتة ~
            [هوية الشاشة غير مكرره] = {
                owner : اسم الشاشة
                location : احداثيات الشاشة
            }
            ~ مثال ~
            ["screen_1"] = {
                owner = "الملكية - شاشة 1",
                location = {x = 190.08, y = -996.34, z = 30.09, h = 341.33},
            },
        ]]
        ["screen_1"] = {
            owner = "الملكية",
            -- location = {x = 206.98822021484, y = -1019.0274047852, z = 29.307590484619, h = 0.0},
            location = {192.92483520508,-939.27362060547,23.172962188721, 0.0},
        }
    },
    Logsystem = {
        --[[
            ~ اعدادات اللوق ~
            Enable : تفعيل / الغاء التفعيل
            Username : إسم اللوق
            AvatarUrl : صورة العرض للوق
            WebhookUrl : رابط الويب هوك ( Discord )
            Color : لون اللوق
        ]]
        Enable = true,
        Username = "Pars - Cinema",
        AvatarUrl = "https://media.discordapp.net/attachments/764915307000889374/940154833539829760/unknown.png",
        WebhookUrl = "",
        Color = 10682368,
    },
    Permissions = {}
}