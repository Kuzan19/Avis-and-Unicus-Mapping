--// Формируем таблицу эквивалент "итого_мэпинг_авис"//--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT (
    "Корневой Договор Номер" VARCHAR(64),
	"АВС" VARCHAR(8),
	"ЦФО" VARCHAR(8),
	"КП" VARCHAR(8),
	"Продукт OEBS" VARCHAR(16),
	"Год Договора OEBS" VARCHAR(4),
	"Код ПП" VARCHAR(8)
);

--// Добавляем данные в таблицу AVIS_UU_MAP_CONTRACT из **_Эталон Авис_ИТОГ //--
INSERT INTO IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT
SELECT
    "ag_our_number" "Корневой Договор Номер",
    "Код OEBS АВС 2011" "АВС",
    "Код OEBS ЦФО 2011" "ЦФО",
    "КП 2011" "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП"
FROM STG_FILES."091_Эталон Авис_ИТОГ"
;

--// Добавляем данные в таблицу AVIS_UU_MAP_CONTRACT из STG_AVIS.REPORT_RNP_QV_ALL //--
INSERT INTO IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT

WITH MIN_OP AS (
SELECT
    MIN(ECON_ID) OVER (PARTITION BY AG_OUR_NUMBER ORDER BY OP_DATE DESC, ECON_ID) ECON_ID
FROM STG_AVIS.REPORT_RNP_QV_ALL
)

SELECT
    RNP.AG_OUR_NUMBER "Корневой Договор Номер",
	ABC."Код OEBS АВС 2011" "АВС",
    CFO."Код OEBS ЦФО 2011" "ЦФО",
    KP."Код OEBS КП 2011" "КП",
    '2' "Год Договора OEBS",
    CASE
    	WHEN AGRN.GROUPE_NAME LIKE '%Сбербанк%' THEN 'B301007'
    	WHEN RNP.AG_OUR_NUMBER LIKE '%/459/%' OR RNP.AG_OUR_NUMBER LIKE '%/460/%'
    	    AND RNP.AG_OUR_NUMBER NOT LIKE '%/045/459/%'
    	    AND RNP.AG_OUR_NUMBER NOT LIKE '%/045/460/%'
    	THEN 'B301001'
    	ELSE 'B301000'
    END "Продукт OEBS",
    RNP.ID_DEPARTMENT "Код ПП"
FROM STG_AVIS.REPORT_RNP_QV_ALL RNP
    JOIN MIN_OP ON MIN_OP.ECON_ID = RNP.ECON_ID
    LEFT JOIN STG_FILES."014_справ_кодов_АВС" ABC ON ABC."Тос название Юникус" = 'ДМС/общий' AND ABC."Тос название Юникус" IS NOT NULL
    LEFT JOIN STG_FILES."017_справ_кодов_ЦФО" CFO ON CFO."код_подразделения" = RNP.ID_DEPARTMENT AND CFO."код_подразделения" IS NOT NULL
    LEFT JOIN STG_FILES."015_справ_кодов_КП" KP	ON KP."КП название Юникус" = RNP.CHANNEL_INFO AND KP."КП название Юникус" IS NOT NULL
    LEFT JOIN STG_AVIS.AGREEMENT AGR ON AGR.AG_ID = RNP.AG_ID
        LEFT JOIN STG_AVIS.AGREEMENT_GROUP_NEW AGRN ON AGRN.GROUPE_ID = AGR.GROUPE_ID
WHERE ((AC_CREDIT = '92/1Н' AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)) OR (AC_DEBIT = '22/5Н' OR AC_DEBIT = '91/17'))
AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)
AND NOT EXISTS(
            SELECT
                1
            FROM IDM_MGMT_MAP.AVIS_UU_MAP_CONTRACT AM
            WHERE AM."Корневой Договор Номер" = RNP.AG_OUR_NUMBER
            )
;




