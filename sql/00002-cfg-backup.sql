BEGIN TRANSACTION;

WITH cte AS (SELECT '$.stored' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "alias": "Создать резервную копию",
        "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
        "color": "",
        "disabledWhilePrinting": false,
        "name": "config_backup",
        "visible": true
    }')
)
WHERE namespace = 'fluidd' AND key = 'macros';

WITH cte AS (SELECT '$.stored' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "alias": "Восстановить резервную копию",
        "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
        "color": "",
        "disabledWhilePrinting": false,
        "name": "config_restore",
        "visible": true
    }')
)
WHERE namespace = 'fluidd' AND key = 'macros';

WITH cte AS (SELECT '$.stored' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "alias": "Обновить ZMOD камеру",
        "categoryId": "0077449b-cd10-4059-aebd-bf17be6cb270",
        "color": "",
        "disabledWhilePrinting": false,
        "name": "camera_reload",
        "visible": true
    }')
)
WHERE namespace = 'fluidd' AND key = 'macros';



WITH cte AS (SELECT '$.macrogroups.9c23dcdb-a9bf-49fe-9473-12b149deb188' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "CONFIG_BACKUP",
        "pos": 24,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

WITH cte AS (SELECT '$.macrogroups.9c23dcdb-a9bf-49fe-9473-12b149deb188' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "CONFIG_RESTORE",
        "pos": 25,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

WITH cte AS (SELECT '$.macrogroups.9c23dcdb-a9bf-49fe-9473-12b149deb188' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "CAMERA_RELOAD",
        "pos": 26,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

COMMIT;
