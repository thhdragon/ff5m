BEGIN TRANSACTION;

WITH cte AS (SELECT '$.stored' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "alias": "CAMERA RESTART",
        "categoryId": "4074e4ed-d0d6-4da3-9924-9412e48bbefa",
        "color": "",
        "disabledWhilePrinting": false,
        "name": "camera_restart",
        "visible": true
    }')
)
WHERE namespace = 'fluidd' AND key = 'macros';

INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('fluidd', 'uiSettings', '{
    "general": {
        "axis": { "z": { "inverted": true } }
    }
}');


WITH cte AS (SELECT '$.macrogroups.caa2d751-0d1e-4859-adfe-f631022f17d7.macros' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "CAMERA_RESTART",
        "pos": 4,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('mainsail', 'control', '{
    "feedrateXY": "300",
    "feedrateZ": "60",
    "hideDuringPrint": true,
    "reverseZ": true,
    "selectedCrossStep": 4,
    "style": "cross"
}');

COMMIT;
