BEGIN TRANSACTION;

INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('fluidd', 'macros', '{
    "stored":
    [
        {
            "alias": "",
            "categoryId": "e004b7a8-256d-4070-8d81-90a2ccef470b",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "air_circulation_external",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "e004b7a8-256d-4070-8d81-90a2ccef470b",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "air_circulation_internal",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "e004b7a8-256d-4070-8d81-90a2ccef470b",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "air_circulation_stop",
            "visible": true
        },
        {
            "alias": "Установить временную зону",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 5,
            "name": "set_timezone"
        },
        {
            "alias": "Включить ZSSH",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 3,
            "name": "zssh_on"
        },
        {
            "alias": "Тест скорости диска",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 7,
            "name": "test_emmc"
        },
        {
            "alias": "Очистить диск",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 8,
            "name": "clear_emmc"
        },
        {
            "alias": "Выключить ZSSH",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 4,
            "name": "zssh_off"
        },
        {
            "alias": "Рестарт ZSSH",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 6,
            "name": "zssh_restart"
        },
        {
            "alias": "",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 5,
            "name": "zssh_reload"
        },
        {
            "alias": "Архивировать конфиг",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 9,
            "name": "tar_config"
        },
        {
            "alias": "Остановить мод",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 8,
            "name": "stop_zmod"
        },
        {
            "alias": "Запустить мод",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 7,
            "name": "start_zmod"
        },
        {
            "alias": "Текущее время",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 4,
            "name": "date_get"
        },
        {
            "alias": "Сменить веб интерфейс",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 2,
            "name": "web"
        },
        {
            "alias": "Изменить время",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 6,
            "name": "date_set"
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "check_md5",
            "visible": false
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "set_fan_speed"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "line_purge"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "g17"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "g18"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "g19"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "kamp"
        },
        {
            "alias": "Расход памяти",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 3,
            "name": "mem"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "order": 11,
            "name": "reboot"
        },
        {
            "alias": "",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "reboot",
            "visible": true
        },
        {
            "alias": "ОЧИСТИТЬ СОПЛО",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "85e2f576-74e1-4bd3-9e82-fca937d1d3ce",
            "order": 3,
            "name": "clear_nozzle"
        },
        {
            "alias": "Выключить принтер",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "name": "shutdown"
        },
        {
            "alias": "Перезагрузка в сток",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 9,
            "name": "skip_zmod"
        },
        {
            "alias": "",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 10,
            "name": "soft_remove"
        },
        {
            "alias": "Отключить ZMOD камеру",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "camera_off",
            "visible": true
        },
        {
            "alias": "Включить ZMOD камеру",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "camera_on",
            "visible": true
        },
        {
            "alias": "Выключить экран принтера",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "display_off",
            "visible": true
        },
        {
            "alias": "Включить экран принтера",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "display_on",
            "visible": true
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m106"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m107"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m300"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m356"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m357"
        },
        {
            "alias": "Удалить мод",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 11,
            "name": "remove_zmod"
        },
        {
            "alias": "Калибровка стола",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "auto_full_bed_level",
            "visible": true
        },
        {
            "alias": "Калибровка шейперов",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "zshaper",
            "visible": true
        },
        {
            "alias": "Регулировка винтов стола",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "bed_level_screws_tune",
            "visible": true
        },
        {
            "alias": "Восстановить Z-offset",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "load_gcode_offset",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "set_gcode_offset",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "save_gcode_offset",
            "visible": false
        },
        {
            "alias": "ОТМЕНИТЬ ПЕЧАТЬ",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "85e2f576-74e1-4bd3-9e82-fca937d1d3ce",
            "order": 2,
            "name": "cancel_print"
        },
        {
            "alias": "LED",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
            "order": 3,
            "name": "led"
        },
        {
            "alias": "LED OFF",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
            "order": 1,
            "name": "led_off"
        },
        {
            "alias": "LED ON",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
            "order": 0,
            "name": "led_on"
        },
        {
            "alias": "Калибровка PID стола",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "pid_tune_bed",
            "visible": true
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "order": 10,
            "name": "play_midi"
        },
        {
            "alias": "ВОЗОБНОВИТЬ",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "85e2f576-74e1-4bd3-9e82-fca937d1d3ce",
            "order": 1,
            "name": "resume"
        },
        {
            "alias": "Калибровка PID экструдера",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "pid_tune_extruder",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "coldpull",
            "visible": true
        },
        {
            "alias": "Загрузить нить",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "load_material",
            "visible": true
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "name": "load_filament"
        },
        {
            "alias": "ПАУЗА",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "85e2f576-74e1-4bd3-9e82-fca937d1d3ce",
            "order": 0,
            "name": "pause"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "name": "purge_filament"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "name": "unload_filament"
        },
        {
            "alias": "Пауза + смена филамента",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m600",
            "visible": true
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "m900"
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "bed_mesh_calibrate",
            "visible": false
        },
        {
            "alias": "Сбросить тензодатчики",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "load_cell_tare",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "end_print",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "set_pause_at_layer",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "set_pause_next_layer",
            "visible": true
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "name": "set_print_stats_info"
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "start_print",
            "visible": false
        },
        {
            "alias": "Закрыть диалоги",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "order": 4,
            "name": "close_dialogs"
        },
        {
            "alias": "Печать файла + leveling",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "leveling_print_file",
            "visible": true
        },
        {
            "alias": "",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "noleveling_print_file",
            "visible": true
        },
        {
            "alias": "Быстро закрыть диалоги",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "order": 5,
            "name": "fast_close_dialogs"
        },
        {
            "alias": "Получить параметры ZMOD",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "get_zmod_data"
        },
        {
            "alias": "Сохранить изменения",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 1,
            "name": "new_save_config"
        },
        {
            "alias": "Сохранить параметры ZMOD",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "save_zmod_data",
            "visible": true
        },
        {
            "alias": "Создать резервную копию",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 0,
            "name": "config_backup"
        },
        {
            "alias": "Восстановить резервную копию",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 2,
            "name": "config_restore"
        },
        {
            "alias": "Обновить камеру",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
            "order": 2,
            "name": "camera_reload"
        },
        {
            "alias": "Проверить конфигурацию",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "order": 1,
            "name": "config_verify"
        },
        {
            "alias": "Бэкап конфигурации",
            "visible": true,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "order": 0,
            "name": "backup_tar"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "beep"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "g28"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "move_safe"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "wait"
        },
        {
            "alias": "",
            "visible": false,
            "disabledWhilePrinting": false,
            "color": "",
            "categoryId": "0",
            "name": "set_led"
        }
    ],
    "categories":
    [
        {
            "id": "85e2f576-74e1-4bd3-9e82-fca937d1d3ce",
            "name": "Печать"
        },
        {
            "id": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
            "name": "Периферия"
        },
        {
            "id": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "name": "Калибровка"
        },
        {
            "id": "89ac157d-a16a-43f1-900a-498d683bf557",
            "name": "Филамент"
        },
        {
            "id": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "name": "Без экрана"
        },
        {
            "id": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
            "name": "Мод"
        },
        {
            "id": "24e79f79-c9db-4e2b-aab3-ed7e5b568d3d",
            "name": "Система"
        },
        {
            "id": "e004b7a8-256d-4070-8d81-90a2ccef470b",
            "name": "Pro"
        }
    ]
}');

INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('mainsail', 'macros', '{
    "macrogroups":
    {
        "caa2d751-0d1e-4859-adfe-f631022f17d7":
        {
            "name": "3. Периферия",
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
                }
            ]
        },
        "7ac31722-85f9-4771-9b7c-01597bc176fd":
        {
            "name": "2. Калибровка",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "LOAD_GCODE_OFFSET",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "PID_TUNE_BED",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "PID_TUNE_EXTRUDER",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "ZSHAPER",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "217c7cae-b4cf-4c05-9ff8-11ae55b48cb5":
        {
            "name": "1. Филамент",
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
            "name": "4. Мод",
            "color": "primary",
            "colorCustom": "#fff",
            "showInStandby": true,
            "showInPause": true,
            "showInPrinting": true,
            "macros":
            [
                {
                    "pos": 1,
                    "name": "BACKUP_TAR",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 2,
                    "name": "NEW_SAVE_CONFIG",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 3,
                    "name": "WEB",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 4,
                    "name": "ZSSH_RELOAD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 5,
                    "name": "START_ZMOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 6,
                    "name": "STOP_ZMOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 7,
                    "name": "SKIP_ZMOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 8,
                    "name": "SOFT_REMOVE",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                },
                {
                    "pos": 9,
                    "name": "REMOVE_ZMOD",
                    "color": "group",
                    "showInStandby": true,
                    "showInPrinting": true,
                    "showInPause": true
                }
            ]
        },
        "b030cdb5-37a7-4280-b3d1-e2cbd1cdcdc0":
        {
            "name": "",
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
                    "name": "TAR_CONFIG",
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