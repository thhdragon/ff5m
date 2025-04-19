BEGIN TRANSACTION;

INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('mainsail', 'macros', '{
    "macrogroups":
    {
        "caa2d751-0d1e-4859-adfe-f631022f17d7":
        {
            "name": "3. Peripherals",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "LED_ON",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "LED_OFF",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "CAMERA_RELOAD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "color": "group",
                    "name": "CAMERA_RESTART",
                    "pos": 4,
                    "showInPause": true,
                    "showInPrinting": true,
                    "showInStandby": true
                }
            ]
        },
        "7ac31722-85f9-4771-9b7c-01597bc176fd":
        {
            "name": "2. Calibration",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "AUTO_FULL_BED_LEVEL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "BED_LEVEL_SCREWS_TUNE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "ZSHAPER",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "PID_TUNE_EXTRUDER",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 6,
                    "name": "LOAD_GCODE_OFFSET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 5,
                    "name": "PID_TUNE_BED",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 7,
                    "name": "LOAD_CELL_TARE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "217c7cae-b4cf-4c05-9ff8-11ae55b48cb5":
        {
            "name": "1. Filament",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "COLDPULL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "LOAD_MATERIAL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "M600",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "8a862223-f07a-49c2-b0bd-5473b299abff":
        {
            "name": "4. Mod",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "TAR_BACKUP",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "WEB",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "ZSSH_RELOAD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "START_MOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 5,
                    "name": "STOP_MOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 6,
                    "name": "SKIP_MOD_SOFT",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 7,
                    "name": "REMOVE_MOD_SOFT",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 8,
                    "name": "REMOVE_MOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 9,
                    "name": "SKIP_MOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "b030cdb5-37a7-4280-b3d1-e2cbd1cdcdc0":
        {
            "name": "7. Other",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "CONFIG_BACKUP",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "CONFIG_RESTORE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "CONFIG_VERIFY",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "MEM",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 5,
                    "name": "DATE_GET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 6,
                    "name": "DATE_SET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 7,
                    "name": "SET_TIMEZONE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 8,
                    "name": "TEST_EMMC",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 9,
                    "name": "CLEAR_EMMC",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 10,
                    "name": "TAR_DEBUG",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 11,
                    "name": "LEVELING_PRINT_FILE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 12,
                    "name": "NOLEVELING_PRINT_FILE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 13,
                    "name": "SHELL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 14,
                    "name": "NEW_RESTART",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 15,
                    "name": "NEW_SAVE_CONFIG",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "e2f557e3-e0d5-4986-9f99-01370c9a2b88":
        {
            "name": "5. System",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "CONFIG_BACKUP",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "CONFIG_RESTORE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "CONFIG_VERIFY",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "MEM",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 5,
                    "name": "DATE_GET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 6,
                    "name": "DATE_SET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 7,
                    "name": "SET_TIMEZONE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 8,
                    "name": "TEST_EMMC",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 9,
                    "name": "CLEAR_EMMC",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 10,
                    "name": "TAR_DEBUG",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "e1c75c67-e93c-4d9a-9474-8712ade0c381":
        {
            "name": "6. Pro",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "AIR_CIRCULATION_EXTERNAL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "AIR_CIRCULATION_INTERNAL",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "AIR_CIRCULATION_STOP",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        }
    },
    "mode": "expert"
}');

COMMIT;
