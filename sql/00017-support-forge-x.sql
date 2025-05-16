BEGIN TRANSACTION;

WITH cte AS (SELECT '$.stored' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "alias": "SUPPORT FORGE-X",
        "categoryId": "d83c5e21-865d-43fd-bf2f-2dfda34ff3af",
        "color": "#882a56",
        "disabledWhilePrinting": false,
        "name": "support_forge_x",
        "visible": true
    }')
)
WHERE namespace = 'fluidd' AND key = 'macros';


WITH cte AS (SELECT '$.macrogroups.8a862223-f07a-49c2-b0bd-5473b299abff.macros' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "SUPPORT_FORGE_X",
        "pos": 10,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

COMMIT;
