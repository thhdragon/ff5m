DELETE FROM "main"."namespace_store"  WHERE namespace="fluidd" AND key="macros";
INSERT INTO "main"."namespace_store" ("namespace", "key", "value") VALUES ('fluidd', 'macros', '{
    "categories": [
        {
            "id": "e004b7a8-256d-4070-8d81-90a2ccef470b",
            "name": "4. Pro"
        },
        {
            "id": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "name": "2. Система"
        },
        {
            "id": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "name": "1. Калибровки"
        },
        {
            "id": "944c031b-feef-4b75-badf-21c30508fb24",
            "name": "0. Основное"
        },
        {
            "id": "89ac157d-a16a-43f1-900a-498d683bf557",
            "name": "3. Филамент"
        },
        {
            "id": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "name": "5. Без экрана"
        }
    ],
    "expanded": [
        0,
        1
    ],
    "stored": [
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
            "alias": "Текущее время",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "date_get",
            "visible": true
        },
        {
            "alias": "Изменить время",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "date_set",
            "visible": true
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
            "alias": "Расход памяти",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "mem",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "reboot",
            "visible": true
        },
        {
            "alias": "Выключить принтер",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "shutdown",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "skip_zmod",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "soft_remove",
            "visible": true
        },
        {
            "alias": "Отключить ZMOD камеру",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "camera_off",
            "visible": true
        },
        {
            "alias": "Включить ZMOD камеру",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "camera_on",
            "visible": true
        },
        {
            "alias": "Выключить экран принтера",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "display_off",
            "visible": true
        },
        {
            "alias": "Включить экран принтера",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "display_on",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m106",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m107",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m300",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m356",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m357",
            "visible": false
        },
        {
            "alias": "Удалить ZMOD",
            "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "remove_zmod",
            "visible": true
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
            "alias": "Регулировка винтов стола",
            "categoryId": "244d667b-c410-4e01-9bf1-e8e0b9deabe2",
            "color": "",
            "disabledWhilePrinting": true,
            "name": "bed_level_screws_tune",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "bed_temperature_wait",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "set_bed_temperature",
            "visible": false
        },
        {
            "alias": "Отменить печать",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "cancel_print",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "led",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "led_off",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "led_on",
            "visible": true
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
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "play_midi",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "resume",
            "visible": true
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
            "name": "load_filament",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "load_material",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "944c031b-feef-4b75-badf-21c30508fb24",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "pause",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "purge_filament",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "89ac157d-a16a-43f1-900a-498d683bf557",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "unload_filament",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m600",
            "visible": false
        },
        {
            "alias": "",
            "categoryId": "0",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "m900",
            "visible": false
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
            "visible": true
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
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "set_print_stats_info",
            "visible": true
        },
        {
            "alias": "",
            "categoryId": "5ceaef9c-2e66-4bbf-998b-94fcab116597",
            "color": "",
            "disabledWhilePrinting": false,
            "name": "start_print",
            "visible": true
        }
    ]
}');
