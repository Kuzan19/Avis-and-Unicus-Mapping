--// Формируем таблицу эквивалент "итого_мэпинг_авис"//--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT (
    "Корневой договор номер" VARCHAR(64),
	"АВС" VARCHAR(8),
	"ЦФО" VARCHAR(8),
	"КП" VARCHAR(8),
	"Код ПП" VARCHAR(8),
	"Год договора OEBS" VARCHAR(4),
	"Продукт OEBS" VARCHAR(16)
);

--// Добавляем данные в таблицу AVIS_UU_MAP_CONTRACT из **_Эталон Авис_ИТОГ //--
INSERT INTO IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT (
    "Корневой договор номер",
	"АВС",
	"ЦФО",
	"КП",
	"Код ПП",
	"Год договора OEBS",
	"Продукт OEBS"
)
    SELECT
	    "ag_our_number",
	    "Код OEBS АВС 2011",
	    "Код OEBS ЦФО 2011",
	    "КП 2011",
	    "Код ПП",
	    "Год договора OEBS",
	    "Продукт OEBS"
    FROM STG_FILES."091_Эталон Авис_ИТОГ"
;

--// Добавляем данные в таблицу AVIS_UU_MAP_CONTRACT из STG_AVIS.REPORT_RNP_QV_ALL //--
INSERT INTO IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT (
    "Корневой договор номер",
    "АВС",
    "ЦФО",
    "КП",
    "Код ПП",
    "Год договора OEBS",
    "Продукт OEBS"
    )

    SELECT
        "Корневой договор номер",
        "Код АВС",
        "Код ЦФО",
        "Код OEBS КП 2011",
        "Подразделение код",
        "Продукт OEBS",
        '2' "Год договора OEBS"
    FROM (
        SELECT
            RNP.AG_OUR_NUMBER,
            CFO."Код OEBS ЦФО 2011" "Код ЦФО",
    	    ABC."Код OEBS АВС 2011" "Код АВС",
    	    KP."Код OEBS КП 2011",
    	    CASE
	        	WHEN AGRN.GROUPE_NAME LIKE '%Сбербанк%' THEN 'B301007'
	        	WHEN RNP.AG_OUR_NUMBER LIKE '%/459/%' OR TMP.AG_OUR_NUMBER LIKE '%/460/%'
	        	    AND RNP.AG_OUR_NUMBER NOT LIKE '%/045/459/%'
	        	    AND RNP.AG_OUR_NUMBER NOT LIKE '%/045/460/%'
	        	THEN 'B301001'
	        	ELSE 'B301000'
	        END "Продукт OEBS"
	    FROM STG_AVIS.REPORT_RNP_QV_ALL RNP

	    LEFT JOIN STG_FILES."017_справ_кодов_ЦФО" CFO
    	ON TMP."Подразделение код" = TO_CHAR(CFO."код_подразделения") AND CFO."код_подразделения" IS NOT NULL

        LEFT JOIN STG_FILES."014_справ_кодов_АВС" ABC
        	ON TMP."ТОС название" = ABC."Тос название Юникус" AND ABC."Тос название Юникус" IS NOT NULL

        LEFT JOIN STG_FILES."015_справ_кодов_КП" KP
        	ON TMP."Канал название" = KP."КП название Юникус" AND KP."КП название Юникус" IS NOT NULL

        LEFT JOIN STG_AVIS.AGREEMENT AGR
            ON AGR.AG_ID = RNP.AG_ID

        LEFT JOIN STG_AVIS.AGREEMENT_GROUP_NEW AGRN
            ON AGRN.GROUPE_ID = AGR.GROUPE_ID

        WHERE (AC_CREDIT = '92/1Н' AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)) OR
        (AC_DEBIT = '22/5Н' OR AC_DEBIT = '91/17') AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)) AMG
    GROUP BY "Корневой договор номер"
    WHERE NOT EXISTS(
        SELECT
            1
        FROM IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT AM
        WHERE AM."Корневой договор номер" = AMG."Корневой договор номер ")
    ORDER BY AG_OUR_NUMBER
    ORDER BY OP_DATE
    ORDER BY ENTRY_ID
    LIMIT 1
;




