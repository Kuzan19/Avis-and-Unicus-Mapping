--Создаем таблицу "АВИС" на основе таблицы "REPORT_RNP_QV_ALL"
CREATE OR REPLACE TABLE IDM_MNGL_MAPPING.AVIS AS (
	SELECT
		RNP.*,
		MPE.ECON_DATE
	FROM STG_AVIS.REPORT_RNP_QV_ALL RNP
	LEFT JOIN STG_AVIS.MAV_PARUS_ECON MPE
	    ON RNP.ECON_ID = MPE.ECON_ID
);

--Создаем таблицу "Журнал Авис"
CREATE OR REPLACE TABLE IDM_MNGL_MAPPING."Журнал Авис" AS (

    SELECT IDM_MNGL_MAPPING.AVIS_JOURNAL.*,
	    CASE
	    	WHEN GROUPE_NAME LIKE '%Сбербанк%' THEN 'B301007'
	    	WHEN ("номер корневого договора" LIKE '%/459/%' OR "номер корневого договора" LIKE '%/460/%')
	    	    AND "номер корневого договора" NOT LIKE '%/045/459/%'
	    	    AND "номер корневого договора" NOT LIKE '%/045/460/%'
	    	THEN 'B301001'
	    	ELSE 'B301000'
	    END "Продукт OEBS"
    FROM (
        WITH  AVIS_MAPP_TEMP AS (
            SELECT
                COMPANY "Код филиала",
        	    ID_DEPARTMENT "Подразделение код",
        	    "NAME" "Подразделение название",
        	    CHANNEL_ID,
                TO_CHAR(CHANNEL_INFO) "Канал название",
        	    AG_ID "Договор ID",
        	    AG_OUR_NUMBER "Корневой договор номер",
        	    AG_OUR_NUMBER "Договор номер",
        	    INSURER "Страхователь",
        	    TO_DATE(OP_DATE) "Дата начисления",
        	    TO_DATE(ECON_DATE) "Дата подтверждения",
        	    OPR_SUM_R "Сумма",
        	    OPR_SUM_D "Сумма депозит",
        	    TO_DATE(NVL(AM_START_DATE, OP_DATE)) "Дата начала ответственности",
        	    'Премия' "Тип",
        	    'ДМС/общий' "ТОС название",
        	    'Авис' "Система",
        	    '1' "Тип перестрахование"
            FROM IDM_MNGL_MAPPING.AVIS
            WHERE AC_CREDIT = '92/1Н' AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)

            UNION ALL

            SELECT
            	COMPANY "Филиал код",
            	ID_DEPARTMENT "Подразделение код",
            	"NAME" "Подразделение название",
            	CHANNEL_ID,
            	TO_CHAR(CHANNEL_INFO) "Канал название",
            	AG_ID "Договор ID",
            	AG_OUR_NUMBER "Номер корневого договора",
            	AG_OUR_NUMBER "Договор Номер",
            	INSURER "Страхователь",
            	TO_DATE(OP_DATE) "Дата начисления",
        	    TO_DATE(ECON_DATE) "Дата подтверждения",
            	-1 * OPR_SUM_R "Сумма",
            	-1 * OPR_SUM_D "Сумма_депозит",
            	TO_DATE(NVL(AM_START_DATE, OP_DATE)) "Дата начала ответственности",
            	'Расторжение' "Тип",
            	'ДМС/общий' "ТОС название",
            	'Авис' "Система",
            	'1' "Тип перестрахования"
            FROM IDM_MNGL_MAPPING.AVIS
            WHERE (AC_DEBIT = '22/5Н' OR AC_DEBIT = '91/17') AND (IS_LOADED <> 'не начисл. в Парус' OR IS_LOADED IS NULL)
            )

        SELECT
    	    TMP.*,
    	    STG_FILES."017_справ_кодов_ЦФО"."Код OEBS ЦФО 2011" "Код ЦФО",
    	    STG_FILES."014_справ_кодов_АВС"."Номер строчки",
    	    TO_CHAR(STG_FILES."014_справ_кодов_АВС"."Код OEBS АВС 2011") "Код АВС",
    	    STG_FILES."015_справ_кодов_КП"."Код OEBS КП 2011",
    	    GROUPE_ID,
    	    GROUPE_NAME
        FROM AVIS_MAPP_TEMP TMP

    	LEFT JOIN STG_FILES."017_справ_кодов_ЦФО" CFO
    		ON TMP."Подразделение код" = TO_CHAR(CFO."код_подразделения") AND CFO."код_подразделения" IS NOT NULL

    	LEFT JOIN STG_FILES."014_справ_кодов_АВС" ABC
    		ON TMP."ТОС название" = ABC."Тос название Юникус" AND ABC."Тос название Юникус" IS NOT NULL

    	LEFT JOIN STG_FILES."015_справ_кодов_КП" KP
    		ON TMP."Канал название" = KP."КП название Юникус" AND KP."КП название Юникус" IS NOT NULL

    	LEFT JOIN (SELECT DISTINCT
    			    AG_ID,
    			    GROUPE_ID
    		    FROM STG_AVIS.AGREEMENT)
    	    ON AG_ID = TMP."Договор ID"

    	LEFT JOIN (SELECT DISTINCT
    			    GROUPE_ID "Группа",
    			    GROUPE_NAME
    		    FROM STG_AVIS.AGREEMENT_GROUP_NEW)
    	    ON GROUPE_ID = "Группа"
    )
);

