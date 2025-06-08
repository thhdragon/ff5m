BEGIN TRANSACTION;

WITH cte AS (SELECT '$.macrogroups.8a862223-f07a-49c2-b0bd-5473b299abff.macros' AS path)
UPDATE namespace_store
SET value = json_insert(value, printf("%s[%i]", (SELECT path FROM cte), json_array_length(json_extract(value, (SELECT path FROM cte)))),
    json('{
        "color": "group",
        "name": "LIST_MOD_PARAMS",
        "pos": 11,
        "showInPause": true,
        "showInPrinting": true,
        "showInStandby": true
    }')
)
WHERE namespace = 'mainsail' AND key = 'macros';

COMMIT;