--Создаем таблицу мэппинга "Avis_mapp"
CREATE OR REPLACE TABLE IDM_MNGL_MAPPING.AVIS_MAPP AS (
    SELECT
	    "ag_our_number",
	    TO_CHAR("Код OEBS АВС 2011") "АВС",
	    TO_CHAR("Код OEBS ЦФО 2011") "ЦФО",
	    TO_CHAR("КП 2011") "КП",
	    TO_CHAR("Код ПП") "Код ПП",
	    "Год договора OEBS",
	    CAST("Продукт OEBS" AS VARCHAR(7)) "Продукт OEBS"
    FROM STG_FILES."502_Эталон Авис_ИТОГ"
);

--Добавляем данные в таблицу мэппинга "Avis_mapp"
INSERT INTO IDM_MNGL_MAPPING.AVIS_MAPP(
	"ag_our_number",
	"АВС",
	"ЦФО",
	"КП",
	"Код ПП",
	"Продукт OEBS",
	"Год договора OEBS")

    WITH AVIS_MAPP_GR AS (
        SELECT
        	"Корневой договор номер " "ag_our_number_GR",
        	TO_CHAR(FIRST_VALUE("Код АВС")) "КОД OEBS АВС 2011",
        	TO_CHAR(FIRST_VALUE("Код ЦФО")) "КОД OEBS ЦФО 2011",
        	TO_CHAR(FIRST_VALUE("Код OEBS КП 2011")) "КП 2011",
        	TO_CHAR(FIRST_VALUE("Подразделение код")) "КОД ПП GR",
        	TO_CHAR(FIRST_VALUE("Продукт OEBS")) "Продукт OEBS"
        FROM IDM_MNGL_MAPPING."Журнал Авис"
        GROUP BY "Корневой договор номер "
        )

    SELECT
    	"ag_our_number_GR",
    	"КОД OEBS АВС 2011",
    	"КОД OEBS ЦФО 2011",
    	"КП 2011",
    	"КОД ПП GR",
    	"Продукт OEBS",
    	'2'
    FROM AVIS_MAPP_GR AMG
    WHERE NOT EXISTS(
        SELECT "ag_our_number"
        FROM IDM_MNGL_MAPPING.AVIS_MAPP AM
        WHERE AM."ag_our_number" = AMG."ag_our_number_GR"
);




