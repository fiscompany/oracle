CREATE OR REPLACE PACKAGE BODY orient.MARINE_ENDORSEMENT_PKG

AS
-- This is a copy of the Hora PACKAGE default template. Please modify file
-- C:\Program Files\KeepTool-11\Bin\Templates\ or change file name in the registry below
-- HKEY_CURRENT_USER\Software\KeepTool\Hora\11.0\Forms\dmPlSql\Templates

 PROCEDURE ADD_INSUR_OBJECTS_END_PR(
 --  ملحق تعديل الاعيان المؤمنة
 -- اضافة
            ENDORSEMENT_DATE_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
            APP_ID_IN                IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
            INSURED_OBJECT_DESC_IN   IN END_MARINE_CARGO_INS_PROPS_TB.INSURED_OBJECT_DESC%TYPE,
            COVERAGE_CONDITION_ID_IN IN END_MARINE_CARGO_INS_PROPS_TB.COVERAGE_CONDITION_ID%TYPE,
            GEO_AREA_ID_IN           IN END_MARINE_CARGO_INS_PROPS_TB.GEO_AREA_ID%TYPE,
            RISK_DEGREE_ID_IN        IN END_MARINE_CARGO_INS_PROPS_TB.RISK_DEGREE_ID%TYPE,
            DISCOUNT_VALUE_IN        IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
            PREMIUM_VALUE_IN         IN NUMBER,
            ADDITIONAL_AMOUNT_IN     IN NUMBER,
            PROPORTIONAL_FEE_PER_IN  IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_PER%TYPE,
            PROPORTIONAL_FEE_VAL_IN  IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_VAL%TYPE,
            ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
            NOTES_IN                 IN ENDORSEMENTS_TB.NOTES%TYPE,
            CREATED_BY_IN            IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
            LANG_IN                  IN VARCHAR2,
            ENDORSEMENT_ID_OUT       OUT NOCOPY NUMBER ,
            ERR_DESC_OUT             OUT NOCOPY VARCHAR2,
            ERR_STATUS_OUT           OUT NOCOPY NUMBER )
AS
            POLICY_ID_V                 NUMBER;
            PROPOSAL_ID_V               NUMBER;
            POLICY_TYPE_V               NUMBER := 7;
            ENDORSEMENT_NUM_V           NUMBER := 13;
            ENDORSEMENT_FEES_V          NUMBER ;
            CNT                         NUMBER;
            CURR_ID_V                   NUMBER;
            EQ_PRICE_V                  NUMBER ;

            POLICY_STATUS_ID_V          NUMBER ;
            INSURANCE_STARTING_DATE_V   DATE;
            INSURANCE_ENDING_DATE_OLD_V DATE;
            INSURANCE_VALUE_OLD_V       NUMBER ;
            INSURRANCE_VALUE_EQ_OLD_V   NUMBER ;
            AMOUNT_PAID_OLD_V           NUMBER ;
            INSURANCE_ENDING_DATE_V     DATE;
            INSURANCE_VALUE_NEW_V       NUMBER;

            ENDORSEMENT_ID_V            NUMBER;

            BRANCH_ID_V                 NUMBER ;
            OFFICE_ID_V                 NUMBER ;
            AGENT_ID_V                  NUMBER ;
            REPRESENTATIVE_ID_V         NUMBER ;
            EMP_ID_V                    NUMBER ;
            CUST_ID_V                   NUMBER ;

            NEW_INSTALLMENT_COUNT_V     NUMBER :=0;
            PAYMENT_METHOD_ID_IN        NUMBER :=0;
            PAYMENT_DUE_ID_IN           NUMBER :=0;
            DUE_DATE_IN                 DATE :=SYSDATE;
            ENDORSEMENT_VALUE_V         NUMBER;
            TOTAL_VALUE_V               NUMBER;
            OLD_PROP_DISCOUNT_VALUE_V   NUMBER;
            PREV_ENDORSEMENT_ID_V       NUMBER;
            END_CNT                     NUMBER;
            ENDORSEMENT_FEES_EQ_V       NUMBER;
            PROPORTIONAL_FEE_VAL_EQ_V   NUMBER;
BEGIN
        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------
        -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data
        SELECT
            POLICY_ID , INS_CURR_ID , PROPOSAL_ID
        INTO
            POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        --------------------
        SELECT COUNT(*) INTO END_CNT
        FROM
            END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;
       -- نسخ البيانات الى الهيستوي

       IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

           --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;
       END IF ;

       -- فحص إذا كانت البوليصة منتهية
       IF TRUNC(INSURANCE_ENDING_DATE_OLD_V) < TRUNC(SYSDATE) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.200',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

       SELECT
           POLICY_STATUS_ID
       INTO
           POLICY_STATUS_ID_V
       FROM POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;

       -- فحص إذا كانت البوليصة ملغية
       IF POLICY_STATUS_ID_V = 2 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.201',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

        -- فحص هل الطلب له ملحق وغير مصدر

        SELECT  COUNT(*)  INTO  CNT
        FROM ENDORSEMENTS_TB
        WHERE
            POLICY_ID = POLICY_ID_V
            AND POLICY_TYPE_ID = POLICY_TYPE_V
            AND ISSUED_BY IS  NULL ;

        IF CNT > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.169,LANG_IN,SQLERRM);
              RETURN;
        END IF ;

       -- GET   ENDORSEMENT_FEES VALUE
       --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
       ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);


       ------------------------------------------
         -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);


       ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

       PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

       ---------------------------------------------------
       ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

       TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

       INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

       --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);


       -- تخزين بيانات الملحق
       -- ENDORSEMENT_TYPE_ID يحمل رقم 13 للتأمين البحري

       MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            NULL  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            CREATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

       -- COPY DATA TO ENDORSMENTS TABLE
       COPY_DATA_TO_END_PR (
            ENDORSEMENT_ID_OUT,
            APP_ID_IN,
            LANG_IN,
            ERR_DESC_OUT,
            ERR_STATUS_OUT);

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

       -- حذف الأعيان المؤمنة
        DELETE FROM END_MC_INSURED_OBJECTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        -- حذف أنواع التعبئة
        DELETE FROM END_MC_PACKAGING_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;


       UPDATE END_MARINE_CARGO_INS_PROPS_TB
       SET
            INSURED_OBJECT_DESC = INSURED_OBJECT_DESC_IN,
            COVERAGE_CONDITION_ID = COVERAGE_CONDITION_ID_IN,
            GEO_AREA_ID = GEO_AREA_ID_IN,
            RISK_DEGREE_ID = RISK_DEGREE_ID_IN,
            PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
            --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
            TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
            PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL + PROPORTIONAL_FEE_VAL_IN,
            CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
            INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
            CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

     -- يتم ارسال جدول اقساط جديد

     --- **************ADD TRANSACTION TO CUSTOMERS**************************************************************************************************/
     --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
     GENERAL_PKG.ADD_TRANSACTION_PR ( 12.31, ENDORSEMENT_ID_OUT, BRANCH_ID_V, CUST_ID_V, CURR_ID_V, INSURANCE_VALUE_NEW_V, CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
     IF  ERR_STATUS_OUT=0 THEN
        RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
     END IF;
     /*****************************************************************************************************************/

     ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


PROCEDURE ADD_COVERAGE_CONDITIONS_END_PR(
         --  ملحق  تعديل التغطيات و الشروط
         -- اضافة
          ENDORSEMENT_DATE_IN       IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                 IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
          DISCOUNT_VALUE_IN         IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
          PREMIUM_VALUE_IN          IN NUMBER,
          ADDITIONAL_AMOUNT_IN      IN NUMBER,
          PROPORTIONAL_FEE_PER_IN  IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN  IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
          CLARIFICATION_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.CLARIFICATION%TYPE,
          NOTES_IN                  IN ENDORSEMENTS_TB.NOTES%TYPE,
          CREATED_BY_IN             IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                   IN VARCHAR2,
          ENDORSEMENT_ID_OUT        OUT NOCOPY NUMBER ,
          ERR_DESC_OUT              OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT            OUT NOCOPY NUMBER )
AS

      POLICY_ID_V                  NUMBER;
      PROPOSAL_ID_V                NUMBER;
      POLICY_TYPE_V                NUMBER := 7;
      ENDORSEMENT_NUM_V            NUMBER := 14;
      ENDORSEMENT_FEES_V           NUMBER ;
      CNT                          NUMBER;
      CURR_ID_V                    NUMBER;
      EQ_PRICE_V                   NUMBER ;

      POLICY_STATUS_ID_V           NUMBER ;
      INSURANCE_STARTING_DATE_V    DATE;
      INSURANCE_ENDING_DATE_OLD_V  DATE;
      INSURANCE_VALUE_OLD_V        NUMBER ;
      INSURRANCE_VALUE_EQ_OLD_V    NUMBER ;
      AMOUNT_PAID_OLD_V            NUMBER ;
      INSURANCE_ENDING_DATE_V      DATE;
      INSURANCE_VALUE_NEW_V        NUMBER;

      ENDORSEMENT_ID_V             NUMBER;

      BRANCH_ID_V                  NUMBER ;
      OFFICE_ID_V                  NUMBER ;
      AGENT_ID_V                   NUMBER ;
      REPRESENTATIVE_ID_V          NUMBER ;
      EMP_ID_V                     NUMBER ;
      CUST_ID_V                    NUMBER ;

      NEW_INSTALLMENT_COUNT_V      NUMBER :=0;
      PAYMENT_METHOD_ID_IN         NUMBER :=0;
      PAYMENT_DUE_ID_IN            NUMBER :=0;
      DUE_DATE_IN                  DATE :=SYSDATE;
      ENDORSEMENT_VALUE_V          NUMBER;
      TOTAL_VALUE_V                NUMBER;
      OLD_PROP_DISCOUNT_VALUE_V    NUMBER;
      END_CNT                      NUMBER;
      PREV_ENDORSEMENT_ID_V        NUMBER;
      ENDORSEMENT_FEES_EQ_V        NUMBER;
      PROPORTIONAL_FEE_VAL_EQ_V    NUMBER;
BEGIN
        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------
        -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data
        SELECT
          POLICY_ID , INS_CURR_ID , PROPOSAL_ID
        INTO
          POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        SELECT COUNT(*) INTO END_CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;

       IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

                   --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;
       END IF ;

        --------------------
       -- فحص إذا كانت البوليصة منتهية
       IF TRUNC(INSURANCE_ENDING_DATE_OLD_V) < TRUNC(SYSDATE) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.200',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

       SELECT
           POLICY_STATUS_ID
       INTO
           POLICY_STATUS_ID_V
       FROM POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;

       -- فحص إذا كانت البوليصة ملغية
       IF POLICY_STATUS_ID_V = 2 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.201',LANG_IN,SQLERRM);
              RETURN;
       END IF ;
        -- فحص هل الطلب له ملحق وغير مصدر

        SELECT  COUNT(*)  INTO  CNT
        FROM ENDORSEMENTS_TB
        WHERE
            POLICY_ID = POLICY_ID_V
            AND POLICY_TYPE_ID = POLICY_TYPE_V
            AND ISSUED_BY IS  NULL ;

        IF CNT > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.169,LANG_IN,SQLERRM);
              RETURN;
       END IF ;



       -- GET   ENDORSEMENT_FEES VALUE
       --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
       ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);
        ------------------------------------------

        -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

       ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

       PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;
       ------------------------------------------

       ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

       TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

       INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

       --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);

       MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            NULL  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            CREATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

       -- COPY DATA TO ENDORSMENTS TABLE
       COPY_DATA_TO_END_PR (
            ENDORSEMENT_ID_OUT,
            APP_ID_IN,
            LANG_IN,
            ERR_DESC_OUT,
            ERR_STATUS_OUT);

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

        DELETE FROM END_MC_ADDITIONAL_COVERAGES_TB
         WHERE
                ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_CONDITIONS_TB
         WHERE
                ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_ENDURINGS_TB
         WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_EXCEPTIONS_TB
         WHERE
               ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MARINE_CARGO_INS_RETENS_TB
         WHERE
               ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

        UPDATE END_MARINE_CARGO_INS_PROPS_TB
         SET
              CLARIFICATION = CLARIFICATION_IN,
              PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
              --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
              TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
              INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
              PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL + PROPORTIONAL_FEE_VAL_IN,
              CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
         WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         UPDATE END_POLICIES_TB
          SET
               -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
              INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
              INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
              END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
              END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
              PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
              PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
              CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
          WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        ----------------------------------------------------------


       --- **************ADD TRANSACTION TO CUSTOMERS**************************************************************************************************/
      --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
       GENERAL_PKG.ADD_TRANSACTION_PR ( 12.32, ENDORSEMENT_ID_OUT, NULL, NULL, NULL, INSURANCE_VALUE_NEW_V, CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
       IF  ERR_STATUS_OUT=0 THEN
          RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
       END IF;
      /*****************************************************************************************************************/


        ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;

PROCEDURE ADD_SHIPMENT_DATA_END_PR(
 -- ملحق  تعديل بيانات الشحن  Shipment Data Modification Endorsement
 -- اضافة
          ENDORSEMENT_DATE_IN         IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                   IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
          LC_BANK_ID_IN               IN MARINE_CARGO_INS_APPS_TB.LC_BANK_ID%TYPE,
          LC_BRANCH_ID_IN             IN MARINE_CARGO_INS_APPS_TB.LC_BRANCH_ID%TYPE,
          LC_IN                       IN MARINE_CARGO_INS_APPS_TB.LC%TYPE,
          MAX_ARRIVAL_DATE_IN         IN MARINE_CARGO_INS_APPS_TB.MAX_ARRIVAL_DATE%TYPE,
          RISK_DEGREE_ID_IN           IN MARINE_CARGO_INS_PROPOSALS_TB.RISK_DEGREE_ID%TYPE,
          CONTAINERS_COUNT_IN         IN MARINE_CARGO_INS_PROPOSALS_TB.CONTAINERS_COUNT%TYPE,
          CONTAINER_SIZE_ID_IN        IN MARINE_CARGO_INS_PROPOSALS_TB.CONTAINER_SIZE_ID%TYPE,
          VEHICLE_NUM_IN              IN MARINE_CARGO_INS_APPS_TB.VEHICLE_NUM%TYPE,
          VEHICLE_MODEL_IN            IN MARINE_CARGO_INS_APPS_TB.VEHICLE_MODEL%TYPE,
          WAY_BILL_NUM_IN             IN MARINE_CARGO_INS_APPS_TB.WAY_BILL_NUM%TYPE,
          VESSEL_NAME_IN              IN MARINE_CARGO_INS_APPS_TB.VESSEL_NAME%TYPE,
          TRIP_NUM_IN                 IN MARINE_CARGO_INS_APPS_TB.TRIP_NUM%TYPE,
          LADING_BILL_NUM_IN          IN MARINE_CARGO_INS_APPS_TB.LADING_BILL_NUM%TYPE,
          AIR_WAY_BILL_NUM_IN         IN MARINE_CARGO_INS_APPS_TB.AIR_WAY_BILL_NUM%TYPE,
          SHIPPING_CONDITION_ID_IN    IN MARINE_CARGO_INS_PROPOSALS_TB.SHIPPING_CONDITION_ID%TYPE,
          DOCUMENTARY_VALUE_IN        IN MARINE_CARGO_INS_PROPOSALS_TB.DOCUMENTARY_VALUE%TYPE,
          ADDITION_RATIO_IN           IN MARINE_CARGO_INS_PROPOSALS_TB.ADDITION_RATIO%TYPE,
          SHIPPING_RATIO_IN           IN MARINE_CARGO_INS_PROPOSALS_TB.SHIPPING_RATIO%TYPE,
          ROUNDING_RATIO_IN           IN MARINE_CARGO_INS_PROPOSALS_TB.ROUNDING_RATIO%TYPE,
          GOODS_VALUE_IN              IN MARINE_CARGO_INS_PROPOSALS_TB.GOODS_VALUE%TYPE,
          INSURANCE_VALUE_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.INSURANCE_VALUE%TYPE,
          DISCOUNT_VALUE_IN           IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
          PREMIUM_VALUE_IN            IN NUMBER,
          ADDITIONAL_AMOUNT_IN        IN NUMBER,
          PROPORTIONAL_FEE_PER_IN     IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN     IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
          NOTES_IN                    IN ENDORSEMENTS_TB.NOTES%TYPE,
          TRIP_FINAL_DESTINATION_IN  IN MARINE_CARGO_INS_PROPOSALS_TB.TRIP_FINAL_DESTINATION%TYPE,
          CREATED_BY_IN               IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                     IN VARCHAR2,
          ENDORSEMENT_ID_OUT          OUT NOCOPY NUMBER ,
          ERR_DESC_OUT                OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT              OUT NOCOPY NUMBER )
AS

      POLICY_ID_V                 NUMBER;
      PROPOSAL_ID_V               NUMBER;
      POLICY_TYPE_V               NUMBER := 7;
      ENDORSEMENT_NUM_V           NUMBER := 15;
      ENDORSEMENT_FEES_V          NUMBER ;
      CNT                         NUMBER;
      CURR_ID_V                   NUMBER;
      EQ_PRICE_V                  NUMBER ;

      POLICY_STATUS_ID_V          NUMBER ;
      INSURANCE_STARTING_DATE_V   DATE;
      INSURANCE_ENDING_DATE_OLD_V DATE;
      INSURANCE_VALUE_OLD_V       NUMBER ;
      INSURRANCE_VALUE_EQ_OLD_V   NUMBER ;
      AMOUNT_PAID_OLD_V           NUMBER ;
      INSURANCE_ENDING_DATE_V     DATE;
      INSURANCE_VALUE_NEW_V       NUMBER;

      ENDORSEMENT_ID_V            NUMBER;

      BRANCH_ID_V                 NUMBER ;
      OFFICE_ID_V                 NUMBER ;
      AGENT_ID_V                  NUMBER ;
      REPRESENTATIVE_ID_V         NUMBER ;
      EMP_ID_V                    NUMBER ;
      CUST_ID_V                   NUMBER ;
      NEW_INSTALLMENT_COUNT_V     NUMBER :=0;
      PAYMENT_METHOD_ID_IN        NUMBER :=0;
      PAYMENT_DUE_ID_IN           NUMBER :=0;
      DUE_DATE_IN                 DATE :=SYSDATE;

      ENDORSEMENT_VALUE_V         NUMBER;
      TOTAL_VALUE_V               NUMBER;
      OLD_PROP_DISCOUNT_VALUE_V   NUMBER;

      INSURANCE_START_DATE_V      DATE;
      INSURANCE_END_DATE_V        DATE;

      PREV_ENDORSEMENT_ID_V       NUMBER;
      END_CNT                     NUMBER;
      ENDORSEMENT_FEES_EQ_V       NUMBER;
      PROPORTIONAL_FEE_VAL_EQ_V   NUMBER;

      GOODS_VALUE_V               NUMBER;
      ----- RATIO -----------------
      ADDITION_RATIO_VALUE_V      NUMBER;
      SHIPPING_RATIO_VALUE_V      NUMBER;
      ROUNDING_RATIO_VALUE_V      NUMBER;

BEGIN

        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------


        -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data

        SELECT
          POLICY_ID , INS_CURR_ID , PROPOSAL_ID ,  INSURANCE_START_DATE , INSURANCE_END_DATE
        INTO
          POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V ,INSURANCE_START_DATE_V , INSURANCE_END_DATE_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        SELECT COUNT(*) INTO END_CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;

       IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

                   --Get Policy Data
           SELECT
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;
       END IF ;


       -- فحص إذا كانت البوليصة منتهية
       IF TRUNC(INSURANCE_ENDING_DATE_OLD_V) < TRUNC(SYSDATE) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.200',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

       SELECT
           POLICY_STATUS_ID
       INTO
           POLICY_STATUS_ID_V
       FROM POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;

       -- فحص إذا كانت البوليصة ملغية
       IF POLICY_STATUS_ID_V = 2 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.201',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

       --------------------
       ---- فحص الحد الاقصى للوصول يجب ان يكون في حدود تاريخ البداية و نهاية التأمين
       IF (MAX_ARRIVAL_DATE_IN IS NOT NULL) THEN
          IF(TRUNC(MAX_ARRIVAL_DATE_IN))< TRUNC(INSURANCE_START_DATE_V)  THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.172',LANG_IN,SQLERRM);
              RETURN;
          END IF;
          IF (TRUNC(MAX_ARRIVAL_DATE_IN))> TRUNC(INSURANCE_END_DATE_V)  THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.173',LANG_IN,SQLERRM);
              RETURN;
          END IF;
       END IF ;

        -- فحص هل الطلب له ملحق وغير مصدر

        SELECT  COUNT(*)  INTO  CNT
        FROM ENDORSEMENTS_TB
        WHERE
            POLICY_ID = POLICY_ID_V
            AND POLICY_TYPE_ID = POLICY_TYPE_V
            AND ISSUED_BY IS  NULL ;

        IF CNT > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.169,LANG_IN,SQLERRM);
              RETURN;
       END IF ;


       -- GET   ENDORSEMENT_FEES VALUE
        --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
        ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);

        EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

        ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

        PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

        ---------------------------------------------------
        ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

        TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

        INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

        --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);


       -- تخزين بيانات الملحق
       -- ENDORSEMENT_TYPE_ID يحمل رقم 13 للتأمين البحري
        MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            NULL  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            CREATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

       -- COPY DATA TO ENDORSMENTS TABLE
       COPY_DATA_TO_END_PR (
            ENDORSEMENT_ID_OUT,
            APP_ID_IN,
            LANG_IN,
            ERR_DESC_OUT,
            ERR_STATUS_OUT);

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

        DELETE FROM END_MC_TRANSPORTATION_TYPES_TB
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       GOODS_VALUE_V :=  NVL(DOCUMENTARY_VALUE_IN,0);

       ADDITION_RATIO_VALUE_V := (GOODS_VALUE_V * ADDITION_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + ADDITION_RATIO_VALUE_V;

       SHIPPING_RATIO_VALUE_V := (GOODS_VALUE_V * SHIPPING_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + SHIPPING_RATIO_VALUE_V;

       ROUNDING_RATIO_VALUE_V := (GOODS_VALUE_V * ROUNDING_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + ROUNDING_RATIO_VALUE_V;


       UPDATE END_MARINE_CARGO_INS_PROPS_TB
       SET
            RISK_DEGREE_ID = RISK_DEGREE_ID_IN,
            CONTAINERS_COUNT = CONTAINERS_COUNT_IN,
            CONTAINER_SIZE_ID = CONTAINER_SIZE_ID_IN ,
            SHIPPING_CONDITION_ID = SHIPPING_CONDITION_ID_IN ,
            DOCUMENTARY_VALUE = DOCUMENTARY_VALUE_IN,
            ADDITION_RATIO = ADDITION_RATIO_IN,
            SHIPPING_RATIO = SHIPPING_RATIO_IN,
            ROUNDING_RATIO = ROUNDING_RATIO_IN,
            GOODS_VALUE = GOODS_VALUE_V,
            INSURANCE_VALUE = INSURANCE_VALUE_IN,
            PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
            --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
            TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
            PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL + PROPORTIONAL_FEE_VAL_IN,
            CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       ----- التعديل على بيانات الطلب
       UPDATE  END_MARINE_CARGO_INS_APPS_TB
       SET
          LC_BANK_ID = LC_BANK_ID_IN,
          LC_BRANCH_ID = LC_BRANCH_ID_IN,
          LC = LC_IN,
          MAX_ARRIVAL_DATE = MAX_ARRIVAL_DATE_IN,
          AIR_WAY_BILL_NUM = AIR_WAY_BILL_NUM_IN,
          VEHICLE_NUM = VEHICLE_NUM_IN,
          VEHICLE_MODEL = VEHICLE_MODEL_IN,
          WAY_BILL_NUM = WAY_BILL_NUM_IN,
          VESSEL_NAME = VESSEL_NAME_IN,
          TRIP_NUM = TRIP_NUM_IN,
          LADING_BILL_NUM = LADING_BILL_NUM_IN,
          CREATED_ON = SYSDATE,
          CREATED_BY = CREATED_BY_IN
       WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
            INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
            CREATED_ON = SYSDATE,
            CREATED_BY = CREATED_BY_IN
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        ----------------------------------------------------------

        --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
         GENERAL_PKG.ADD_TRANSACTION_PR ( 12.33, ENDORSEMENT_ID_OUT, null, null, null, INSURANCE_VALUE_NEW_V, CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
         IF  ERR_STATUS_OUT=0 THEN
            Raise_application_error(-20011, ' Error in GENERAL_PKG.ADD_TRANSACTION_PR ');
         END IF;
        /*****************************************************************************************************************/


         ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;

PROCEDURE UPD_SHIPMENT_DATA_END_PR(
 -- ملحق  تعديل بيانات الشحن  Shipment Data Modification Endorsement
 -- اضافة
          ENDORSEMENT_ID_IN          IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          ENDORSEMENT_DATE_IN        IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                  IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
          LC_BANK_ID_IN              IN MARINE_CARGO_INS_APPS_TB.LC_BANK_ID%TYPE,
          LC_BRANCH_ID_IN            IN MARINE_CARGO_INS_APPS_TB.LC_BRANCH_ID%TYPE,
          LC_IN                      IN MARINE_CARGO_INS_APPS_TB.LC%TYPE,
          MAX_ARRIVAL_DATE_IN        IN MARINE_CARGO_INS_APPS_TB.MAX_ARRIVAL_DATE%TYPE,
          RISK_DEGREE_ID_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.RISK_DEGREE_ID%TYPE,
          CONTAINERS_COUNT_IN        IN MARINE_CARGO_INS_PROPOSALS_TB.CONTAINERS_COUNT%TYPE,
          CONTAINER_SIZE_ID_IN       IN MARINE_CARGO_INS_PROPOSALS_TB.CONTAINER_SIZE_ID%TYPE,
          VEHICLE_NUM_IN             IN MARINE_CARGO_INS_APPS_TB.VEHICLE_NUM%TYPE,
          VEHICLE_MODEL_IN           IN MARINE_CARGO_INS_APPS_TB.VEHICLE_MODEL%TYPE,
          WAY_BILL_NUM_IN            IN MARINE_CARGO_INS_APPS_TB.WAY_BILL_NUM%TYPE,
          VESSEL_NAME_IN             IN MARINE_CARGO_INS_APPS_TB.VESSEL_NAME%TYPE,
          TRIP_NUM_IN                IN MARINE_CARGO_INS_APPS_TB.TRIP_NUM%TYPE,
          LADING_BILL_NUM_IN         IN MARINE_CARGO_INS_APPS_TB.LADING_BILL_NUM%TYPE,
          AIR_WAY_BILL_NUM_IN        IN MARINE_CARGO_INS_APPS_TB.AIR_WAY_BILL_NUM%TYPE,
          SHIPPING_CONDITION_ID_IN   IN MARINE_CARGO_INS_PROPOSALS_TB.SHIPPING_CONDITION_ID%TYPE,
          DOCUMENTARY_VALUE_IN       IN MARINE_CARGO_INS_PROPOSALS_TB.DOCUMENTARY_VALUE%TYPE,
          ADDITION_RATIO_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.ADDITION_RATIO%TYPE,
          SHIPPING_RATIO_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.SHIPPING_RATIO%TYPE,
          ROUNDING_RATIO_IN          IN MARINE_CARGO_INS_PROPOSALS_TB.ROUNDING_RATIO%TYPE,
          GOODS_VALUE_IN             IN MARINE_CARGO_INS_PROPOSALS_TB.GOODS_VALUE%TYPE,
          INSURANCE_VALUE_IN         IN MARINE_CARGO_INS_PROPOSALS_TB.INSURANCE_VALUE%TYPE,
          DISCOUNT_VALUE_IN          IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
          PREMIUM_VALUE_IN           IN NUMBER,
          ADDITIONAL_AMOUNT_IN       IN NUMBER,
          PROPORTIONAL_FEE_PER_IN    IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN    IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSEMENT_FEES_IN        IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
          NOTES_IN                   IN ENDORSEMENTS_TB.NOTES%TYPE,
          TRIP_FINAL_DESTINATION_IN  IN MARINE_CARGO_INS_PROPOSALS_TB.TRIP_FINAL_DESTINATION%TYPE,
          UPDATED_BY_IN              IN MARINE_CARGO_INS_PROPOSALS_TB.UPDATED_BY%TYPE,
          LANG_IN                    IN VARCHAR2,
          ERR_DESC_OUT               OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT             OUT NOCOPY NUMBER )
AS

      POLICY_ID_V                  NUMBER;
      PROPOSAL_ID_V                NUMBER;
      POLICY_TYPE_V                NUMBER := 7;
      ENDORSEMENT_NUM_V            NUMBER := 15;
      ENDORSEMENT_FEES_V           NUMBER ;
      CNT                          NUMBER;
      CURR_ID_V                    NUMBER;
      EQ_PRICE_V                   NUMBER ;

      POLICY_STATUS_ID_V           NUMBER ;
      INSURANCE_STARTING_DATE_V    DATE;
      INSURANCE_ENDING_DATE_OLD_V  DATE;
      INSURANCE_VALUE_OLD_V        NUMBER ;
      INSURRANCE_VALUE_EQ_OLD_V    NUMBER ;
      AMOUNT_PAID_OLD_V            NUMBER ;
      INSURANCE_ENDING_DATE_V      DATE;
      INSURANCE_VALUE_NEW_V        NUMBER;

      ENDORSEMENT_ID_V            NUMBER;

      BRANCH_ID_V                 NUMBER ;
      OFFICE_ID_V                 NUMBER ;
      AGENT_ID_V                  NUMBER ;
      REPRESENTATIVE_ID_V         NUMBER ;
      EMP_ID_V                    NUMBER ;
      CUST_ID_V                   NUMBER ;


      NEW_INSTALLMENT_COUNT_V     NUMBER :=0;
      PAYMENT_METHOD_ID_IN        NUMBER :=0;
      PAYMENT_DUE_ID_IN           NUMBER :=0;
      DUE_DATE_IN                 DATE :=SYSDATE;

      ISSUED_BY_V                 NUMBER;
      ENDORSEMENT_VALUE_V         NUMBER;
      TOTAL_VALUE_V               NUMBER;
      OLD_PROP_DISCOUNT_VALUE_V   NUMBER;

      INSURANCE_START_DATE_V      DATE;
      INSURANCE_END_DATE_V        DATE;

      END_CNT                     NUMBER;
      PREV_ENDORSEMENT_ID_V       NUMBER ;

      ENDORSEMENT_ID_OUT          NUMBER ;
      ENDORSEMENT_FEES_EQ_V       NUMBER ;
      PROPORTIONAL_FEE_VAL_EQ_V   NUMBER ;

      GOODS_VALUE_V               NUMBER ;
      ----- RATIO -----------------
      ADDITION_RATIO_VALUE_V      NUMBER;
      SHIPPING_RATIO_VALUE_V      NUMBER;
      ROUNDING_RATIO_VALUE_V      NUMBER;

BEGIN

  -- معرفة حالة الملحق هل مصدر ام لا
        -- اذا كان مصدر لايمكن تعديله
        SELECT ISSUED_BY  INTO  ISSUED_BY_V
        FROM ENDORSEMENTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN  ;

        IF ISSUED_BY_V IS NOT NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.170,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        -- DELETE OLD DATA FROM ENDORSMENTS TABLES
        DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN  ,
                    LANG_IN ,
                    ERR_DESC_OUT  ,
                    ERR_STATUS_OUT ) ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

        SELECT
              POLICY_ID , INS_CURR_ID , PROPOSAL_ID
        INTO
              POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V
        FROM
             MARINE_CARGO_INS_APPS_TB
        WHERE
             APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;


        SELECT COUNT(*) INTO END_CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
              PROPOSAL_ID  = PROPOSAL_ID_V;

        IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;

            SELECT
                    INSURANCE_START_DATE , INSURANCE_END_DATE
            INTO
                   INSURANCE_START_DATE_V , INSURANCE_END_DATE_V
            FROM
                  END_MARINE_CARGO_INS_APPS_TB
            WHERE
                  APP_ID = APP_ID_IN
                  AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            SELECT
                   INSURANCE_START_DATE , INSURANCE_END_DATE
              INTO
                   INSURANCE_START_DATE_V , INSURANCE_END_DATE_V
              FROM
                   MARINE_CARGO_INS_APPS_TB
              WHERE
                   APP_ID = APP_ID_IN ;

                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;

            -- فحص هل البوليصة مصدرة
            IF ISSUED_BY_V IS NULL THEN
                ERR_STATUS_OUT := 0 ;
                ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
                RETURN;
           END IF;
       END IF ;

      -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data


        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

       ---- فحص الحد الاقصى للوصول يجب ان يكون في حدود تاريخ البداية و نهاية التأمين
       IF (MAX_ARRIVAL_DATE_IN IS NOT NULL) THEN
          IF(TRUNC(MAX_ARRIVAL_DATE_IN))< TRUNC(INSURANCE_START_DATE_V)  THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.172',LANG_IN,SQLERRM);
              RETURN;
          END IF;
          IF (TRUNC(MAX_ARRIVAL_DATE_IN))> TRUNC(INSURANCE_END_DATE_V)  THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.173',LANG_IN,SQLERRM);
              RETURN;
          END IF;
       END IF ;

       -- GET   ENDORSEMENT_FEES VALUE
       --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
       ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);
       ------------------------------------------

        -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

       ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

       PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

       ---------------------------------------------------
        ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

        TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

        INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

        --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);

       MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            ENDORSEMENT_ID_IN  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            UPDATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

        ----------------------------------------------------------
         -------------------------------------------------------
        -- COPY DATA TO ENDORSMENTS TABLE
           COPY_DATA_TO_END_PR (
                ENDORSEMENT_ID_OUT  ,
                APP_ID_IN   ,
                LANG_IN                       ,
                ERR_DESC_OUT                  ,
                ERR_STATUS_OUT                )  ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

        DELETE FROM END_MC_TRANSPORTATION_TYPES_TB
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       GOODS_VALUE_V :=  NVL(DOCUMENTARY_VALUE_IN,0);

       ADDITION_RATIO_VALUE_V := (GOODS_VALUE_V * ADDITION_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + ADDITION_RATIO_VALUE_V;

       SHIPPING_RATIO_VALUE_V := (GOODS_VALUE_V * SHIPPING_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + SHIPPING_RATIO_VALUE_V;

       ROUNDING_RATIO_VALUE_V := (GOODS_VALUE_V * ROUNDING_RATIO_IN) /100 ;
       GOODS_VALUE_V := GOODS_VALUE_V + ROUNDING_RATIO_VALUE_V;

        -------------------------------------------------------
--       -- التعديل على بيانات عرض التأمين البحري
       UPDATE END_MARINE_CARGO_INS_PROPS_TB
       SET
            RISK_DEGREE_ID = RISK_DEGREE_ID_IN,
            CONTAINERS_COUNT = CONTAINERS_COUNT_IN,
            CONTAINER_SIZE_ID = CONTAINER_SIZE_ID_IN ,
            SHIPPING_CONDITION_ID = SHIPPING_CONDITION_ID_IN ,
            DOCUMENTARY_VALUE = DOCUMENTARY_VALUE_IN,
            ADDITION_RATIO = ADDITION_RATIO_IN,
            SHIPPING_RATIO = SHIPPING_RATIO_IN,
            ROUNDING_RATIO = ROUNDING_RATIO_IN,
            GOODS_VALUE = GOODS_VALUE_V,
            INSURANCE_VALUE = INSURANCE_VALUE_IN,
            PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
            --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
            TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
            PROPORTIONAL_FEE_VAL         = NVL(PROPORTIONAL_FEE_VAL,0) + NVL(PROPORTIONAL_FEE_VAL_IN,0),
            UPDATED_ON = SYSDATE,
            UPDATED_BY = UPDATED_BY_IN
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       ----- التعديل على بيانات الطلب
       UPDATE  END_MARINE_CARGO_INS_APPS_TB
       SET
          LC_BANK_ID = LC_BANK_ID_IN,
          LC_BRANCH_ID = LC_BRANCH_ID_IN,
          LC = LC_IN,
          MAX_ARRIVAL_DATE = MAX_ARRIVAL_DATE_IN,
          AIR_WAY_BILL_NUM = AIR_WAY_BILL_NUM_IN,
          VEHICLE_NUM = VEHICLE_NUM_IN,
          VEHICLE_MODEL = VEHICLE_MODEL_IN,
          WAY_BILL_NUM = WAY_BILL_NUM_IN,
          VESSEL_NAME = VESSEL_NAME_IN,
          TRIP_NUM = TRIP_NUM_IN,
          LADING_BILL_NUM = LADING_BILL_NUM_IN,
          UPDATED_ON = SYSDATE,
          UPDATED_BY = UPDATED_BY_IN
       WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;


   -- التعديل على بيانات البوليصة المؤقتة
       UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
            INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   NVL(PROPORTIONAL_FEE_VAL,0) + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   NVL(PROPORTIONAL_FEE_VAL_EQ,0) + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
            UPDATED_ON = SYSDATE,
            UPDATED_BY = UPDATED_BY_IN
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;


      --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
       GENERAL_PKG.ADD_TRANSACTION_PR ( 12.36, ENDORSEMENT_ID_IN, NULL, NULL, NULL, INSURANCE_VALUE_NEW_V, UPDATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
       IF  ERR_STATUS_OUT=0 THEN
          RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
       END IF;
      /*****************************************************************************************************************/



        ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


PROCEDURE ADD_END_MC_TRANSPORT_TYPES_PR(
          ENDORSEMENT_ID_IN             IN END_MC_TRANSPORTATION_TYPES_TB.ENDORSEMENT_ID%TYPE,
          PROPOSAL_ID_IN                IN END_MC_TRANSPORTATION_TYPES_TB.PROPOSAL_ID%TYPE,
          TRANSPORTATION_TYPE_ID_IN     IN END_MC_TRANSPORTATION_TYPES_TB.TRANSPORTATION_TYPE_ID%TYPE,
          TRANSPORTATION_ORDER_IN       IN END_MC_TRANSPORTATION_TYPES_TB.TRANSPORTATION_ORDER%TYPE,
          AIRPORT_ID_FROM_IN            IN END_MC_TRANSPORTATION_TYPES_TB.AIRPORT_ID_FROM%TYPE,
          PORT_ID_FROM_IN               IN END_MC_TRANSPORTATION_TYPES_TB.PORT_ID_FROM%TYPE,
          COUNTRY_ID_FROM_IN            IN END_MC_TRANSPORTATION_TYPES_TB.COUNTRY_ID_FROM%TYPE,
          STATE_ID_FROM_IN              IN END_MC_TRANSPORTATION_TYPES_TB.STATE_ID_FROM%TYPE,
          CITY_ID_FROM_IN               IN END_MC_TRANSPORTATION_TYPES_TB.CITY_ID_FROM%TYPE,
          AIRPORT_ID_TO_IN              IN END_MC_TRANSPORTATION_TYPES_TB.AIRPORT_ID_TO%TYPE,
          PORT_ID_TO_IN                 IN END_MC_TRANSPORTATION_TYPES_TB.PORT_ID_TO%TYPE,
          COUNTRY_ID_TO_IN              IN END_MC_TRANSPORTATION_TYPES_TB.COUNTRY_ID_TO%TYPE,
          STATE_ID_TO_IN                IN END_MC_TRANSPORTATION_TYPES_TB.STATE_ID_TO%TYPE,
          CITY_ID_TO_IN                 IN END_MC_TRANSPORTATION_TYPES_TB.CITY_ID_TO%TYPE,
          LANG_IN                       IN VARCHAR2,
          ERR_DESC_OUT                  OUT VARCHAR2,
          ERR_STATUS_OUT                OUT NUMBER)
AS
BEGIN

          INSERT INTO   END_MC_TRANSPORTATION_TYPES_TB
              (ENDORSEMENT_ID,PROPOSAL_ID,TRANSPORTATION_TYPE_ID,TRANSPORTATION_ORDER,
              AIRPORT_ID_FROM,PORT_ID_FROM,COUNTRY_ID_FROM,
              STATE_ID_FROM,CITY_ID_FROM,AIRPORT_ID_TO,
              PORT_ID_TO,COUNTRY_ID_TO,STATE_ID_TO,
              CITY_ID_TO)
          VALUES
              (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,TRANSPORTATION_TYPE_ID_IN,TRANSPORTATION_ORDER_IN,
              AIRPORT_ID_FROM_IN,PORT_ID_FROM_IN,COUNTRY_ID_FROM_IN,
              STATE_ID_FROM_IN,CITY_ID_FROM_IN,AIRPORT_ID_TO_IN,
              PORT_ID_TO_IN,COUNTRY_ID_TO_IN,STATE_ID_TO_IN,
              CITY_ID_TO_IN);

        ERR_STATUS_OUT :=1;

EXCEPTION
    WHEN OTHERS THEN
            ERR_STATUS_OUT :=0 ;
            ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;


PROCEDURE UPD_INSUR_OBJECTS_END_PR(
 --  ملحق تعديل الاعيان المؤمنة
 -- تعديل
          ENDORSEMENT_ID_IN         IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          ENDORSEMENT_DATE_IN       IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                 IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
          INSURED_OBJECT_DESC_IN    IN END_MARINE_CARGO_INS_PROPS_TB.INSURED_OBJECT_DESC%TYPE,
          COVERAGE_CONDITION_ID_IN  IN END_MARINE_CARGO_INS_PROPS_TB.COVERAGE_CONDITION_ID%TYPE,
          GEO_AREA_ID_IN            IN END_MARINE_CARGO_INS_PROPS_TB.GEO_AREA_ID%TYPE,
          RISK_DEGREE_ID_IN         IN END_MARINE_CARGO_INS_PROPS_TB.RISK_DEGREE_ID%TYPE,
          DISCOUNT_VALUE_IN         IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
          PREMIUM_VALUE_IN          IN NUMBER,
          ADDITIONAL_AMOUNT_IN      IN NUMBER,
          PROPORTIONAL_FEE_PER_IN   IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN   IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
          NOTES_IN                  IN ENDORSEMENTS_TB.NOTES%TYPE,
          ISSUED_BY_IN              IN ENDORSEMENTS_TB.ISSUED_BY%TYPE,
          LANG_IN                   IN VARCHAR2,
          ERR_DESC_OUT              OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT            OUT NOCOPY NUMBER )

AS

      POLICY_ID_V                 NUMBER;
      PROPOSAL_ID_V               NUMBER;
      POLICY_TYPE_V               NUMBER := 7;
      ENDORSEMENT_NUM_V           NUMBER := 13;
      ENDORSEMENT_FEES_V          NUMBER ;
      CNT                         NUMBER;
      CURR_ID_V                   NUMBER;
      EQ_PRICE_V                  NUMBER ;

      POLICY_STATUS_ID_V          NUMBER ;
      INSURANCE_STARTING_DATE_V   DATE;
      INSURANCE_ENDING_DATE_OLD_V DATE;
      INSURANCE_VALUE_OLD_V       NUMBER ;
      INSURRANCE_VALUE_EQ_OLD_V   NUMBER ;
      AMOUNT_PAID_OLD_V           NUMBER ;
      INSURANCE_ENDING_DATE_V     DATE;
      INSURANCE_VALUE_NEW_V       NUMBER;

      ENDORSEMENT_ID_V            NUMBER;

      BRANCH_ID_V                 NUMBER ;
      OFFICE_ID_V                 NUMBER ;
      AGENT_ID_V                  NUMBER ;
      REPRESENTATIVE_ID_V         NUMBER ;
      EMP_ID_V                    NUMBER ;
      CUST_ID_V                   NUMBER ;

      NEW_INSTALLMENT_COUNT_V     NUMBER :=0;
      PAYMENT_METHOD_ID_IN        NUMBER :=0;
      PAYMENT_DUE_ID_IN           NUMBER :=0;
      DUE_DATE_IN                 DATE :=SYSDATE;

      ISSUED_BY_V                 NUMBER;

      TOTAL_VALUE_V               NUMBER;
      OLD_PROP_DISCOUNT_VALUE_V   NUMBER;
      ENDORSEMENT_VALUE_V         NUMBER;
      END_CNT                     NUMBER;
      PREV_ENDORSEMENT_ID_V       NUMBER ;

      ENDORSEMENT_ID_OUT                NUMBER ;
      ENDORSEMENT_FEES_EQ_V             NUMBER ;
      PROPORTIONAL_FEE_VAL_EQ_V         NUMBER ;
BEGIN

        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------

           -- معرفة حالة الملحق هل مصدر ام لا
        -- اذا كان مصدر لايمكن تعديله
        SELECT ISSUED_BY  INTO  ISSUED_BY_V
        FROM ENDORSEMENTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN  ;

        IF ISSUED_BY_V IS NOT NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.170,LANG_IN,SQLERRM);
              RETURN;
        END IF;


        -- DELETE OLD DATA FROM ENDORSMENTS TABLES
        DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN  ,
                    LANG_IN ,
                    ERR_DESC_OUT  ,
                    ERR_STATUS_OUT ) ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

      -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data
        SELECT
          POLICY_ID , INS_CURR_ID , PROPOSAL_ID
        INTO
          POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;


        SELECT COUNT(*) INTO END_CNT
        FROM  END_POLICIES_TB
        WHERE
              POLICY_ID  = POLICY_ID_V;
       -- نسخ البيانات الى الهيستوي

       IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;

            -- فحص هل البوليصة مصدرة
            IF ISSUED_BY_V IS NULL THEN
                ERR_STATUS_OUT := 0 ;
                ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
                RETURN;
           END IF;
       END IF ;




       -- GET   ENDORSEMENT_FEES VALUE
       --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
       ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);
        ------------------------------------------

        -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

       ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

       PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

       ------------------------------------------------
       ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

       TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

       INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

       --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);


       MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            ENDORSEMENT_ID_IN  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            ISSUED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

        ----------------------------------------------------------
         -------------------------------------------------------
        -- COPY DATA TO ENDORSMENTS TABLE
           COPY_DATA_TO_END_PR (
                ENDORSEMENT_ID_OUT  ,
                APP_ID_IN   ,
                LANG_IN                       ,
                ERR_DESC_OUT                  ,
                ERR_STATUS_OUT                )  ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

         -- حذف الأعيان المؤمنة
        DELETE FROM END_MC_INSURED_OBJECTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        -- حذف أنواع التعبئة
        DELETE FROM END_MC_PACKAGING_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

       UPDATE END_MARINE_CARGO_INS_PROPS_TB
       SET
            INSURED_OBJECT_DESC = INSURED_OBJECT_DESC_IN,
            COVERAGE_CONDITION_ID = COVERAGE_CONDITION_ID_IN,
            GEO_AREA_ID = GEO_AREA_ID_IN,
            RISK_DEGREE_ID = RISK_DEGREE_ID_IN,
            PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
            --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
            TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
            PROPORTIONAL_FEE_VAL         = NVL(PROPORTIONAL_FEE_VAL,0) + NVL(PROPORTIONAL_FEE_VAL_IN,0),
            UPDATED_ON = SYSDATE,
            UPDATED_BY = ISSUED_BY_IN
       WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

       UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
            INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   NVL(PROPORTIONAL_FEE_VAL,0) + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   NVL(PROPORTIONAL_FEE_VAL_EQ,0) + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
            UPDATED_ON = SYSDATE,
            UPDATED_BY = ISSUED_BY_IN
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

      --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
       GENERAL_PKG.ADD_TRANSACTION_PR ( 12.34, ENDORSEMENT_ID_IN, NULL, NULL, NULL, INSURANCE_VALUE_NEW_V, ISSUED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
       IF  ERR_STATUS_OUT=0 THEN
          RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
       END IF;
      /*****************************************************************************************************************/

      ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


  PROCEDURE UPD_COVERAGE_CONDITIONS_END_PR(
 --ملحق  تعديل التغطيات و الشروط
 -- تعديل
            ENDORSEMENT_ID_IN     IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
            ENDORSEMENT_DATE_IN   IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
            APP_ID_IN             IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
            DISCOUNT_VALUE_IN     IN ENDORSEMENTS_TB.DISCOUNT_VALUE%TYPE,
            PREMIUM_VALUE_IN      IN NUMBER,
            ADDITIONAL_AMOUNT_IN  IN NUMBER,
            PROPORTIONAL_FEE_PER_IN   IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_PER%TYPE,
            PROPORTIONAL_FEE_VAL_IN   IN END_MARINE_CARGO_INS_PROPS_TB.PROPORTIONAL_FEE_VAL%TYPE,
            ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
            CLARIFICATION_IN      IN MARINE_CARGO_INS_PROPOSALS_TB.CLARIFICATION%TYPE,
            NOTES_IN              IN ENDORSEMENTS_TB.NOTES%TYPE,
            ISSUED_BY_IN          IN ENDORSEMENTS_TB.ISSUED_BY%TYPE,
            LANG_IN               IN VARCHAR2,
            ERR_DESC_OUT          OUT NOCOPY VARCHAR2,
            ERR_STATUS_OUT        OUT NOCOPY NUMBER )

AS

      POLICY_ID_V                   NUMBER;
      PROPOSAL_ID_V                 NUMBER;
      POLICY_TYPE_V                 NUMBER := 7;
      ENDORSEMENT_NUM_V             NUMBER := 14;
      ENDORSEMENT_FEES_V            NUMBER ;
      CNT                           NUMBER;
      CURR_ID_V                     NUMBER;
      EQ_PRICE_V                    NUMBER ;

      POLICY_STATUS_ID_V            NUMBER ;
      INSURANCE_STARTING_DATE_V     DATE;
      INSURANCE_ENDING_DATE_OLD_V   DATE;
      INSURANCE_VALUE_OLD_V         NUMBER ;
      INSURRANCE_VALUE_EQ_OLD_V     NUMBER ;
      AMOUNT_PAID_OLD_V             NUMBER ;
      INSURANCE_ENDING_DATE_V       DATE;
      INSURANCE_VALUE_NEW_V         NUMBER;

      ENDORSEMENT_ID_V              NUMBER;

      BRANCH_ID_V                   NUMBER ;
      OFFICE_ID_V                   NUMBER ;
      AGENT_ID_V                    NUMBER ;
      REPRESENTATIVE_ID_V           NUMBER ;
      EMP_ID_V                      NUMBER ;
      CUST_ID_V                     NUMBER ;


      NEW_INSTALLMENT_COUNT_V       NUMBER :=0;
      PAYMENT_METHOD_ID_IN          NUMBER :=0;
      PAYMENT_DUE_ID_IN             NUMBER :=0;
      DUE_DATE_IN                   DATE :=SYSDATE;

      ISSUED_BY_V                   NUMBER;
      ENDORSEMENT_VALUE_V           NUMBER;
      TOTAL_VALUE_V                 NUMBER;
      OLD_PROP_DISCOUNT_VALUE_V     NUMBER;

      END_CNT                   NUMBER;
      PREV_ENDORSEMENT_ID_V     NUMBER ;
      ENDORSEMENT_ID_OUT        NUMBER ;
      ENDORSEMENT_FEES_EQ_V      NUMBER ;
      PROPORTIONAL_FEE_VAL_EQ_V  NUMBER ;
BEGIN

        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------

           -- معرفة حالة الملحق هل مصدر ام لا
        -- اذا كان مصدر لايمكن تعديله
        SELECT ISSUED_BY  INTO  ISSUED_BY_V
        FROM ENDORSEMENTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN  ;

        IF ISSUED_BY_V IS NOT NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(5.15,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        -- DELETE OLD DATA FROM ENDORSMENTS TABLES
        DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN  ,
                    LANG_IN ,
                    ERR_DESC_OUT  ,
                    ERR_STATUS_OUT ) ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;

      -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data

        SELECT
          POLICY_ID , INS_CURR_ID , PROPOSAL_ID
        INTO
          POLICY_ID_V  , CURR_ID_V , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(12.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        --------------------

        SELECT COUNT(*) INTO END_CNT
        FROM  END_POLICIES_TB
        WHERE
              POLICY_ID  = POLICY_ID_V;

        IF END_CNT > 0 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V   ;

            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V ;
                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V ,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID =  PREV_ENDORSEMENT_ID_V;

       ELSE
            SELECT  DISCOUNT_VALUE
            INTO    OLD_PROP_DISCOUNT_VALUE_V
            FROM    MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

                   --Get Policy Data
           SELECT
               POLICY_STATUS_ID  ,
               INSURANCE_STARTING_DATE,
               INSURANCE_ENDING_DATE,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
               AMOUNT_PAID ,
               INSURANCE_ENDING_DATE,ISSUED_BY,
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID
           INTO
               POLICY_STATUS_ID_V  ,
               INSURANCE_STARTING_DATE_V,
               INSURANCE_ENDING_DATE_OLD_V,
               INSURANCE_VALUE_OLD_V, CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V,
               AMOUNT_PAID_OLD_V   ,
               INSURANCE_ENDING_DATE_V   ,ISSUED_BY_V,
               BRANCH_ID_V , OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V
           FROM POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;

            -- فحص هل البوليصة مصدرة
            IF ISSUED_BY_V IS NULL THEN
                ERR_STATUS_OUT := 0 ;
                ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
                RETURN;
           END IF;
       END IF ;

       -- GET   ENDORSEMENT_FEES VALUE
       --ENDORSEMENT_FEES_V := GENERAL_PKG.CALC_SUM_FEES_FN(ENDORSEMENT_NUM_V,CURR_ID_V);
       ENDORSEMENT_FEES_V := NVL(ENDORSEMENT_FEES_IN,0);

        ------------------------------------------

        -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

       ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_V,0) * EQ_PRICE_V ;

       PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

        ------------------------------------------

       ENDORSEMENT_VALUE_V := NVL(PREMIUM_VALUE_IN,0) - NVL(INSURANCE_VALUE_OLD_V,0);

       TOTAL_VALUE_V :=    NVL(PREMIUM_VALUE_IN,0);  --+ NVL(ADDITIONAL_AMOUNT_IN,0);

       INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0);

       --INSURANCE_VALUE_NEW_V :=  NVL(TOTAL_VALUE_V,0) -  NVL(OLD_PROP_DISCOUNT_VALUE_V,0) +  NVL(ENDORSEMENT_FEES_V,0) - NVL(DISCOUNT_VALUE_IN,0);

        MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            ENDORSEMENT_ID_IN  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_V ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            TOTAL_VALUE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_V  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            NEW_INSTALLMENT_COUNT_V  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            ISSUED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

        ----------------------------------------------------------
         -------------------------------------------------------
        -- COPY DATA TO ENDORSMENTS TABLE
           COPY_DATA_TO_END_PR (
                ENDORSEMENT_ID_OUT  ,
                APP_ID_IN   ,
                LANG_IN                       ,
                ERR_DESC_OUT                  ,
                ERR_STATUS_OUT                )  ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;


        DELETE FROM END_MC_ADDITIONAL_COVERAGES_TB
         WHERE
                ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_CONDITIONS_TB
         WHERE
                ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_ENDURINGS_TB
         WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MC_EXCEPTIONS_TB
         WHERE
               ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         DELETE FROM END_MARINE_CARGO_INS_RETENS_TB
         WHERE
               ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

         UPDATE END_MARINE_CARGO_INS_PROPS_TB
         SET
              CLARIFICATION = CLARIFICATION_IN,
              PREMIUM_VALUE = PREMIUM_VALUE + ENDORSEMENT_VALUE_V,
              --ADDITIONAL_AMOUNT = ADDITIONAL_AMOUNT_IN,
              TOTAL_VALUE = TOTAL_VALUE + ENDORSEMENT_VALUE_V,
              INS_AMOUNT_AFTER_DISCOUNT = INSURANCE_VALUE_NEW_V,
              --PROPORTIONAL_FEE_PER         = PROPORTIONAL_FEE_PER + PROPORTIONAL_FEE_PER_IN,
              PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL + PROPORTIONAL_FEE_VAL_IN,
              UPDATED_ON = SYSDATE,
              UPDATED_BY = ISSUED_BY_IN
         WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

          UPDATE END_POLICIES_TB
          SET
               -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
              INSURANCE_VALUE             =   INSURANCE_VALUE_NEW_V          ,
              INSURRANCE_VALUE_EQUIVALENT =   INSURANCE_VALUE_NEW_V *  EQ_PRICE_V,
              END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
              END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
              --PROPORTIONAL_FEE_PER        =   PROPORTIONAL_FEE_PER + NVL(PROPORTIONAL_FEE_PER_IN,0) ,
              PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
              PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0),
              UPDATED_ON = SYSDATE,
                UPDATED_BY = ISSUED_BY_IN
          WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

      --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
       GENERAL_PKG.ADD_TRANSACTION_PR ( 12.35, ENDORSEMENT_ID_IN, NULL, NULL, NULL, INSURANCE_VALUE_NEW_V, ISSUED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
       IF  ERR_STATUS_OUT=0 THEN
          RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
       END IF;
      /*****************************************************************************************************************/


        ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;

 PROCEDURE ADD_END_MC_INSURED_OBJECTS_PR(
           ENDORSEMENT_ID_IN        IN END_MC_INSURED_OBJECTS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN           IN END_MC_INSURED_OBJECTS_TB.PROPOSAL_ID%TYPE,
           INSURED_OBJECT_ID_IN     IN END_MC_INSURED_OBJECTS_TB.INSURED_OBJECT_ID%TYPE,
           LANG_IN                  IN VARCHAR2,
           ERR_DESC_OUT             OUT VARCHAR2,
           ERR_STATUS_OUT           OUT NUMBER)
  AS
  BEGIN
      INSERT INTO   END_MC_INSURED_OBJECTS_TB
            (ENDORSEMENT_ID,PROPOSAL_ID,INSURED_OBJECT_ID)
      VALUES
            (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,INSURED_OBJECT_ID_IN);

      ERR_STATUS_OUT :=1;

  EXCEPTION
      WHEN OTHERS THEN
      ERR_STATUS_OUT :=0 ;
      ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

  END ;


 PROCEDURE ADD_END_MC_PACKAGING_TYPES_PR(
           ENDORSEMENT_ID_IN        IN END_MC_PACKAGING_TYPES_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN           IN END_MC_PACKAGING_TYPES_TB.PROPOSAL_ID%TYPE,
           PACKAGING_TYPE_ID_IN     IN END_MC_PACKAGING_TYPES_TB.PACKAGING_TYPE_ID%TYPE,
           LANG_IN                  IN VARCHAR2,
           ERR_DESC_OUT             OUT VARCHAR2,
           ERR_STATUS_OUT           OUT NUMBER)
 AS
 BEGIN

      INSERT INTO   END_MC_PACKAGING_TYPES_TB
            (ENDORSEMENT_ID,PROPOSAL_ID,PACKAGING_TYPE_ID)
      VALUES
            (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,PACKAGING_TYPE_ID_IN);

      ERR_STATUS_OUT :=1;

 EXCEPTION
      WHEN OTHERS THEN
      ERR_STATUS_OUT :=0 ;
      ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;

 PROCEDURE ADD_END_MC_ADDITION_COVERAG_PR(
           ENDORSEMENT_ID_IN    IN END_MC_ADDITIONAL_COVERAGES_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_ADDITIONAL_COVERAGES_TB.PROPOSAL_ID%TYPE,
           ADD_COVERAGE_ID_IN   IN END_MC_ADDITIONAL_COVERAGES_TB.ADD_COVERAGE_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
            ERR_STATUS_OUT      OUT NUMBER)
 AS
 BEGIN

        INSERT INTO   END_MC_ADDITIONAL_COVERAGES_TB
                (ENDORSEMENT_ID,PROPOSAL_ID,ADD_COVERAGE_ID)
        VALUES
                (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,ADD_COVERAGE_ID_IN);

        ERR_STATUS_OUT :=1;

 EXCEPTION
        WHEN OTHERS THEN
        ERR_STATUS_OUT :=0 ;
        ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;


 PROCEDURE ADD_END_MC_CONDITIONS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_CONDITIONS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_CONDITIONS_TB.PROPOSAL_ID%TYPE,
           CONDITION_ID_IN      IN END_MC_CONDITIONS_TB.CONDITION_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER)
 AS
 BEGIN

        INSERT INTO   END_MC_CONDITIONS_TB
                (ENDORSEMENT_ID,PROPOSAL_ID,CONDITION_ID)
        VALUES
                (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,CONDITION_ID_IN);

        ERR_STATUS_OUT :=1;

 EXCEPTION
        WHEN OTHERS THEN
        ERR_STATUS_OUT :=0 ;
        ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;


 PROCEDURE ADD_END_MC_ENDURINGS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_ENDURINGS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_ENDURINGS_TB.PROPOSAL_ID%TYPE,
           ENDURING_ID_IN       IN END_MC_ENDURINGS_TB.ENDURING_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER)
 AS
 BEGIN

        INSERT INTO   END_MC_ENDURINGS_TB
                (ENDORSEMENT_ID,PROPOSAL_ID,ENDURING_ID)
        VALUES
                (ENDORSEMENT_ID_IN, PROPOSAL_ID_IN,ENDURING_ID_IN);

          ERR_STATUS_OUT :=1;

 EXCEPTION
        WHEN OTHERS THEN
        ERR_STATUS_OUT :=0 ;
        ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;


 PROCEDURE ADD_END_MC_FEE_TYPES_PR(
           ENDORSEMENT_ID_IN        IN END_MC_ENDURINGS_TB.ENDORSEMENT_ID%TYPE,
           FEE_TYPE_ID_IN           IN MC_FEE_TYPES_TB.FEE_TYPE_ID%TYPE,
           FEE_PERCENT_VALUE_IN     IN MC_FEE_TYPES_TB.FEE_PERCENT_VALUE%TYPE,
           FEE_TYPE_PERCENT_IN      IN MC_FEE_TYPES_TB.FEE_TYPE_PERCENT%TYPE,
           FEE_TYPE_VALUE_IN        IN MC_FEE_TYPES_TB.FEE_TYPE_VALUE%TYPE,
           FEE_CURR_ID_IN           IN MC_FEE_TYPES_TB.FEE_CURR_ID%TYPE,
           FEE_VALUE_IN             IN MC_FEE_TYPES_TB.FEE_VALUE%TYPE,
           LANG_IN                  IN VARCHAR2,
           ERR_DESC_OUT             OUT VARCHAR2,
           ERR_STATUS_OUT           OUT NUMBER)

 AS
 BEGIN
          INSERT INTO   END_MC_FEE_TYPES_TB
                ( ENDORSEMENT_ID,
                  FEE_TYPE_ID,
                  FEE_PERCENT_VALUE,
                  FEE_TYPE_PERCENT,
                  FEE_TYPE_VALUE,
                  FEE_CURR_ID ,
                  FEE_VALUE )
          VALUES
                ( ENDORSEMENT_ID_IN,
                  FEE_TYPE_ID_IN ,
                  FEE_PERCENT_VALUE_IN,
                  FEE_TYPE_PERCENT_IN,
                  FEE_TYPE_VALUE_IN,
                  FEE_CURR_ID_IN ,
                  FEE_VALUE_IN
                 );

              ERR_STATUS_OUT :=1;
 EXCEPTION
          WHEN OTHERS THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;

 PROCEDURE ADD_END_MC_EXCEPTIONS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_EXCEPTIONS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_EXCEPTIONS_TB.PROPOSAL_ID%TYPE,
           EXCEPTION_ID_IN      IN END_MC_EXCEPTIONS_TB.EXCEPTION_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER)
 AS
 BEGIN

        INSERT INTO   END_MC_EXCEPTIONS_TB
                (ENDORSEMENT_ID,PROPOSAL_ID,EXCEPTION_ID)
        VALUES
                (ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,EXCEPTION_ID_IN);

        ERR_STATUS_OUT :=1;

 EXCEPTION
        WHEN OTHERS THEN
          ERR_STATUS_OUT :=0 ;
          ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;

 PROCEDURE DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN NUMBER ,
                    LANG_IN IN VARCHAR2,
                    ERR_DESC_OUT  OUT VARCHAR2,
                    ERR_STATUS_OUT   OUT NUMBER)
AS

  BEGIN

        -- حذف البوليصة
        DELETE FROM   END_POLICIES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف التغطيات الإضافية
        DELETE FROM END_MC_ADDITIONAL_COVERAGES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف الشروط
        DELETE FROM END_MC_CONDITIONS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        -- حذف الاستثناءات
        DELETE FROM END_MC_EXCEPTIONS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        --
        DELETE FROM END_MC_ENDURINGS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

                -- حذف الرسوم
        DELETE FROM END_MC_FEE_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        -- حذف الإعيان المؤمنة
        DELETE FROM END_MC_INSURED_OBJECTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف أنواع التعبئة
        DELETE FROM END_MC_PACKAGING_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف طرق الشحن
        DELETE FROM END_MC_TRANSPORTATION_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف التحملات
        DELETE FROM END_MARINE_CARGO_INS_RETENS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات الطلب
        DELETE FROM END_MARINE_CARGO_INS_APPS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات العرض
        DELETE FROM END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات الدفعات
        DELETE FROM END_INSTALLMENTS_TB
        WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات رسوم الملحق
        DELETE FROM ENDORSEMENT_FEES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف الملحق
        DELETE FROM ENDORSEMENTS_TB
        WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        ERR_STATUS_OUT :=1;

  EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;

  PROCEDURE DELETE_HIS_DETAIL_PR(
                    ENDORSEMENT_ID_IN NUMBER ,
                    LANG_IN IN VARCHAR2,
                    ERR_DESC_OUT  OUT VARCHAR2,
                    ERR_STATUS_OUT   OUT NUMBER)
AS

  BEGIN

        -- حذف البوليصة
        DELETE FROM   HIS_POLICIES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف التغطيات الإضافية
        DELETE FROM HIS_MC_ADDITIONAL_COVERAGES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف الشروط
        DELETE FROM HIS_MC_CONDITIONS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        -- حذف الاستثناءات
        DELETE FROM HIS_MC_EXCEPTIONS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        --
        DELETE FROM HIS_MC_ENDURINGS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

                -- حذف الرسوم
        DELETE FROM HIS_MC_FEE_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        -- حذف الإعيان المؤمنة
        DELETE FROM HIS_MC_INSURED_OBJECTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف أنواع التعبئة
        DELETE FROM HIS_MC_PACKAGING_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف طرق الشحن
        DELETE FROM HIS_MC_TRANSPORTATION_TYPES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف التحملات
        DELETE FROM HIS_MARINE_CARGO_INS_RETENS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات الطلب
        DELETE FROM HIS_MARINE_CARGO_INS_APPS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        -- حذف بيانات العرض
        DELETE FROM HIS_MARINE_CARGO_INS_PROPS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN;



        ERR_STATUS_OUT :=1;

  EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


PROCEDURE DEL_ENDOR_PR(
                          ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
                          CREATED_BY_IN     IN NUMBER ,
                          LANG_IN           IN VARCHAR2,
                          ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
                          ERR_STATUS_OUT    OUT NOCOPY NUMBER )

 AS
        ISSUED_BY_V                   NUMBER ;
        APPLICATION_ID_V              NUMBER ;
        CNT                           NUMBER ;
        PREV_ENDORSEMENT_ID_V         NUMBER ;
        INSURANCE_STARTING_DATE_OLD_V DATE ;
        INSURANCE_ENDING_DATE_V       DATE ;

        REM_PERIOD_V                  NUMBER ;
        ENDORSEMENT_DATE_V            DATE ;
        YEAR_DAY_COUNT_V              NUMBER ;

        APP_CURR_ID_V                 NUMBER ;
        BRANCH_ID_V                   NUMBER ;
        CUST_ID_V                     NUMBER ;
        ENDORSEMENT_NUM_V             NUMBER ;
        TRANS_LOG_TYPES_V             NUMBER ;

 BEGIN

        -- فحص هل الطلب له ملحق وغير مصدر

        SELECT ISSUED_BY , CURR_ID ,  BRANCH_ID  , CUST_ID , ENDORSEMENT_NUM
        INTO  ISSUED_BY_V  , APP_CURR_ID_V   ,  BRANCH_ID_V  , CUST_ID_V  , ENDORSEMENT_NUM_V
        FROM ENDORSEMENTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN  ;

        IF ISSUED_BY_V IS NOT NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.16,LANG_IN,SQLERRM);
              RETURN;
        END IF;

         -- حذف الجداول المؤقتة
         -- وحذف الملحق ورسوم الملحق
        --------------------------------------------------
       DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN  ,
                    LANG_IN ,
                    ERR_DESC_OUT  ,
                    ERR_STATUS_OUT    ) ;

       IF  ERR_STATUS_OUT = 0 THEN
              RETURN;
       END IF;


        --- **************ADD TRANSACTION TO CUSTOMERS**************************************************************************************************/
       CASE ENDORSEMENT_NUM_V
         WHEN 13 THEN
         -- حذف ملحق تعديل بيانات الأعيان المؤمنة
              TRANS_LOG_TYPES_V := 12.74;
         WHEN 14 THEN
         -- حذف ملحق تعديل بيانات الشروط والتغطيات
              TRANS_LOG_TYPES_V := 12.75;
         WHEN 15 THEN
         -- حذف ملحق تعديل بيانات الشحن
              TRANS_LOG_TYPES_V := 12.76;
         WHEN 71 THEN
         -- حذف ملحق إلغاء البوليصة
              TRANS_LOG_TYPES_V := 12.77;
         WHEN 85 THEN
         -- حذف ملحق تمديد البوليصة
              TRANS_LOG_TYPES_V := 12.95;
       END CASE ;


        -- GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
        GENERAL_PKG.ADD_TRANSACTION_PR ( TRANS_LOG_TYPES_V, ENDORSEMENT_ID_IN, BRANCH_ID_V, CUST_ID_V, APP_CURR_ID_V, NULL, CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
        IF  ERR_STATUS_OUT=0 THEN
             RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
        END IF;
        /*****************************************************************************************************************/


       ERR_STATUS_OUT :=1;

 EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);

 END ;


 PROCEDURE COPY_DATA_TO_HIS_PR(
  --  نسخ بيانات طلب تامين البحري بمشتقاته الى جداول الهيستوري
           ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
           APP_ID_IN         IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE  ,
           LANG_IN           IN VARCHAR2 ,
           ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
           ERR_STATUS_OUT    OUT NOCOPY NUMBER )
 AS
        POLICY_ID_V            NUMBER ;
        PROPOSAL_ID_V          NUMBER ;
        POLICY_TYPE_V          NUMBER :=7;
        POLICY_TYPE_SUB_CATEGORY_ID_V NUMBER;
        CNT                    NUMBER ;
        PREV_ENDORSEMENT_ID_V  NUMBER ;
 BEGIN


        SELECT PROPOSAL_ID,POLICY_ID
        INTO   PROPOSAL_ID_V,POLICY_ID_V
        FROM   MARINE_CARGO_INS_APPS_TB
            WHERE    APP_ID = APP_ID_IN;

        SELECT POLICY_TYPE_SUB_CATEGORY_ID
        INTO   POLICY_TYPE_SUB_CATEGORY_ID_V
        FROM   POLICIES_TB
            WHERE POLICY_ID = POLICY_ID_V;

        -- نسخ البيانات الى الهيستوي
        INSERT INTO HIS_INSTALLMENTS_TB
            (ENDORSEMENT_ID, APPLICATION_ID, POLICY_TYPE_ID, INST_ID, POLICY_ID,
            INST_STATUS_ID, INST_DATE, CURRENCY_ID, INST_VALUE, INST_LAST_PAYED_ON,
            INST_PAYED_AMOUNT, CUST_ID, CREATED_ON, CREATED_BY,
            POLICY_TYPE_SUB_CATEGORY_ID)
        SELECT
            ENDORSEMENT_ID_IN,APPLICATION_ID, POLICY_TYPE_ID, INST_ID, POLICY_ID,
            INST_STATUS_ID, INST_DATE, CURRENCY_ID, INST_VALUE, INST_LAST_PAYED_ON,
            INST_PAYED_AMOUNT, CUST_ID, CREATED_ON, CREATED_BY,
            POLICY_TYPE_SUB_CATEGORY_ID_V
        FROM INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_V;

        SELECT COUNT(*) INTO CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;

       IF CNT > 1 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V
                AND ENDORSEMENT_ID < ENDORSEMENT_ID_IN ;

            INSERT INTO HIS_MARINE_CARGO_INS_PROPS_TB
            SELECT
                  PROPOSAL_ID, PROPOSAL_TYPE_ID, PROPOSAL_ORDER, PROPOSAL_DATE,
                  PROPOSAL_VALIDATION_IN_DAYS, PROPOSAL_EXPIRY_DATE, REFERENCE, CUST_ID,
                  BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, INS_CURR_ID,
                  INSURED_OBJECT_DESC, COVERAGE_CONDITION_ID, GEO_AREA_ID, RISK_DEGREE_ID,
                  CONTAINERS_COUNT, CONTAINER_SIZE_ID, SHIPPING_CONDITION_ID, DOCUMENTARY_VALUE,
                  ADDITION_RATIO, SHIPPING_RATIO, ROUNDING_RATIO, GOODS_VALUE, INSURANCE_VALUE,
                  CLARIFICATION, PREMIUM_VALUE, ADDITIONAL_AMOUNT, TOTAL_VALUE, DISCOUNT_TYPE,
                  DISCOUNT_PERCENT, DISCOUNT_VALUE, INS_AMOUNT_AFTER_DISCOUNT, PROPORTIONAL_FEE_PER,
                  PROPORTIONAL_FEE_VAL, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                  REPLY_DATE, REPLY_NOTE, PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS,
                  RENEWAL_DATE, RENEWED_PROPOSAL_ID, PROPOSAL_STATUS_ID, PROPOSAL_STATUS_DATE,
                  POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_PROPOSAL_ID, NOTE, ENDORSEMENT_ID_IN,
                  PROCESS_FLAG,INSTALLMENT_COUNT,PREMIUM_PERIOD_ID,DUE_DATE,GRACE_PERIOD,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY, TRIP_FINAL_DESTINATION,
                  DEBTOR_CUST_ID,INSURED_CUST_ID,DEBTOR_TYPE_ID
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V
                  AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

             -- نسخ بيانات الطلب
            INSERT INTO HIS_MARINE_CARGO_INS_APPS_TB
            SELECT
                    APP_ID, PROPOSAL_ID, APP_DATE, INSURANCE_START_DATE, INSURANCE_END_DATE,
                    INS_CURR_ID, LC_BANK_ID, LC_BRANCH_ID, LC, MAX_ARRIVAL_DATE, VESSEL_NAME,
                    TRIP_NUM, LADING_BILL_NUM, VEHICLE_NUM, VEHICLE_MODEL, WAY_BILL_NUM,
                    AIR_WAY_BILL_NUM, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                    PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS, RENEWAL_DATE, RENEWED_APP_ID,
                    APP_STATUS_ID, APP_STATUS_DATE, POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_APP_ID,
                    NOTE, ENDORSEMENT_ID_IN, CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,
                    RULE_AUTH_STATUS_ID, RULE_AUTH_ON
            FROM END_MARINE_CARGO_INS_APPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V
                  AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

              -- نسخ بيانات البوليصة
            INSERT INTO HIS_POLICIES_TB
                  (
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID,
                  INSURANCE_STARTING_DATE, INSURANCE_ENDING_DATE,
                  PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                  INSURANCE_VALUE, CURR_ID,
                  INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID,  ENDORSEMENT_ID,
                  ORIGINAL_INSURANCE_VALUE,ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY , RENEW_ON  ,
                  RETURNED_VALUE , CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
                 )
            SELECT
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID, INSURANCE_STARTING_DATE,
                  INSURANCE_ENDING_DATE, PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID, INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID, ENDORSEMENT_ID_IN, ORIGINAL_INSURANCE_VALUE, ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY, CREATED_ON, CREATED_BY,
                  UPDATED_ON, UPDATED_BY, RENEW_ON ,
                  RETURNED_VALUE ,CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
            FROM END_POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO HIS_MC_TRANSPORTATION_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, TRANSPORTATION_TYPE_ID, TRANSPORTATION_ORDER,
                  AIRPORT_ID_FROM, PORT_ID_FROM, COUNTRY_ID_FROM, STATE_ID_FROM, CITY_ID_FROM,
                  AIRPORT_ID_TO, PORT_ID_TO, COUNTRY_ID_TO, STATE_ID_TO, CITY_ID_TO
            FROM END_MC_TRANSPORTATION_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO HIS_MC_EXCEPTIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, EXCEPTION_ID
            FROM END_MC_EXCEPTIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO HIS_MC_CONDITIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, CONDITION_ID
            FROM END_MC_CONDITIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO HIS_MC_ENDURINGS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ENDURING_ID
            FROM END_MC_ENDURINGS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO HIS_MC_ADDITIONAL_COVERAGES_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ADD_COVERAGE_ID
            FROM END_MC_ADDITIONAL_COVERAGES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO HIS_MC_FEE_TYPES_TB
            SELECT
                ENDORSEMENT_ID_IN , PROPOSAL_ID, FEE_TYPE_ID, FEE_PERCENT_VALUE,
                FEE_TYPE_PERCENT, FEE_TYPE_VALUE, FEE_CURR_ID, FEE_VALUE
            FROM END_MC_FEE_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO HIS_MC_INSURED_OBJECTS_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, INSURED_OBJECT_ID
            FROM END_MC_INSURED_OBJECTS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO HIS_MC_PACKAGING_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, PACKAGING_TYPE_ID
            FROM END_MC_PACKAGING_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

             --التحملات
          INSERT INTO HIS_MARINE_CARGO_INS_RETENS_TB
                 (ENDORSEMENT_ID, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY)
          SELECT
                 ENDORSEMENT_ID_IN, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY
          FROM END_MARINE_CARGO_INS_RETENS_TB
          WHERE
               PROPOSAL_ID = PROPOSAL_ID_V
               AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;
       ----------------------------------------------------
       ----------------------------------------------------

      ELSE
       -- نسخ بيانات العرض


            INSERT INTO HIS_MARINE_CARGO_INS_PROPS_TB
            SELECT
                  PROPOSAL_ID, PROPOSAL_TYPE_ID, PROPOSAL_ORDER, PROPOSAL_DATE,
                  PROPOSAL_VALIDATION_IN_DAYS, PROPOSAL_EXPIRY_DATE, REFERENCE, CUST_ID,
                  BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, INS_CURR_ID,
                  INSURED_OBJECT_DESC, COVERAGE_CONDITION_ID, GEO_AREA_ID, RISK_DEGREE_ID,
                  CONTAINERS_COUNT, CONTAINER_SIZE_ID, SHIPPING_CONDITION_ID, DOCUMENTARY_VALUE,
                  ADDITION_RATIO, SHIPPING_RATIO, ROUNDING_RATIO, GOODS_VALUE, INSURANCE_VALUE,
                  CLARIFICATION, PREMIUM_VALUE, ADDITIONAL_AMOUNT, TOTAL_VALUE, DISCOUNT_TYPE,
                  DISCOUNT_PERCENT, DISCOUNT_VALUE, INS_AMOUNT_AFTER_DISCOUNT, PROPORTIONAL_FEE_PER,
                  PROPORTIONAL_FEE_VAL, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                  REPLY_DATE, REPLY_NOTE, PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS,
                  RENEWAL_DATE, RENEWED_PROPOSAL_ID, PROPOSAL_STATUS_ID, PROPOSAL_STATUS_DATE,
                  POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_PROPOSAL_ID, NOTE, ENDORSEMENT_ID_IN,
                  PROCESS_FLAG,INSTALLMENT_COUNT,PREMIUM_PERIOD_ID,DUE_DATE,GRACE_PERIOD,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY, TRIP_FINAL_DESTINATION,
                  DEBTOR_CUST_ID,INSURED_CUST_ID,DEBTOR_TYPE_ID
            FROM MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V;


             -- نسخ بيانات الطلب
            INSERT INTO HIS_MARINE_CARGO_INS_APPS_TB
            SELECT
                    APP_ID, PROPOSAL_ID, APP_DATE, INSURANCE_START_DATE, INSURANCE_END_DATE,
                    INS_CURR_ID, LC_BANK_ID, LC_BRANCH_ID, LC, MAX_ARRIVAL_DATE, VESSEL_NAME,
                    TRIP_NUM, LADING_BILL_NUM, VEHICLE_NUM, VEHICLE_MODEL, WAY_BILL_NUM,
                    AIR_WAY_BILL_NUM, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                    PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS, RENEWAL_DATE, RENEWED_APP_ID,
                    APP_STATUS_ID, APP_STATUS_DATE, POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_APP_ID,
                    NOTE, ENDORSEMENT_ID_IN, CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,
                    RULE_AUTH_STATUS_ID, RULE_AUTH_ON
            FROM MARINE_CARGO_INS_APPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V;

              -- نسخ بيانات البوليصة
            INSERT INTO HIS_POLICIES_TB
                  (
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID,
                  INSURANCE_STARTING_DATE, INSURANCE_ENDING_DATE,
                  PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                  INSURANCE_VALUE, CURR_ID,
                  INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID,  ENDORSEMENT_ID,
                  ORIGINAL_INSURANCE_VALUE,ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY , RENEW_ON  ,
                  RETURNED_VALUE , CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
                 )
            SELECT
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID, INSURANCE_STARTING_DATE,
                  INSURANCE_ENDING_DATE, PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID, INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID, ENDORSEMENT_ID_IN, ORIGINAL_INSURANCE_VALUE, ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY, CREATED_ON, CREATED_BY,
                  UPDATED_ON, UPDATED_BY, RENEW_ON ,
                  RETURNED_VALUE ,CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID ,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER

            FROM POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;





            INSERT INTO HIS_MC_TRANSPORTATION_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_TRANSPORTATION_TYPES_TB.*
            FROM MC_TRANSPORTATION_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;


            INSERT INTO HIS_MC_EXCEPTIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_EXCEPTIONS_TB.*
            FROM MC_EXCEPTIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;


            INSERT INTO HIS_MC_CONDITIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,MC_CONDITIONS_TB.*
            FROM MC_CONDITIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO HIS_MC_ENDURINGS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ENDURING_ID
            FROM MC_ENDURINGS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO HIS_MC_ADDITIONAL_COVERAGES_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ADD_COVERAGE_ID
            FROM MC_ADDITIONAL_COVERAGES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO HIS_MC_FEE_TYPES_TB
            SELECT
                ENDORSEMENT_ID_IN , MC_FEE_TYPES_TB.*
            FROM MC_FEE_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;



            INSERT INTO HIS_MC_INSURED_OBJECTS_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_INSURED_OBJECTS_TB.*
            FROM MC_INSURED_OBJECTS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO HIS_MC_PACKAGING_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_PACKAGING_TYPES_TB.*
            FROM MC_PACKAGING_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

             --التحملات
          INSERT INTO HIS_MARINE_CARGO_INS_RETENS_TB
                 (ENDORSEMENT_ID, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY)
          SELECT
                 ENDORSEMENT_ID_IN, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY
          FROM MARINE_CARGO_INS_RETENTIONS_TB
          WHERE
               PROPOSAL_ID = PROPOSAL_ID_V;

      END IF ;

      ERR_STATUS_OUT :=1 ;

 EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


 PROCEDURE COPY_DATA_TO_END_PR(
  --  نسخ بيانات طلب تامين البحري بمشتقاته الى جداول الهيستوري
           ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
           APP_ID_IN         IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE  ,
           LANG_IN           IN VARCHAR2 ,
           ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
           ERR_STATUS_OUT    OUT NOCOPY NUMBER )
 AS
        POLICY_ID_V            NUMBER ;
        PROPOSAL_ID_V          NUMBER ;
        POLICY_TYPE_V          NUMBER :=7;
        CNT                    NUMBER ;
        PREV_ENDORSEMENT_ID_V  NUMBER ;
 BEGIN


        SELECT PROPOSAL_ID,POLICY_ID
        INTO   PROPOSAL_ID_V,POLICY_ID_V
        FROM   MARINE_CARGO_INS_APPS_TB
        WHERE    APP_ID = APP_ID_IN;

        SELECT COUNT(*) INTO CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;
       -- نسخ البيانات الى الهيستوي

       IF CNT > 1 THEN

            SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                PROPOSAL_ID  = PROPOSAL_ID_V
                AND ENDORSEMENT_ID < ENDORSEMENT_ID_IN ;

            INSERT INTO END_MARINE_CARGO_INS_PROPS_TB
            SELECT
                  PROPOSAL_ID, PROPOSAL_TYPE_ID, PROPOSAL_ORDER, PROPOSAL_DATE,
                  PROPOSAL_VALIDATION_IN_DAYS, PROPOSAL_EXPIRY_DATE, REFERENCE, CUST_ID,
                  BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, INS_CURR_ID,
                  INSURED_OBJECT_DESC, COVERAGE_CONDITION_ID, GEO_AREA_ID, RISK_DEGREE_ID,
                  CONTAINERS_COUNT, CONTAINER_SIZE_ID, SHIPPING_CONDITION_ID, DOCUMENTARY_VALUE,
                  ADDITION_RATIO, SHIPPING_RATIO, ROUNDING_RATIO, GOODS_VALUE, INSURANCE_VALUE,
                  CLARIFICATION, PREMIUM_VALUE, ADDITIONAL_AMOUNT, TOTAL_VALUE, DISCOUNT_TYPE,
                  DISCOUNT_PERCENT, DISCOUNT_VALUE, INS_AMOUNT_AFTER_DISCOUNT, PROPORTIONAL_FEE_PER,
                  PROPORTIONAL_FEE_VAL, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                  REPLY_DATE, REPLY_NOTE, PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS,
                  RENEWAL_DATE, RENEWED_PROPOSAL_ID, PROPOSAL_STATUS_ID, PROPOSAL_STATUS_DATE,
                  POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_PROPOSAL_ID, NOTE, ENDORSEMENT_ID_IN,
                  PROCESS_FLAG,INSTALLMENT_COUNT,PREMIUM_PERIOD_ID,DUE_DATE,GRACE_PERIOD,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,TRIP_FINAL_DESTINATION,
                  DEBTOR_CUST_ID,INSURED_CUST_ID,DEBTOR_TYPE_ID
            FROM END_MARINE_CARGO_INS_PROPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V
                  AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

             -- نسخ بيانات الطلب
            INSERT INTO END_MARINE_CARGO_INS_APPS_TB
            SELECT
                    APP_ID, PROPOSAL_ID, APP_DATE, INSURANCE_START_DATE, INSURANCE_END_DATE,
                    INS_CURR_ID, LC_BANK_ID, LC_BRANCH_ID, LC, MAX_ARRIVAL_DATE, VESSEL_NAME,
                    TRIP_NUM, LADING_BILL_NUM, VEHICLE_NUM, VEHICLE_MODEL, WAY_BILL_NUM,
                    AIR_WAY_BILL_NUM, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                    PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS, RENEWAL_DATE, RENEWED_APP_ID,
                    APP_STATUS_ID, APP_STATUS_DATE, POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_APP_ID,
                    NOTE, ENDORSEMENT_ID_IN, CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,
                    RULE_AUTH_STATUS_ID, RULE_AUTH_ON
            FROM END_MARINE_CARGO_INS_APPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V
                  AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

              -- نسخ بيانات البوليصة
            INSERT INTO END_POLICIES_TB
                  (
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID,
                  INSURANCE_STARTING_DATE, INSURANCE_ENDING_DATE,
                  PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                  INSURANCE_VALUE, CURR_ID,
                  INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID,  ENDORSEMENT_ID,
                  ORIGINAL_INSURANCE_VALUE,ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY , RENEW_ON  ,
                  RETURNED_VALUE , CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
                 )
            SELECT
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID, INSURANCE_STARTING_DATE,
                  INSURANCE_ENDING_DATE, PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID, INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID, ENDORSEMENT_ID_IN, ORIGINAL_INSURANCE_VALUE, ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY, CREATED_ON, CREATED_BY,
                  UPDATED_ON, UPDATED_BY, RENEW_ON ,
                  RETURNED_VALUE ,CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
            FROM END_POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V
                AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO END_MC_TRANSPORTATION_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, TRANSPORTATION_TYPE_ID, TRANSPORTATION_ORDER,
                  AIRPORT_ID_FROM, PORT_ID_FROM, COUNTRY_ID_FROM, STATE_ID_FROM, CITY_ID_FROM,
                  AIRPORT_ID_TO, PORT_ID_TO, COUNTRY_ID_TO, STATE_ID_TO, CITY_ID_TO
            FROM END_MC_TRANSPORTATION_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO END_MC_EXCEPTIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, EXCEPTION_ID
            FROM END_MC_EXCEPTIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO END_MC_CONDITIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, CONDITION_ID
            FROM END_MC_CONDITIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO END_MC_ENDURINGS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ENDURING_ID
            FROM END_MC_ENDURINGS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO END_MC_ADDITIONAL_COVERAGES_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ADD_COVERAGE_ID
            FROM END_MC_ADDITIONAL_COVERAGES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO END_MC_FEE_TYPES_TB
            SELECT
                ENDORSEMENT_ID_IN , PROPOSAL_ID, FEE_TYPE_ID, FEE_PERCENT_VALUE,
                FEE_TYPE_PERCENT, FEE_TYPE_VALUE, FEE_CURR_ID, FEE_VALUE
            FROM END_MC_FEE_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;



            INSERT INTO END_MC_INSURED_OBJECTS_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, INSURED_OBJECT_ID
            FROM END_MC_INSURED_OBJECTS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


            INSERT INTO END_MC_PACKAGING_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , PROPOSAL_ID, PACKAGING_TYPE_ID
            FROM END_MC_PACKAGING_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V
                 AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

             --التحملات
          INSERT INTO END_MARINE_CARGO_INS_RETENS_TB
                 (ENDORSEMENT_ID, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY)
          SELECT
                 ENDORSEMENT_ID_IN, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY
          FROM END_MARINE_CARGO_INS_RETENS_TB
          WHERE
               PROPOSAL_ID = PROPOSAL_ID_V
               AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;
       ----------------------------------------------------
       ----------------------------------------------------

      ELSE
       -- نسخ بيانات العرض


            INSERT INTO END_MARINE_CARGO_INS_PROPS_TB
            SELECT
                  PROPOSAL_ID, PROPOSAL_TYPE_ID, PROPOSAL_ORDER, PROPOSAL_DATE,
                  PROPOSAL_VALIDATION_IN_DAYS, PROPOSAL_EXPIRY_DATE, REFERENCE, CUST_ID,
                  BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, INS_CURR_ID,
                  INSURED_OBJECT_DESC, COVERAGE_CONDITION_ID, GEO_AREA_ID, RISK_DEGREE_ID,
                  CONTAINERS_COUNT, CONTAINER_SIZE_ID, SHIPPING_CONDITION_ID, DOCUMENTARY_VALUE,
                  ADDITION_RATIO, SHIPPING_RATIO, ROUNDING_RATIO, GOODS_VALUE, INSURANCE_VALUE,
                  CLARIFICATION, PREMIUM_VALUE, ADDITIONAL_AMOUNT, TOTAL_VALUE, DISCOUNT_TYPE,
                  DISCOUNT_PERCENT, DISCOUNT_VALUE, INS_AMOUNT_AFTER_DISCOUNT, PROPORTIONAL_FEE_PER,
                  PROPORTIONAL_FEE_VAL, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                  REPLY_DATE, REPLY_NOTE, PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS,
                  RENEWAL_DATE, RENEWED_PROPOSAL_ID, PROPOSAL_STATUS_ID, PROPOSAL_STATUS_DATE,
                  POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_PROPOSAL_ID, NOTE, ENDORSEMENT_ID_IN,
                  PROCESS_FLAG,INSTALLMENT_COUNT,PREMIUM_PERIOD_ID,DUE_DATE,GRACE_PERIOD,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,TRIP_FINAL_DESTINATION,
                  DEBTOR_CUST_ID,INSURED_CUST_ID,DEBTOR_TYPE_ID
            FROM MARINE_CARGO_INS_PROPOSALS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V;


             -- نسخ بيانات الطلب
            INSERT INTO END_MARINE_CARGO_INS_APPS_TB
            SELECT
                    APP_ID, PROPOSAL_ID, APP_DATE, INSURANCE_START_DATE, INSURANCE_END_DATE,
                    INS_CURR_ID, LC_BANK_ID, LC_BRANCH_ID, LC, MAX_ARRIVAL_DATE, VESSEL_NAME,
                    TRIP_NUM, LADING_BILL_NUM, VEHICLE_NUM, VEHICLE_MODEL, WAY_BILL_NUM,
                    AIR_WAY_BILL_NUM, LOCK_STATUS, LOCK_DATE, CANCELLED_FLAG, CUSTOMER_REPLY_ID,
                    PRINT_STATUS, PRINT_DATE, RENEWAL_STATUS, RENEWAL_DATE, RENEWED_APP_ID,
                    APP_STATUS_ID, APP_STATUS_DATE, POLICY_ID, NEW_VERSION_COUNT, PREVIOUS_APP_ID,
                    NOTE, ENDORSEMENT_ID_IN, CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY,
                    RULE_AUTH_STATUS_ID, RULE_AUTH_ON
            FROM MARINE_CARGO_INS_APPS_TB
            WHERE
                  PROPOSAL_ID=PROPOSAL_ID_V;

              -- نسخ بيانات البوليصة
            INSERT INTO END_POLICIES_TB
                  (
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID,
                  INSURANCE_STARTING_DATE, INSURANCE_ENDING_DATE,
                  PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                  INSURANCE_VALUE, CURR_ID,
                  INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID,  ENDORSEMENT_ID,
                  ORIGINAL_INSURANCE_VALUE,ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY,
                  CREATED_ON, CREATED_BY, UPDATED_ON, UPDATED_BY , RENEW_ON  ,
                  RETURNED_VALUE , CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER
                 )
            SELECT
                  POLICY_ID, POLICY_TYPE_ID, POLICY_STATUS_ID, INSURANCE_STARTING_DATE,
                  INSURANCE_ENDING_DATE, PRINT_STATUS, BRANCH_ID, OFFICE_ID, AGENT_ID,
                  REPRESENTATIVE_ID, EMP_ID, CUST_ID, INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT,
                  AMOUNT_PAID, ENDORSEMENT_ID_IN, ORIGINAL_INSURANCE_VALUE, ORIGINAL_INSURRANCE_VALUE_EQU,
                  ISSUED_ON, ISSUED_BY, PRINTED_ON, PRINTED_BY, CREATED_ON, CREATED_BY,
                  UPDATED_ON, UPDATED_BY, RENEW_ON ,
                  RETURNED_VALUE ,CANCELLED_NOTES , CANCELLED_ON , CANCELLED_BY ,
                  POLICY_TYPE_SUB_CATEGORY_ID ,
                  POLICY_FEES_VALUE,POLICY_FEES_VALUE_EQ,
                  END_FEES_VALUE,END_FEES_VALUE_EQ,
                  PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
                  ORIG_PROPORTIONAL_FEE_PER,ORIG_PROPORTIONAL_FEE_VAL,ORIG_PROPORTIONAL_FEE_VAL_EQ,
                  PROP_FLAG,XOL_FLAG,FAC_FLAG,
                  DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID,POLICY_NUMBER

            FROM POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND POLICY_TYPE_ID = POLICY_TYPE_V ;





            INSERT INTO END_MC_TRANSPORTATION_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_TRANSPORTATION_TYPES_TB.*
            FROM MC_TRANSPORTATION_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;


            INSERT INTO END_MC_EXCEPTIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_EXCEPTIONS_TB.*
            FROM MC_EXCEPTIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;


            INSERT INTO END_MC_CONDITIONS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,MC_CONDITIONS_TB.*
            FROM MC_CONDITIONS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO END_MC_ENDURINGS_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ENDURING_ID
            FROM MC_ENDURINGS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO END_MC_ADDITIONAL_COVERAGES_TB
            SELECT
                  ENDORSEMENT_ID_IN ,PROPOSAL_ID, ADD_COVERAGE_ID
            FROM MC_ADDITIONAL_COVERAGES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO END_MC_FEE_TYPES_TB
            SELECT
                ENDORSEMENT_ID_IN , MC_FEE_TYPES_TB.*
            FROM MC_FEE_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;



            INSERT INTO END_MC_INSURED_OBJECTS_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_INSURED_OBJECTS_TB.*
            FROM MC_INSURED_OBJECTS_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

            INSERT INTO END_MC_PACKAGING_TYPES_TB
            SELECT
                  ENDORSEMENT_ID_IN , MC_PACKAGING_TYPES_TB.*
            FROM MC_PACKAGING_TYPES_TB
            WHERE
                 PROPOSAL_ID = PROPOSAL_ID_V ;

             --التحملات
          INSERT INTO END_MARINE_CARGO_INS_RETENS_TB
                 (ENDORSEMENT_ID, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY)
          SELECT
                 ENDORSEMENT_ID_IN, PROPOSAL_ID, RETENTION_TYPE_ID,PERCENT_VALUE,
                 CURR_ID,RETENTION_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                 RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                 CREATED_ON,CREATED_BY,UPDATED_ON,UPDATED_BY
          FROM MARINE_CARGO_INS_RETENTIONS_TB
          WHERE
               PROPOSAL_ID = PROPOSAL_ID_V;

      END IF ;

      ERR_STATUS_OUT :=1 ;

 EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;



 PROCEDURE ISS_ENDOR_PR(
 -- اصدار ملحق  تعديل الاعيان المؤمنةة
                          ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
                          POLICY_ID_IN IN NUMBER ,
                          ISSUED_BY_IN IN ENDORSEMENTS_TB.ISSUED_BY%TYPE,
                          LANG_IN IN VARCHAR2,
                          ERR_DESC_OUT  OUT NOCOPY VARCHAR2,
                          ERR_STATUS_OUT   OUT NOCOPY NUMBER )
 AS

        POLICY_TYPE_V       NUMBER := 7;
        CURR_ID_V           NUMBER ;
        ENDORSEMENT_NUM_V   NUMBER ;
        END_VALUE_V         NUMBER ; -- قيمة الملحق
        SUM_INST_VALUE_V    NUMBER ; -- اجمالي الدفعات للملحق
        END_INST_COUNT_V    NUMBER ; -- عدد الاقساط في الملحق
        MAX_INST_ID_V       NUMBER ; -- اخر قسط في الجدول القديم
        ISSUED_ON_V         DATE;
        INSURANCE_ENDING_DATE_V DATE;
        PROPOSAL_ID_V       NUMBER;
        INSURANCE_VALUE_V                 NUMBER;

        EQ_PRICE_V                        NUMBER ;
        CURR_DECIMAL_V                    NUMBER;

        APP_ID_V            NUMBER ;

        SCREEN_ID_V          NUMBER ;
        TRANS_TYPE_ID_V      NUMBER ;
        TRANS_LOG_TYPES_V    NUMBER ;
        BRANCH_ID_V          NUMBER ;
        CUST_ID_V            NUMBER ;
        END_FEES_VALUE_V     NUMBER ;
        PROPORTIONAL_FEE_PER_V NUMBER ;
        PROPORTIONAL_FEE_VAL_V NUMBER;
        PROPORTIONAL_FEE_VAL_EQ_V NUMBER ;
        AGENT_ID_V           NUMBER ;
        OFFICE_ID_V          NUMBER ;
        REPRESENTATIVE_ID_V  NUMBER ;
        EMP_ID_V             NUMBER ;
        END_PROPORTIONAL_FEE_VAL_V  NUMBER ;
        ENDORSEMENT_FEES_V          NUMBER ;
        CREATED_ON_V        DATE;
        CREATED_BY_V        NUMBER;
        ENDORSEMENT_DATE_V DATE;
        INSURANCE_ENDING_DATE_NEW_V DATE;
        POLICY_STATUS_ID_V NUMBER;
        CNT NUMBER;
        PREV_ENDORSEMENT_ID_V NUMBER;
        PROP_INSURANCE_VALUE_V NUMBER;
        OLD_PROP_INSURANCE_VALUE_V NUMBER;
        ACUAL_INSURANCE_VALUE_V NUMBER;
        BASE_PREMIUM_V NUMBER;
        WAR_PREMIUM_V NUMBER;
        DISCOUNT_VALUE_V NUMBER;
        OLD_DISCOUNT_VALUE_V NUMBER;
        TOTAL_DISCOUNT_V NUMBER;
        MAIN_PREMIUM_VALUE_V NUMBER;
        MESSAGE_ID_V         VARCHAR2(100) := '1.108';

        POLICY_FEES_VALUE_V       NUMBER;

        S_INSURANCE_VALUE_V       NUMBER;
        S_BASE_PREMIUM_V          NUMBER;
        S_OTHER_FEES_V            NUMBER;
        S_ISSUING_FEES_V          NUMBER;
        S_TOTAL_DISCOUNT_V        NUMBER;


        NEW_BASE_PREMIUM_V        NUMBER;
        NEW_OTHER_FEES_V          NUMBER;
        NEW_ISSUING_FEES_V        NUMBER;
        NEW_TOTAL_DISCOUNT_V      NUMBER;

        NEW_DAYS                  NUMBER;
        OLD_DAYS                  NUMBER;
        TOTAL_DAYS                   NUMBER;

        -- تاريخ البوليصة من جدول POLICY_TB
        INS_START_DATE_V             DATE ;
        INS_ENDING_DATE_V            DATE ;

        INSURANCE_FEES_REFUND_FLAG_V NUMBER ;
        DEBTOR_CUST_ID_V             NUMBER;
        DEBTOR_TYPE_ID_V             NUMBER;
        INSURER_CUST_ID_V            NUMBER;
        POLICY_NUMBER_V              NUMBER;

BEGIN
----------------- الفحوصات ---------------------------------------------

        --END_MARINE_CARGO_INS_APPS_TB
        -- جلب بيانات التعديل من الجدول المؤقت
        SELECT
              INSURANCE_VALUE , END_FEES_VALUE,INSURANCE_ENDING_DATE,INSURANCE_STARTING_DATE ,
              POLICY_FEES_VALUE,
              PROPORTIONAL_FEE_PER,PROPORTIONAL_FEE_VAL,PROPORTIONAL_FEE_VAL_EQ,
              CREATED_ON, CREATED_BY, POLICY_STATUS_ID,
              DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID
        INTO
              INSURANCE_VALUE_V , END_FEES_VALUE_V,INSURANCE_ENDING_DATE_V,INS_START_DATE_V,
              POLICY_FEES_VALUE_V,
              PROPORTIONAL_FEE_PER_V,PROPORTIONAL_FEE_VAL_V,PROPORTIONAL_FEE_VAL_EQ_V,
              CREATED_ON_V, CREATED_BY_V, POLICY_STATUS_ID_V,
              DEBTOR_CUST_ID_V, DEBTOR_TYPE_ID_V, INSURER_CUST_ID_V
        FROM
             END_POLICIES_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        SELECT AGENT_ID ,POLICY_NUMBER
        INTO AGENT_ID_V, POLICY_NUMBER_V
        FROM POLICIES_TB
        WHERE  POLICY_ID = POLICY_ID_IN ;

     ----------- GET APPLICATION ID
        SELECT PROPOSAL_ID, NVL(INSURANCE_VALUE,0), NVL(DISCOUNT_VALUE,0)
        INTO PROPOSAL_ID_V, PROP_INSURANCE_VALUE_V, DISCOUNT_VALUE_V
        FROM
               END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        SELECT COUNT(*) INTO CNT
        FROM  END_MARINE_CARGO_INS_PROPS_TB
        WHERE
            PROPOSAL_ID  = PROPOSAL_ID_V;

        IF CNT > 1 THEN
             SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
             FROM END_MARINE_CARGO_INS_PROPS_TB
             WHERE
                  PROPOSAL_ID  = PROPOSAL_ID_V
                  AND ENDORSEMENT_ID < ENDORSEMENT_ID_IN ;

             SELECT NVL(INSURANCE_VALUE,0), NVL(DISCOUNT_VALUE,0)
             INTO OLD_PROP_INSURANCE_VALUE_V, OLD_DISCOUNT_VALUE_V
             FROM END_MARINE_CARGO_INS_PROPS_TB
             WHERE
                  PROPOSAL_ID = PROPOSAL_ID_V
                  AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;
        ELSE
             SELECT NVL(INSURANCE_VALUE,0), NVL(DISCOUNT_VALUE,0)
             INTO OLD_PROP_INSURANCE_VALUE_V, OLD_DISCOUNT_VALUE_V
             FROM MARINE_CARGO_INS_PROPOSALS_TB
             WHERE
                  PROPOSAL_ID = PROPOSAL_ID_V ;
        END IF;

        SELECT APP_ID INTO APP_ID_V
        FROM
               MARINE_CARGO_INS_APPS_TB
        WHERE
            PROPOSAL_ID = PROPOSAL_ID_V ;

        -- CHECK IF THE POLICY ISSUED
        SELECT ISSUED_ON  , CURR_ID     , BRANCH_ID  , CUST_ID  , ENDORSEMENT_NUM ,
               NVL(INSURANCE_VALUE_NEW,0) - NVL(INSURANCE_VALUE_OLD,0) + NVL(ENDORSEMENT_FEES, 0) AS END_VALUE,
                OFFICE_ID, REPRESENTATIVE_ID, EMP_ID,
                ENDORSEMENT_DATE, INSURANCE_ENDING_DATE_NEW,
                PROPORTIONAL_FEE_VAL, ENDORSEMENT_FEES,
                NVL(INSURANCE_VALUE_NEW,0) - NVL(INSURANCE_VALUE_OLD,0) - NVL(PROPORTIONAL_FEE_VAL,0)
        INTO ISSUED_ON_V  , CURR_ID_V   ,  BRANCH_ID_V  , CUST_ID_V , ENDORSEMENT_NUM_V , END_VALUE_V,
                 OFFICE_ID_V, REPRESENTATIVE_ID_V, EMP_ID_V,
                 ENDORSEMENT_DATE_V, INSURANCE_ENDING_DATE_NEW_V,
                 END_PROPORTIONAL_FEE_VAL_V, ENDORSEMENT_FEES_V,
                 MAIN_PREMIUM_VALUE_V
        FROM ENDORSEMENTS_TB
        WHERE
               ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        IF   ISSUED_ON_V  IS NOT NULL THEN
             ERR_STATUS_OUT :=0 ;
             ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.171,LANG_IN,SQLERRM);
             RETURN;
        END IF;

        IF ENDORSEMENT_NUM_V = 71 THEN
             MESSAGE_ID_V := '1.109';
        END IF;

--        GENERAL_PKG.CHECK_CLOSING_PR(
--              ENDORSEMENT_DATE_V,
--              MESSAGE_ID_V,
--              LANG_IN,
--              ERR_DESC_OUT,
--              ERR_STATUS_OUT
--        );
--
--        IF ERR_STATUS_OUT = 0 THEN
--            RETURN;
--        END IF;

       IF END_VALUE_V > 0 THEN
            -- فحص هل قيمة الاقساط = قيمة الملحق
            SELECT SUM(INST_VALUE) AS SUM_INST_VALUE  ,
                   COUNT(INST_ID)  AS END_INST_COUNT
            INTO   SUM_INST_VALUE_V , END_INST_COUNT_V
            FROM END_INSTALLMENTS_TB
            WHERE
                 ENDORSEMENT_ID = ENDORSEMENT_ID_IN;
            -- فحص هل مجموع الاقساط للملحق = قيمة الملحق
            IF SUM_INST_VALUE_V <> END_VALUE_V THEN
                ERR_STATUS_OUT :=0 ;
                ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.172,LANG_IN,SQLERRM);
                RETURN;
            END IF;

            -- فحص هل عدد الاقساط اكبر من صفر
             IF END_INST_COUNT_V = 0 THEN
                ERR_STATUS_OUT :=0 ;
                ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.173,LANG_IN,SQLERRM);
                RETURN;
            END IF;
       END IF;


         -- نسخ البيانات الى الهيستوي
        -- COPY ALL APPLICATION DATA TO HISTORY
        COPY_DATA_TO_HIS_PR( ENDORSEMENT_ID_IN,APP_ID_V,
                             LANG_IN,ERR_DESC_OUT , ERR_STATUS_OUT);

       IF ERR_STATUS_OUT = 0 THEN
             RETURN;
       END IF;

       -- GET EQUVILANT PRICE
       EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(CURR_ID_V);

       CURR_DECIMAL_V :=  GENERAL_PKG.GET_CURR_DECIMAL_FN (CURR_ID_V);

       UPDATE END_POLICIES_TB
       SET
            INSURRANCE_VALUE_EQUIVALENT     = ROUND(INSURANCE_VALUE * EQ_PRICE_V ,CURR_DECIMAL_V ),
            ORIGINAL_INSURRANCE_VALUE_EQU   = ROUND(ORIGINAL_INSURANCE_VALUE * EQ_PRICE_V ,CURR_DECIMAL_V ),
            POLICY_FEES_VALUE_EQ            = ROUND(POLICY_FEES_VALUE * EQ_PRICE_V ,CURR_DECIMAL_V ),
            PROPORTIONAL_FEE_VAL_EQ         = ROUND(PROPORTIONAL_FEE_VAL * EQ_PRICE_V ,CURR_DECIMAL_V ),
            ORIG_PROPORTIONAL_FEE_VAL_EQ    = ROUND(ORIG_PROPORTIONAL_FEE_VAL * EQ_PRICE_V ,CURR_DECIMAL_V )
       WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

       -- تعديل  بيانات الملحق الى مصدر
       -- ENDORSEMENT_TYPE_ID يحمل رقم 1 اي ملحق تعديل بيانات المركبة
       UPDATE   ENDORSEMENTS_TB
       SET
          INSURRANCE_VALUE_EQ_OLD = ROUND(INSURANCE_VALUE_OLD * EQ_PRICE_V ,CURR_DECIMAL_V ),
          INSURRANCE_VALUE_EQ_NEW = ROUND(INSURANCE_VALUE_NEW * EQ_PRICE_V ,CURR_DECIMAL_V ),
          ENDORSEMENT_FEES_EQ     = ROUND(ENDORSEMENT_FEES * EQ_PRICE_V ,CURR_DECIMAL_V ),
          PROPORTIONAL_FEE_VAL_EQ = ROUND(PROPORTIONAL_FEE_VAL * EQ_PRICE_V ,CURR_DECIMAL_V ),
          ISSUED_ON               = SYSDATE ,
          ISSUED_BY               = ISSUED_BY_IN
       WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

------------------------------------------------------
       -- التعديل على جدول الاقساط
        MCT_MARINE_ENDORSEMENT_PKG.INSTALLEMENTS_PROCESS_PR(
              ENDORSEMENT_ID_IN             ,
              ENDORSEMENT_NUM_V             ,
              POLICY_ID_IN                  ,
              POLICY_TYPE_V                 ,
              PROPOSAL_ID_V                 ,
              END_VALUE_V                   ,   -- قيمة الملحق
              INSURANCE_VALUE_V             ,   -- قيمة البوليصة بعد الملحق
              CUST_ID_V                     ,
              ISSUED_BY_IN                  ,
              LANG_IN                       ,
              ERR_DESC_OUT                  ,
              ERR_STATUS_OUT                ) ;
--------------------------------------------------------


       -- التعديل على بداية التأمين ونهاية التأمين في جدول البوالص
       -- Plicy_Tb
       UPDATE POLICIES_TB
       SET
             INSURANCE_VALUE             = INSURANCE_VALUE_V ,
             INSURRANCE_VALUE_EQUIVALENT = INSURANCE_VALUE_V *  EQ_PRICE_V,
             END_FEES_VALUE              = END_FEES_VALUE_V ,
             END_FEES_VALUE_EQ           = END_FEES_VALUE_V * EQ_PRICE_V,
             PROPORTIONAL_FEE_VAL        = PROPORTIONAL_FEE_VAL_V,
             PROPORTIONAL_FEE_VAL_EQ     = ROUND(PROPORTIONAL_FEE_VAL_V * EQ_PRICE_V ,CURR_DECIMAL_V )
       WHERE
          POLICY_ID = POLICY_ID_IN
          AND POLICY_TYPE_ID = POLICY_TYPE_V ;

       -----------------------------------------------------------------------------------
       -- INSERT IN HIS_POLICY_VALUES_TB
       ACUAL_INSURANCE_VALUE_V := PROP_INSURANCE_VALUE_V - OLD_PROP_INSURANCE_VALUE_V;
       TOTAL_DISCOUNT_V := DISCOUNT_VALUE_V - OLD_DISCOUNT_VALUE_V;

       WAR_PREMIUM_V := MARINE_CARGO_PKG.GET_WAR_PREMIUM_FN(NVL(ACUAL_INSURANCE_VALUE_V,0),NVL(MAIN_PREMIUM_VALUE_V,0)) ;

       POLICY_FEES_VALUE_V := 0;

       IF ENDORSEMENT_NUM_V = 71 THEN

                   --  معرفة اعدادات الملحق الخاص بالالغاء حسب نوع البوليصة والنوع الفرعي
           -- وهل الاعدادات لالغاء ملحق او الغاء عين
            SELECT  INSURANCE_FEES_REFUND_FLAG
            INTO  INSURANCE_FEES_REFUND_FLAG_V
            FROM POLICY_CANCEL_SETT_PRICES_TB
            WHERE POLICY_TYPE_ID  = 7
                  AND POLICY_TYPE_SUB_CATEGORY_ID = 1
                  AND IS_POLICY = 1;

            SELECT
                  INSURANCE_ENDING_DATE,INSURANCE_STARTING_DATE
            INTO
                  INS_ENDING_DATE_V,INS_START_DATE_V
            FROM
                 POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_IN ;

            -- عدد ايام التامين للفترة السابقة
            SELECT TO_DATE(INS_ENDING_DATE_V,'DD-MM-YYYY') - TO_DATE(INS_START_DATE_V,'DD-MM-YYYY') + 1
            INTO TOTAL_DAYS
            FROM DUAL;

            -- عدد ايام التامين لغاية يوم حفظ الملحق
            SELECT TO_DATE(ENDORSEMENT_DATE_V,'DD-MM-YYYY') - TO_DATE(INS_START_DATE_V,'DD-MM-YYYY')
            INTO OLD_DAYS
            FROM DUAL;

            IF OLD_DAYS < 0 THEN
                OLD_DAYS := 0;
            END IF;

            NEW_DAYS :=  TOTAL_DAYS - OLD_DAYS ;

            -- جلب بيانات مجموع كلا من القسط الاساسي والاصدار والرسوم الاخرى

            SELECT
                S_INSURANCE_VALUE,
                S_BASE_PREMIUM ,
                S_ISSUING_FEES ,
                S_OTHER_FEES ,
                S_TOTAL_DISCOUNT
            INTO
                S_INSURANCE_VALUE_V,
                S_BASE_PREMIUM_V ,
                S_ISSUING_FEES_V ,
                S_OTHER_FEES_V ,
                S_TOTAL_DISCOUNT_V
            FROM
                SUM_HIS_POLICY_VALUES_VW
            WHERE
                POLICY_ID =  POLICY_ID_IN ;

            NEW_BASE_PREMIUM_V := -1 * (S_BASE_PREMIUM_V * (NEW_DAYS) / (TOTAL_DAYS));

            NEW_OTHER_FEES_V := -1 * (S_OTHER_FEES_V * (NEW_DAYS) / (TOTAL_DAYS));

            NEW_ISSUING_FEES_V := -1 * (S_ISSUING_FEES_V * (NEW_DAYS) / (TOTAL_DAYS));

            NEW_TOTAL_DISCOUNT_V := -1 * (S_TOTAL_DISCOUNT_V * (NEW_DAYS) / (TOTAL_DAYS));

            IF NVL(INSURANCE_FEES_REFUND_FLAG_V,0) = 0 THEN
                 NEW_ISSUING_FEES_V := 0 ;
            END IF;

            -- Canceld by ahmed kullab at 19/12/2018
--            MAIN_PREMIUM_VALUE_V := NEW_BASE_PREMIUM_V ;
--            POLICY_FEES_VALUE_V  := NEW_OTHER_FEES_V  ;
--            END_PROPORTIONAL_FEE_VAL_V := NEW_ISSUING_FEES_V ;
--            TOTAL_DISCOUNT_V := NEW_TOTAL_DISCOUNT_V;

            ACUAL_INSURANCE_VALUE_V := S_INSURANCE_VALUE_V * -1  ;

            WAR_PREMIUM_V := -1 * MARINE_CARGO_PKG.GET_WAR_PREMIUM_FN(
                                    NVL(S_INSURANCE_VALUE_V,0),
                                    NVL(MAIN_PREMIUM_VALUE_V,0)) ;

       -- نهاية فحص هل الملحق هو الغاء
       END IF;


       INSERT INTO HIS_POLICY_VALUES_TB
            (POLICY_ID, ENDORSEMENT_ID, POLICY_NUMBER, APP_ID, POLICY_TYPE_ID,
            POLICY_TYPE_SUB_CATEGORY_ID, CUST_ID, BRANCH_ID, OFFICE_ID, AGENT_ID,
            REPRESENTATIVE_ID, EMP_ID,
            INSURANCE_VALUE, INSURANCE_STARTING_DATE, INSURANCE_ENDING_DATE,
            INSURANCE_PERIOD,
            CURR_ID, CURR_EQ_PRICE,
            BASE_PREMIUM,TOTAL_DISCOUNT,
            OTHER_FEES, ISSUING_FEES, ENDORSEMENT_FEES,
            WAR_PREMIUM,
            CREATED_ON, CREATED_BY, ISSUED_ON, ISSUED_BY,
            POLICY_STATUS_ID,
            ACTUAL_ENDING_DATE,
            DEBTOR_CUST_ID, DEBTOR_TYPE_ID, INSURER_CUST_ID)
        VALUES
            (POLICY_ID_IN, ENDORSEMENT_ID_IN, POLICY_NUMBER_V, APP_ID_V, 7,
            1, CUST_ID_V, BRANCH_ID_V, OFFICE_ID_V, AGENT_ID_V,
            REPRESENTATIVE_ID_V, EMP_ID_V,
            ACUAL_INSURANCE_VALUE_V, ENDORSEMENT_DATE_V, INSURANCE_ENDING_DATE_NEW_V,
            INSURANCE_ENDING_DATE_NEW_V - ENDORSEMENT_DATE_V + 1,
            CURR_ID_V, EQ_PRICE_V,
            MAIN_PREMIUM_VALUE_V,
            TOTAL_DISCOUNT_V,
            POLICY_FEES_VALUE_V, END_PROPORTIONAL_FEE_VAL_V, ENDORSEMENT_FEES_V,
            WAR_PREMIUM_V,
            CREATED_ON_V, CREATED_BY_V, SYSDATE, ISSUED_BY_IN,
            POLICY_STATUS_ID_V,
            INSURANCE_ENDING_DATE_NEW_V,
            DEBTOR_CUST_ID_V, DEBTOR_TYPE_ID_V, INSURER_CUST_ID_V);
       --------------------------------------------------------------

       CASE ENDORSEMENT_NUM_V
       WHEN 13 THEN
            -- ملحق تعديل  الاعيان
            SCREEN_ID_V        := 223 ;
            TRANS_TYPE_ID_V    := 76 ;
            TRANS_LOG_TYPES_V  := 12.37;
       WHEN 14 THEN
            -- قيمة شروط التغطية
             SCREEN_ID_V       := 227 ;
             TRANS_TYPE_ID_V   := 77 ;
             TRANS_LOG_TYPES_V := 12.38;
       WHEN 15 THEN
             --  الشحن
             SCREEN_ID_V       := 228 ;
             TRANS_TYPE_ID_V   := 78 ;
             TRANS_LOG_TYPES_V := 12.39 ;
       WHEN 85 THEN
            -- التأمين الهندسي - ملحق  تمديد مدة التأمين - تأمين أخطار المقاولين
             SCREEN_ID_V       := 0 ;
             TRANS_TYPE_ID_V   := 128;
             TRANS_LOG_TYPES_V := 12.91;
             --UPDATE POLICY
             UPDATE POLICIES_TB
             SET
               INSURANCE_ENDING_DATE  = INSURANCE_ENDING_DATE_NEW_V
             WHERE POLICY_ID          = POLICY_ID_IN;
             -----------------------------------------
             UPDATE HIS_POLICY_VALUES_TB
             SET
               ACTUAL_ENDING_DATE = INSURANCE_ENDING_DATE_NEW_V
             WHERE POLICY_ID      = POLICY_ID_IN;
             -----------------------------------------
       WHEN 71 THEN
             --  الغاء
             SCREEN_ID_V       := 1010 ;
             TRANS_TYPE_ID_V   := 79 ;
             TRANS_LOG_TYPES_V := 12.79 ;

             UPDATE POLICIES_TB
             SET
               --INSURANCE_ENDING_DATE    = INSURANCE_ENDING_DATE_V,
               CANCELLED_ON             = INSURANCE_ENDING_DATE_NEW_V,--SYSDATE,
               CANCELLED_BY             = ISSUED_BY_IN,
               POLICY_STATUS_ID         = 2
             WHERE POLICY_ID            = POLICY_ID_IN;
             -----------------------------------------
             UPDATE HIS_POLICY_VALUES_TB
             SET
               ACTUAL_ENDING_DATE = INSURANCE_ENDING_DATE_NEW_V,
               CANCELLED_ON       = INSURANCE_ENDING_DATE_NEW_V,--SYSDATE,
               POLICY_STATUS_ID   = 2
             WHERE POLICY_ID      = POLICY_ID_IN;
             -----------------------------------------

       END CASE ;


                --إضافة القيود للملحق
           ADD_ENDORSEMENT_ENTRIES_PR( CUST_ID_V,AGENT_ID_V,ENDORSEMENT_ID_IN,BRANCH_ID_V,
          CURR_ID_V,SCREEN_ID_V,TRANS_TYPE_ID_V,ISSUED_BY_IN,LANG_IN,ERR_DESC_OUT, ERR_STATUS_OUT);

          IF ERR_STATUS_OUT = 0 THEN
             RETURN;
          END IF;


       --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
       GENERAL_PKG.ADD_TRANSACTION_PR ( TRANS_LOG_TYPES_V, ENDORSEMENT_ID_IN, BRANCH_ID_V  , CUST_ID_V, CURR_ID_V, INSURANCE_VALUE_V, ISSUED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
       IF  ERR_STATUS_OUT=0 THEN
           RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
       END IF;
      /*****************************************************************************************************************/

       ERR_STATUS_OUT :=1;

 EXCEPTION
         WHEN OTHERS THEN
             --  ROLLBACK;
               ERR_STATUS_OUT :=0 ;
               ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
 END ;


 -- ADD ENDOR ENTRIES
   PROCEDURE ADD_ENDORSEMENT_ENTRIES_PR(
          CUST_ID_IN        IN ENDORSEMENTS_TB.CUST_ID%TYPE,
          AGENT_ID_IN       IN ENDORSEMENTS_TB.AGENT_ID%TYPE,
          ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          BRANCH_ID_IN      IN ENDORSEMENTS_TB.BRANCH_ID%TYPE,
          CURRENCY_ID_IN    IN ENDORSEMENTS_TB.CURR_ID%TYPE,
          SCREEN_ID_IN      IN TRANSACTIONS_TB.SCREEN_ID%TYPE,
          TRANS_TYPE_ID_IN  IN TRANSACTIONS_TB.TRANS_TYPE_ID%TYPE,
          CREATED_BY_IN     IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN           IN VARCHAR2,
          ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT    OUT NOCOPY NUMBER) AS

   ACC_LEDGER_ID_V NUMBER;
   ACC_NUM_V       NUMBER;
   CUST_TYPE_V     NUMBER;
   NULL_V          NUMBER;
   CUST_NAME_NA_V   NVARCHAR2(200);
   CUST_NAME_FO_V  NVARCHAR2(200);


                 POLICY_ID_V      NUMBER;
   DEBTOR_CUST_ID_V NUMBER;
   DEBTOR_TYPE_ID_V     NUMBER;

   BEGIN


--           IF AGENT_ID_IN IS NOT NULL THEN
--                -- ??? ??? ???? ????
--              SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
--                FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL10';
--
--              SELECT AGENT_NAME_NA, AGENT_NAME_FO
--              INTO   CUST_NAME_NA_V,CUST_NAME_FO_V
--              FROM   AGENTS_TB
--              WHERE  AGENT_ID = AGENT_ID_IN;
--
--                ACC_NUM_V := AGENT_ID_IN;
--            ELSE
--
--
--               SELECT CUST_TYPE, CUST_NAME_NA, CUST_NAME_FO
--               INTO CUST_TYPE_V ,CUST_NAME_NA_V,CUST_NAME_FO_V
--               FROM CUSTOMERS_TB WHERE CUST_ID = CUST_ID_IN;
--
--
--                    IF CUST_TYPE_V = 1 THEN
--                       SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
--                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL9';
--                    ELSE
--
--                      SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
--                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL1';
--                    END IF;
--
--
--                    ACC_NUM_V := CUST_ID_IN;
--
--            END IF;


           SELECT POLICY_ID
           INTO POLICY_ID_V
           FROM   ENDORSEMENTS_TB
           WHERE ENDORSEMENT_ID= ENDORSEMENT_ID_IN ;


          SELECT  DEBTOR_CUST_ID ,DEBTOR_TYPE_ID
          INTO     DEBTOR_CUST_ID_V ,DEBTOR_TYPE_ID_V
          FROM POLICIES_TB WHERE POLICY_ID = POLICY_ID_V ;



     IF DEBTOR_CUST_ID_V IS NOT NULL AND DEBTOR_TYPE_ID_V =2  THEN
                -- اذا كان يوجد وكيل
              SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
                FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL10';

--              SELECT AGENT_NAME_NA, AGENT_NAME_FO
--              INTO   CUST_NAME_NA_V,CUST_NAME_FO_V
--              FROM   AGENTS_TB
--              WHERE  AGENT_ID = DEBTOR_CUST_ID_V;

                ACC_NUM_V := DEBTOR_CUST_ID_V;

  ELSIF DEBTOR_CUST_ID_V IS NOT NULL AND DEBTOR_TYPE_ID_V =1  THEN

               -- جلب نوع العميل شركة او فرد
               SELECT CUST_TYPE INTO CUST_TYPE_V
               FROM CUSTOMERS_TB WHERE CUST_ID = DEBTOR_CUST_ID_V;

                    -- اذا كان العميل شركة
                    IF CUST_TYPE_V = 1 THEN
                       SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL9';
                    ELSE
                    -- اذا كان العميل فرد
                      SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL1';
                    END IF;
                    ACC_NUM_V := DEBTOR_CUST_ID_V;




            ELSE

               -- اذا كان لا يوجد وكيل
               -- جلب نوع العميل شركة او فرد
              SELECT CUST_TYPE INTO CUST_TYPE_V
               FROM CUSTOMERS_TB WHERE CUST_ID = CUST_ID_IN;


                    -- اذا كان العميل شركة
                    IF CUST_TYPE_V = 1 THEN
                       SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL9';
                    ELSE
                    -- اذا كان العميل فرد
                      SELECT LEDGER_ID INTO ACC_LEDGER_ID_V
                         FROM GL_ACCOUNTS_TB WHERE GL_NO = 'GL1';
                    END IF;


                    ACC_NUM_V := CUST_ID_IN;

            END IF;




                  -- add  account
       EXECUTE IMMEDIATE 'BEGIN FINANCE_PKG.ADD_ACCOUNTS_PR(
                 :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14) ; END;'
                 USING
                 BRANCH_ID_IN,
                 ACC_NUM_V,
                 ACC_LEDGER_ID_V,
                 CURRENCY_ID_IN,
                 0,
                 SYSDATE,
                 CUST_NAME_NA_V,
                 CUST_NAME_FO_V,
                 NULL_V,
                 1,
                 CREATED_BY_IN,
                 'NA',
                 OUT ERR_DESC_OUT,
                 OUT ERR_STATUS_OUT;

          IF ERR_STATUS_OUT = 0 THEN
             RETURN;
          END IF;




--     -- EXECUTE PROCESS TRANSACTION PROCEDURE
       EXECUTE IMMEDIATE 'BEGIN TRANSACTIONS_ENTRIES_PKG.TRANS_ENTRIES_PROCESS_PR(
                 :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17,:18,:19,:20) ; END;'
                 USING
                 'Marine-004',
                 ENDORSEMENT_ID_IN,
                 SYSDATE,
                 BRANCH_ID_IN,
                 NULL_V,
                 ACC_NUM_V,
                 NULL_V,
                 CURRENCY_ID_IN,
                 NULL_V,
                 ACC_LEDGER_ID_V,
                 ' WHERE ENDORSEMENT_ID = '||ENDORSEMENT_ID_IN,
                 NULL_V,
                 NULL_V,
                 CREATED_BY_IN,
                 LANG_IN,
                 OUT ERR_DESC_OUT,
                 OUT ERR_STATUS_OUT,
                 SCREEN_ID_IN,
                 1,
                 TRANS_TYPE_ID_IN;

          IF ERR_STATUS_OUT = 0 THEN
             RETURN;
          END IF;

   END;


FUNCTION GET_CHANGE_FN (
          FIELD_NAME_IN IN VARCHAR2,
          HIS_TABLE_NAME_IN VARCHAR2,
          END_TABLE_NAME_IN VARCHAR2,
          POLICY_ID_IN IN NUMBER,
          ENDORSEMENT_ID_IN IN NUMBER,
          LANG_IN VARCHAR2,
          SYMPOL_IN IN NUMBER DEFAULT NULL
          )  RETURN  VARCHAR2
IS
    FROM_V          VARCHAR2(200);
    TO_V            VARCHAR2(200);
    SYMPOL_FROM_V   VARCHAR2(200);
    SYMPOL_TO_V   VARCHAR2(200);
    FIELD_TYPE_V    VARCHAR2(200);
    END_VALUE_V     VARCHAR2(1000);
    HIS_VALUE_V     VARCHAR2(1000);
    SQL_STMT        VARCHAR2(1000);
    CHANGE_DATA_V   VARCHAR2(1000);
BEGIN
      GENERAL_PKG.SELECT_LABELS_PR(1070,LANG_IN,FROM_V );
      GENERAL_PKG.SELECT_LABELS_PR(1071,LANG_IN,TO_V );

      IF SYMPOL_IN IS NOT NULL THEN
        IF SYMPOL_IN = 1 THEN
            SQL_STMT :=  ' SELECT CURR_SYMBOL_FO
                    FROM ' ||  HIS_TABLE_NAME_IN || '
                    WHERE
                          POLICY_ID = :3
                          AND ENDORSEMENT_ID =  :4'  ;
            EXECUTE IMMEDIATE SQL_STMT INTO  SYMPOL_FROM_V
            USING POLICY_ID_IN , ENDORSEMENT_ID_IN;

            SQL_STMT :=  ' SELECT CURR_SYMBOL_FO
                    FROM ' ||  END_TABLE_NAME_IN || '
                    WHERE
                          POLICY_ID = :3
                          AND ENDORSEMENT_ID =  :4'  ;
            EXECUTE IMMEDIATE SQL_STMT INTO  SYMPOL_TO_V
            USING POLICY_ID_IN , ENDORSEMENT_ID_IN;
        ELSE
            SYMPOL_FROM_V := '%';
            SYMPOL_TO_V := '%';
        END IF;
      END IF;

      SQL_STMT :=  ' SELECT '|| FIELD_NAME_IN ||'
                    FROM ' ||  HIS_TABLE_NAME_IN || '
                    WHERE
                          POLICY_ID = :3
                          AND ENDORSEMENT_ID =  :4'  ;
      EXECUTE IMMEDIATE SQL_STMT INTO  HIS_VALUE_V
      USING POLICY_ID_IN , ENDORSEMENT_ID_IN;

      SQL_STMT :=  ' SELECT '|| FIELD_NAME_IN ||'
                    FROM ' ||  END_TABLE_NAME_IN || '
                    WHERE
                          POLICY_ID = :3
                          AND ENDORSEMENT_ID =  :4'  ;
      EXECUTE IMMEDIATE SQL_STMT INTO END_VALUE_V
      USING POLICY_ID_IN , ENDORSEMENT_ID_IN;

      SQL_STMT :=  ' SELECT DATA_TYPE
                    FROM all_tab_columns
                    WHERE
                          TABLE_NAME = :3 AND
                          COLUMN_NAME = :4 '  ;
      EXECUTE IMMEDIATE SQL_STMT INTO  FIELD_TYPE_V
      USING HIS_TABLE_NAME_IN , FIELD_NAME_IN;

      IF FIELD_TYPE_V = 'DATE' THEN
           IF HIS_VALUE_V IS NOT NULL THEN HIS_VALUE_V := TO_DATE(HIS_VALUE_V,'DD-MM-YYYY'); END IF;
           IF END_VALUE_V IS NOT NULL THEN END_VALUE_V := TO_DATE(END_VALUE_V,'DD-MM-YYYY'); END IF;
      END IF ;

      IF END_VALUE_V IS NULL AND HIS_VALUE_V IS NULL THEN
          CHANGE_DATA_V := '';
      ELSE
           IF HIS_VALUE_V IS NULL AND END_VALUE_V IS NOT NULL THEN
                CHANGE_DATA_V := TO_V || ' ' || END_VALUE_V || '' || SYMPOL_TO_V;
           ELSIF HIS_VALUE_V IS NOT NULL AND END_VALUE_V IS NULL THEN
                CHANGE_DATA_V := FROM_V || ' ' || HIS_VALUE_V || '' || SYMPOL_FROM_V || ' ' || TO_V || ' nothing';
           ELSE
               IF HIS_VALUE_V <> END_VALUE_V THEN
                     CHANGE_DATA_V := FROM_V || ' ' || HIS_VALUE_V || '' || SYMPOL_FROM_V || ' ' || TO_V || ' ' || END_VALUE_V || '' || SYMPOL_TO_V;
               ELSE
                     CHANGE_DATA_V := 'not changed';
               END IF;
           END IF;
      END IF;

      RETURN CHANGE_DATA_V;

EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN '';

END;


PROCEDURE ADD_PERIOD_END_PR(
          -- ملحق تمديد مدة التأمين
         -- اضافة
          ENDORSEMENT_DATE_IN                IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                          IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
		  INSURANCE_ENDING_DATE_NEW_IN       IN ENDORSEMENTS_TB.INSURANCE_ENDING_DATE_NEW%TYPE,

          PROPORTIONAL_FEE_PER_IN            IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN            IN MARINE_CARGO_INS_PROPOSALS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSMENT_VALUE_IN                IN NUMBER ,
          ENDORSEMENT_FEES_IN                IN NUMBER ,
          NOTES_IN                           IN ENDORSEMENTS_TB.NOTES%TYPE,
          CREATED_BY_IN                      IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                            IN VARCHAR2,
          ENDORSEMENT_ID_OUT                 OUT NOCOPY NUMBER ,
          ERR_DESC_OUT                       OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT                     OUT NOCOPY NUMBER )
AS
          PROPOSAL_ID_V                     NUMBER;
          POLICY_ID_V                       NUMBER;
          ENDORSEMENT_NUM_V                 NUMBER := 85;
          CNT                               NUMBER;
          PROP_CURR_ID_V                    NUMBER;  -- عملة العرض
          POLICY_CURR_ID_V                  NUMBER;  -- عملة البوليصة
          EQ_PRICE_V                        NUMBER ;
          INSURANCE_VALUE_OLD_V             NUMBER ;
          INSURRANCE_VALUE_EQ_OLD_V         NUMBER ;
          INSURANCE_ENDING_DATE_V           DATE;
          BRANCH_ID_V                       NUMBER ;
          OFFICE_ID_V                       NUMBER ;
          AGENT_ID_V                        NUMBER ;
          REPRESENTATIVE_ID_V               NUMBER ;
          EMP_ID_V                          NUMBER ;
          CUST_ID_V                         NUMBER ;
          POLICY_STATUS_ID_V                NUMBER ;

          INSTALLMENT_COUNT_NEW_IN          NUMBER :=0;
          PAYMENT_METHOD_ID_IN              NUMBER :=0;
          PAYMENT_DUE_ID_IN                 NUMBER :=0;
          DUE_DATE_IN                       DATE :=SYSDATE;

          OLD_PROP_DISCOUNT_VALUE_V         NUMBER;
          END_CNT                           NUMBER;
          PREV_ENDORSEMENT_ID_V             NUMBER;

          DISCOUNT_VALUE_IN                 NUMBER:=0;
          ENDORSMENT_VALUE_V                NUMBER ;
          ENDORSMENT_INS_VALUE_NEW_V        NUMBER ;
          END_INS_VAL_WITHOUT_FEE_V         NUMBER  ;

          OLD_PREMIUM_VALUE_V               NUMBER ;
          NEW_PREMIUM_VALUE_V               NUMBER ;
          OLD_MAIN_PREMIUM_VALUE_V          NUMBER ;
          NEW_MAIN_PREMIUM_VALUE_V          NUMBER ;
          OLD_TOTAL_VALUE_V                 NUMBER ;
          NEW_TOTAL_VALUE_V                 NUMBER ;
          ISSUED_BY_V                       NUMBER ;
          ENDORSEMENT_FEES_EQ_V             NUMBER ;
          PROPORTIONAL_FEE_VAL_EQ_V         NUMBER ;

BEGIN
        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------
        -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data
        SELECT
          POLICY_ID , PROPOSAL_ID
        INTO
          POLICY_ID_V  , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        SELECT
          INS_CURR_ID, PREMIUM_VALUE,
          TOTAL_VALUE
        INTO
          PROP_CURR_ID_V, OLD_PREMIUM_VALUE_V,
          OLD_TOTAL_VALUE_V
        FROM
            MARINE_CARGO_INS_PROPOSALS_TB
        WHERE
            PROPOSAL_ID = PROPOSAL_ID_V ;

        -- فحص هل الطلب له ملحق وغير مصدر
        SELECT  COUNT(*)  INTO  CNT
        FROM ENDORSEMENTS_TB
        WHERE
            POLICY_ID = POLICY_ID_V
            AND ISSUED_BY IS  NULL ;

        IF CNT > 0 THEN
            ERR_STATUS_OUT :=0 ;
            ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.169,LANG_IN,SQLERRM);
            RETURN;
        END IF ;

      --Get Policy Data
       SELECT COUNT(*) INTO CNT
       FROM  END_POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;

       -- اذا كان هناك ملحق سابق يتم جلب البيانات من بيانات اخر ملحق
       -- والا يتم جلب البيانات من البوليصة
       IF CNT > 0 THEN
           -- جلب رقم اخر ملحق
           SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V ;

          -- Get Application Data
          SELECT
            INS_CURR_ID, PREMIUM_VALUE,
            TOTAL_VALUE
          INTO
            PROP_CURR_ID_V, OLD_PREMIUM_VALUE_V,
            OLD_TOTAL_VALUE_V
          FROM
              END_MARINE_CARGO_INS_PROPS_TB
          WHERE
              PROPOSAL_ID = PROPOSAL_ID_V
              AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

          SELECT POLICY_ID
          INTO POLICY_ID_V
          FROM END_MARINE_CARGO_INS_APPS_TB
          WHERE
            PROPOSAL_ID = PROPOSAL_ID_V
              AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

       END IF ;

        --------------------

       --Get Policy Data
        -- اذا كان هناك ملحق سابق يتم جلب البيانات من بيانات اخر ملحق
        -- والا يتم جلب البيانات من البوليصة
        IF CNT > 0 THEN

            SELECT
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID  ,
               INSURANCE_ENDING_DATE, ISSUED_BY  ,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT

            INTO
               BRANCH_ID_V ,OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V ,
               INSURANCE_ENDING_DATE_V, ISSUED_BY_V ,
               INSURANCE_VALUE_OLD_V, POLICY_CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V
            FROM END_POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;
        ELSE
            SELECT
               BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID  ,
               INSURANCE_ENDING_DATE, ISSUED_BY ,
               INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT
            INTO
               BRANCH_ID_V ,OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V ,
               INSURANCE_ENDING_DATE_V, ISSUED_BY_V,
               INSURANCE_VALUE_OLD_V, POLICY_CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V
            FROM POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V;

            -- فحص هل البوليصة مصدرة
            IF ISSUED_BY_V IS NULL THEN
                ERR_STATUS_OUT :=0 ;
                ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
                RETURN;
            END IF;
        END IF;

       -- فحص إذا كانت البوليصة منتهية
       IF TRUNC(INSURANCE_ENDING_DATE_V) < TRUNC(SYSDATE) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.200',LANG_IN,SQLERRM);
              RETURN;
       END IF ;

       -- فحص إذا كان  تاريخ نهاية التأمين الجديد أقل من تاريخ نهاية التأمين القديم
       IF TRUNC(INSURANCE_ENDING_DATE_NEW_IN) <= TRUNC(INSURANCE_ENDING_DATE_V) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('14.236',LANG_IN,SQLERRM);
              RETURN;
       END IF ;


       SELECT
           POLICY_STATUS_ID
       INTO
           POLICY_STATUS_ID_V
       FROM POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;

       -- فحص إذا كانت البوليصة ملغية
       IF POLICY_STATUS_ID_V = 2 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('12.201',LANG_IN,SQLERRM);
              RETURN;
       END IF ;
        -- اذا كانت عملة البوليصة مختلفة عن عملة العرض
        -- يتم تحويل قيمة الملحق المدخلة الى  عملة العرض

        IF  POLICY_CURR_ID_V <> PROP_CURR_ID_V  THEN
            ENDORSMENT_VALUE_V :=  GENERAL_PKG.GET_EXCHANGE_CROSS_RATE_FN(ENDORSMENT_VALUE_IN ,
                                                                    POLICY_CURR_ID_V , PROP_CURR_ID_V );
        ELSE
            ENDORSMENT_VALUE_V := ENDORSMENT_VALUE_IN ;
        END IF;

        ------------------------------------------

        -- GET EQUVILANT PRICE
        EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(POLICY_CURR_ID_V);

       -- قيمة البوليصة بعد الملحق بدون رسوم الملحق
       -- يتم تخزين القيمة في الملحق
       END_INS_VAL_WITHOUT_FEE_V :=  NVL(INSURANCE_VALUE_OLD_V,0) +
                                            NVL(ENDORSMENT_VALUE_IN,0)   ;

       -- القيمة الجديدة للبوليصة مع رسوم الملحق
       -- سيتم تخزينها في البوليصة
       ENDORSMENT_INS_VALUE_NEW_V :=  NVL(INSURANCE_VALUE_OLD_V,0) +
                                             NVL(ENDORSMENT_VALUE_IN,0)   +
                                             NVL(ENDORSEMENT_FEES_IN,0) ;

        -- قيمة قسط التأمين الجديد  بعملة العرض
        -- = القيمة القديمة + قيمة الملحق بعملة العرض
        NEW_PREMIUM_VALUE_V := OLD_PREMIUM_VALUE_V + ENDORSMENT_VALUE_V ;

        NEW_TOTAL_VALUE_V := OLD_TOTAL_VALUE_V + ENDORSMENT_VALUE_V ;

        MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            NULL  ,                      --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_NEW_IN ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            END_INS_VAL_WITHOUT_FEE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_IN  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            INSTALLMENT_COUNT_NEW_IN  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            CREATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;

        -------------------------------------------------------
        -- COPY DATA TO ENDORSMENTS TABLE
         COPY_DATA_TO_END_PR (
              ENDORSEMENT_ID_OUT,
              APP_ID_IN,
              LANG_IN,
              ERR_DESC_OUT,
              ERR_STATUS_OUT);


        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;
        ----------------------------------------------------------

        -- التعديل على بيانات العرض
        UPDATE  END_MARINE_CARGO_INS_PROPS_TB
        SET
            PREMIUM_VALUE                = NEW_PREMIUM_VALUE_V,
            TOTAL_VALUE                  = NEW_TOTAL_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT    = ENDORSMENT_INS_VALUE_NEW_V,
            PROPORTIONAL_FEE_PER         = PROPORTIONAL_FEE_PER_IN,
            PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL_IN

        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        ----- التعديل على بيانات الطلب
        UPDATE  END_MARINE_CARGO_INS_APPS_TB
        SET
           INSURANCE_END_DATE = INSURANCE_ENDING_DATE_NEW_IN
        WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

        ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_IN,0) * EQ_PRICE_V ;

        PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

        UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
			INSURANCE_ENDING_DATE		=   INSURANCE_ENDING_DATE_NEW_IN,
            INSURANCE_VALUE             =   ENDORSMENT_INS_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   ENDORSMENT_INS_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0)
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;


        -- ************** ADD TRANSACTION TO CUSTOMERS **************************************************************************************************/
        --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
        GENERAL_PKG.ADD_TRANSACTION_PR ( 12.89, ENDORSEMENT_ID_OUT, BRANCH_ID_V, CUST_ID_V , POLICY_CURR_ID_V, ENDORSMENT_INS_VALUE_NEW_V , CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );

        IF  ERR_STATUS_OUT=0 THEN
            RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
        END IF;
        /*****************************************************************************************************************/


        ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT := 0 ;
               ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;

PROCEDURE UPD_PERIOD_END_PR(
          -- ملحق تمديد مدة التأمين
          -- تعديل
          ENDORSEMENT_ID_IN                  IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          ENDORSEMENT_DATE_IN                IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                          IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
		  INSURANCE_ENDING_DATE_NEW_IN      IN ENDORSEMENTS_TB.INSURANCE_ENDING_DATE_NEW%TYPE,

          PROPORTIONAL_FEE_PER_IN            IN MCT_PROPOSALS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN            IN MCT_PROPOSALS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSMENT_VALUE_IN                IN NUMBER ,
          ENDORSEMENT_FEES_IN                IN NUMBER ,
          NOTES_IN                           IN ENDORSEMENTS_TB.NOTES%TYPE,
          CREATED_BY_IN                      IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                            IN VARCHAR2,
          ERR_DESC_OUT                       OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT                     OUT NOCOPY NUMBER )
AS
          PROPOSAL_ID_V                     NUMBER;
          POLICY_ID_V                       NUMBER;
          ENDORSEMENT_NUM_V                 NUMBER := 85;
          CNT                               NUMBER;

          PROP_CURR_ID_V                    NUMBER;  -- عملة العرض
          POLICY_CURR_ID_V                  NUMBER;  -- عملة البوليصة
          EQ_PRICE_V                        NUMBER ;

          INSURANCE_VALUE_OLD_V             NUMBER ;
          INSURRANCE_VALUE_EQ_OLD_V         NUMBER ;

          INSURANCE_ENDING_DATE_V           DATE;

          INSTALLMENT_COUNT_NEW_IN          NUMBER :=0;
          PAYMENT_METHOD_ID_IN              NUMBER :=0;
          PAYMENT_DUE_ID_IN                 NUMBER :=0;
          DUE_DATE_IN                       DATE :=SYSDATE;

          OLD_PROP_DISCOUNT_VALUE_V         NUMBER;
          END_CNT                           NUMBER;
          PREV_ENDORSEMENT_ID_V             NUMBER;

          DISCOUNT_VALUE_IN                 NUMBER:=0;
          ENDORSMENT_VALUE_V                NUMBER ;
          ENDORSMENT_INS_VALUE_NEW_V        NUMBER ;
          END_INS_VAL_WITHOUT_FEE_V         NUMBER  ;

          OLD_PREMIUM_VALUE_V               NUMBER ;
          NEW_PREMIUM_VALUE_V               NUMBER ;
          OLD_MAIN_PREMIUM_VALUE_V          NUMBER ;
          NEW_MAIN_PREMIUM_VALUE_V          NUMBER ;
          OLD_TOTAL_VALUE_V                 NUMBER ;
          NEW_TOTAL_VALUE_V                 NUMBER ;
          ISSUED_BY_V                       NUMBER ;

          BRANCH_ID_V                       NUMBER ;
          OFFICE_ID_V                       NUMBER ;
          AGENT_ID_V                        NUMBER ;
          REPRESENTATIVE_ID_V               NUMBER ;
          EMP_ID_V                          NUMBER ;
          CUST_ID_V                         NUMBER ;

          ENDORSEMENT_ID_OUT                NUMBER ;
          ENDORSEMENT_FEES_EQ_V             NUMBER ;
          PROPORTIONAL_FEE_VAL_EQ_V         NUMBER ;

BEGIN

        -- فحص هل الملحق مصدر
        -- اذا كان مصدر لا يمكن التعديل عليه

        SELECT ISSUED_BY
        INTO  ISSUED_BY_V
        FROM ENDORSEMENTS_TB
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_IN  ;

        IF ISSUED_BY_V IS NOT NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.16,LANG_IN,SQLERRM);
              RETURN;
        END IF;

        -- DELETE OLD DATA FROM ENDORSMENTS TABLES
        DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN  ,
                    LANG_IN ,
                    ERR_DESC_OUT  ,
                    ERR_STATUS_OUT ) ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;


        ----------------- الفحوصات ---------------------------------------------
        ------------------------------------------------------------------------
        -- فحص هل البوليصة مصدرة لهذا الطلب
        -- Get Application Data
        SELECT
          POLICY_ID , PROPOSAL_ID
        INTO
          POLICY_ID_V  , PROPOSAL_ID_V
        FROM
            MARINE_CARGO_INS_APPS_TB
        WHERE
            APP_ID = APP_ID_IN ;

        SELECT
          INS_CURR_ID, PREMIUM_VALUE,
          TOTAL_VALUE
        INTO
          PROP_CURR_ID_V, OLD_PREMIUM_VALUE_V,
          OLD_TOTAL_VALUE_V
        FROM
            MARINE_CARGO_INS_PROPOSALS_TB
        WHERE
            PROPOSAL_ID = PROPOSAL_ID_V ;


        IF POLICY_ID_V IS NULL THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
              RETURN;
        END IF;

      --Get Policy Data
       SELECT COUNT(*) INTO CNT
       FROM  END_POLICIES_TB
       WHERE
            POLICY_ID = POLICY_ID_V;
       -- اذا كان هناك ملحق سابق يتم جلب البيانات من بيانات اخر ملحق
       -- والا يتم جلب البيانات من البوليصة
       IF CNT > 0 THEN
           -- جلب رقم اخر ملحق
           SELECT MAX(ENDORSEMENT_ID)  INTO PREV_ENDORSEMENT_ID_V
           FROM END_POLICIES_TB
           WHERE
                POLICY_ID = POLICY_ID_V ;

          -- Get Application Data
          SELECT
            POLICY_ID, INS_CURR_ID, PREMIUM_VALUE,
            TOTAL_VALUE
          INTO
            POLICY_ID_V, PROP_CURR_ID_V, OLD_PREMIUM_VALUE_V,
            OLD_TOTAL_VALUE_V
          FROM
              END_MARINE_CARGO_INS_PROPS_TB
          WHERE
              PROPOSAL_ID = PROPOSAL_ID_V
              AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;

          SELECT POLICY_ID
          INTO POLICY_ID_V
          FROM END_MARINE_CARGO_INS_APPS_TB
          WHERE
            PROPOSAL_ID = PROPOSAL_ID_V
              AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;


       END IF ;


        -- اذا كان هناك ملحق سابق يتم جلب البيانات من بيانات اخر ملحق
        -- والا يتم جلب البيانات من البوليصة
        IF CNT > 0 THEN
            -- جلب رقم اخر ملحق

            SELECT
                BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID  ,
                INSURANCE_ENDING_DATE, ISSUED_BY  ,
                INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT

            INTO
                BRANCH_ID_V ,OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V ,
                INSURANCE_ENDING_DATE_V, ISSUED_BY_V ,
                INSURANCE_VALUE_OLD_V, POLICY_CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V
            FROM END_POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V
                AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V ;
        ELSE
            SELECT
                BRANCH_ID ,OFFICE_ID, AGENT_ID,REPRESENTATIVE_ID,EMP_ID,CUST_ID  ,
                INSURANCE_ENDING_DATE, ISSUED_BY ,
                INSURANCE_VALUE, CURR_ID, INSURRANCE_VALUE_EQUIVALENT
            INTO
                BRANCH_ID_V ,OFFICE_ID_V, AGENT_ID_V,REPRESENTATIVE_ID_V,EMP_ID_V,CUST_ID_V ,
                INSURANCE_ENDING_DATE_V, ISSUED_BY_V,
                INSURANCE_VALUE_OLD_V, POLICY_CURR_ID_V, INSURRANCE_VALUE_EQ_OLD_V
            FROM POLICIES_TB
            WHERE
                POLICY_ID = POLICY_ID_V;

            -- فحص هل البوليصة مصدرة
            IF ISSUED_BY_V IS NULL THEN
                ERR_STATUS_OUT := 0 ;
                ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(14.168,LANG_IN,SQLERRM);
                RETURN;
           END IF;

        END IF;

       -- فحص إذا كان  تاريخ نهاية التأمين الجديد أقل من تاريخ نهاية التأمين القديم
       IF TRUNC(INSURANCE_ENDING_DATE_NEW_IN) <= TRUNC(INSURANCE_ENDING_DATE_V) THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('14.236',LANG_IN,SQLERRM);
              RETURN;
       END IF ;


        -- اذا كانت عملة البوليصة مختلفة عن عملة العرض
        -- يتم تحويل قيمة الملحق المدخلة الى  عملة العرض
        IF  POLICY_CURR_ID_V <> PROP_CURR_ID_V  THEN
            ENDORSMENT_VALUE_V := GENERAL_PKG.GET_EXCHANGE_CROSS_RATE_FN(ENDORSMENT_VALUE_IN ,
                                           POLICY_CURR_ID_V , PROP_CURR_ID_V );
        ELSE
            ENDORSMENT_VALUE_V := ENDORSMENT_VALUE_IN ;
        END IF;

        ------------------------------------------
        -- GET EQUVILANT PRICE
        EQ_PRICE_V := GENERAL_PKG.GET_CURR_MID_PRICE_FN(POLICY_CURR_ID_V);

        -- قيمة البوليصة بعد الملحق بدون رسوم الملحق
        -- يتم تخزين القيمة في الملحق
--        END_INS_VAL_WITHOUT_FEE_V :=  ROUND(NVL(INSURANCE_VALUE_OLD_V,0) +
--                                            NVL(ENDORSMENT_VALUE_IN,0)  ,0) ;
        END_INS_VAL_WITHOUT_FEE_V :=  NVL(INSURANCE_VALUE_OLD_V,0) +
                                            NVL(ENDORSMENT_VALUE_IN,0) ;
        -- القمة الجديدة للبوليصة مع رسوم الملحق
        -- سيتم تخزينها في البوليصة
        ENDORSMENT_INS_VALUE_NEW_V :=  NVL(INSURANCE_VALUE_OLD_V,0) +
                                              NVL(ENDORSMENT_VALUE_IN,0)   +
                                              NVL(ENDORSEMENT_FEES_IN,0) ;

        -- قيمة قسط التأمين الجديد  بعملة العرض
        -- = القيمة القديمة + قيمة الملحق بعملة العرض
        NEW_PREMIUM_VALUE_V := OLD_PREMIUM_VALUE_V + ENDORSMENT_VALUE_V ;

        NEW_TOTAL_VALUE_V := OLD_TOTAL_VALUE_V + ENDORSMENT_VALUE_V ;

        MCT_MARINE_ENDORSEMENT_PKG.ADD_ENDORSMENTS_PR(
            ENDORSEMENT_ID_IN  ,             --  ENDORSEMENT_ID_IN
            ENDORSEMENT_NUM_V ,
            POLICY_ID_V  ,
            ENDORSEMENT_DATE_IN  ,
            INSURANCE_ENDING_DATE_NEW_IN ,     -- تاريخ نهاية التأمين الجديد اذا تغير
            EQ_PRICE_V   ,
            END_INS_VAL_WITHOUT_FEE_V ,  -- INSURANCE_VALUE_NEW = OLD + END_VALUE
            ENDORSEMENT_FEES_IN  ,       -- ENDORSEMENT_FEES
            PROPORTIONAL_FEE_PER_IN ,    -- الرسوم النسبية
            PROPORTIONAL_FEE_VAL_IN,     -- قيمة الرسوم النسبية
            NOTES_IN   ,                 -- NOTES
            0  ,                         -- DISCOUNT_VALUE
            PAYMENT_METHOD_ID_IN ,       -- PAYMENT_METHOD_ID
            PAYMENT_DUE_ID_IN  ,         -- PAYMENT_DUE_ID
            INSTALLMENT_COUNT_NEW_IN  ,  -- INSTALLMENT_COUNT_NEW_IN
            DUE_DATE_IN  ,               -- DUE_DATE
            0    ,                       -- ADJUSTMENT_VALUE
            ENDORSEMENT_ID_OUT   ,       -- ENDORSEMENT_ID_OUT
            CREATED_BY_IN   ,
            LANG_IN                       ,
            ERR_DESC_OUT                  ,
            ERR_STATUS_OUT                )  ;


        -------------------------------------------------------
        -- COPY DATA TO ENDORSMENTS TABLE
           COPY_DATA_TO_END_PR (
                ENDORSEMENT_ID_OUT  ,
                APP_ID_IN   ,
                LANG_IN                       ,
                ERR_DESC_OUT                  ,
                ERR_STATUS_OUT                )  ;

        IF  ERR_STATUS_OUT = 0 THEN
            RETURN;
        END IF;
        ----------------------------------------------------------

        -- التعديل على بيانات العرض
        UPDATE  END_MARINE_CARGO_INS_PROPS_TB
        SET
            PREMIUM_VALUE                = NEW_PREMIUM_VALUE_V,
            TOTAL_VALUE                  = NEW_TOTAL_VALUE_V,
            INS_AMOUNT_AFTER_DISCOUNT    = ENDORSMENT_INS_VALUE_NEW_V,
            PROPORTIONAL_FEE_VAL         = PROPORTIONAL_FEE_VAL_IN
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        ----- التعديل على بيانات الطلب
        UPDATE  END_MARINE_CARGO_INS_APPS_TB
        SET
           INSURANCE_END_DATE = INSURANCE_ENDING_DATE_NEW_IN
        WHERE
           ENDORSEMENT_ID = ENDORSEMENT_ID_OUT;

        ENDORSEMENT_FEES_EQ_V := NVL(ENDORSEMENT_FEES_IN,0) * EQ_PRICE_V ;

        PROPORTIONAL_FEE_VAL_EQ_V := NVL(PROPORTIONAL_FEE_VAL_IN,0) * EQ_PRICE_V ;

        UPDATE END_POLICIES_TB
        SET
             -- القيمة القديمة + قيمة الملحق + قيمة رسوم الملحق
            INSURANCE_ENDING_DATE		=   INSURANCE_ENDING_DATE_NEW_IN,
            INSURANCE_VALUE             =   ENDORSMENT_INS_VALUE_NEW_V          ,
            INSURRANCE_VALUE_EQUIVALENT =   ENDORSMENT_INS_VALUE_NEW_V *  EQ_PRICE_V,
            END_FEES_VALUE              =   NVL(END_FEES_VALUE,0) + NVL(ENDORSEMENT_FEES_IN,0) ,
            END_FEES_VALUE_EQ           =   NVL(END_FEES_VALUE_EQ,0) + ENDORSEMENT_FEES_EQ_V,
            PROPORTIONAL_FEE_VAL        =   PROPORTIONAL_FEE_VAL + NVL(PROPORTIONAL_FEE_VAL_IN,0) ,
            PROPORTIONAL_FEE_VAL_EQ     =   PROPORTIONAL_FEE_VAL_EQ + NVL(PROPORTIONAL_FEE_VAL_EQ_V,0)
        WHERE
            ENDORSEMENT_ID = ENDORSEMENT_ID_OUT ;

        --- ************** ADD TRANSACTION TO CUSTOMERS **************************************************************************************************/
        --GENERAL_PKG.ADD_TRANSACTION_PR(DOC_TYPE_IN,DOC_NO_IN,BRANCH_ID_IN,CUST_ID_IN,CURR_ID_IN,TRANS_AMOUNT_IN,USER_ID_IN,LANG_IN,RR_DESC_OUT,ERR_STATUS_OUT);
        GENERAL_PKG.ADD_TRANSACTION_PR ( 12.90 , ENDORSEMENT_ID_OUT, BRANCH_ID_V, CUST_ID_V , POLICY_CURR_ID_V, 0, CREATED_BY_IN,  LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT  );
        IF  ERR_STATUS_OUT=0 THEN
            RAISE_APPLICATION_ERROR(-20011, ' ERROR IN GENERAL_PKG.ADD_TRANSACTION_PR ');
        END IF;
        /*****************************************************************************************************************/


    ERR_STATUS_OUT :=1;

EXCEPTION
         WHEN OTHERS THEN
               ERR_STATUS_OUT := 0 ;
               ERR_DESC_OUT   := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;

PROCEDURE DEL_MARINE_ENDORSEMENTS_PR(
-------------- حذف ملاحق التأمين الهندسي المصدرة -----------
          ENDORSEMENT_ID_IN          IN DELETED_ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          POLICY_ID_IN               IN DELETED_ENDORSEMENTS_TB.POLICY_ID%TYPE,
          POLICY_DEL_REASON_ID_IN    IN DELETED_ENDORSEMENTS_TB.POLICY_DEL_REASON_ID%TYPE,
          NOTES_IN                   IN DELETED_ENDORSEMENTS_TB.CANCELLED_NOTES%TYPE,
          CREATED_BY_IN              IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                    IN VARCHAR2,
          ERR_DESC_OUT               OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT             OUT NOCOPY NUMBER )
AS

   COUNT_V                          NUMBER;
   ISSUED_ON_V                      DATE;
   POLICY_TYPE_ID_V                 NUMBER;
   POLICY_TYPE_SUB_CATEGORY_ID_V    NUMBER;
   INSURANCE_VALUE_V                NUMBER;
   INSURRANCE_VALUE_EQUIVALENT_V    NUMBER;
   END_FEES_VALUE_V                 NUMBER;
   END_FEES_VALUE_EQ_V              NUMBER;
   PROPORTIONAL_FEE_VAL_EQ_V        NUMBER;
   INSURANCE_STARTING_DATE_V        DATE;
   INSURANCE_ENDING_DATE_V          DATE;
   ENDORSEMENT_NUM_V                NUMBER;
   CNT                              NUMBER;
   ENDORSEMENT_DATE_V               DATE;
   DIFFERENCE_VALUE_V               NUMBER;
   PRIC_V                           NUMBER;

   PREV_ENDORSEMENT_ID_V            NUMBER;
   INST_VALUE_V                     NUMBER;
   HIS_INST_VALUE_V                 NUMBER;
   ENDORSEMENT_ID_V                 NUMBER;
   PROPORTIONAL_FEE_VAL_V           NUMBER;
   HIS_COUNT_V                      NUMBER;
   TRANS_TYPE_V                       NUMBER;
   NEW_TRANS_TYPE_V                    NUMBER:=163;
   POLICY_TYPE_CAT_NA_V                  NVARCHAR2(200);
    POLICY_TYPE_NA_V                      NVARCHAR2(200);

BEGIN

        SELECT COUNT(*)
        INTO COUNT_V
        FROM HIS_INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID = ENDORSEMENT_ID_IN;


        IF COUNT_V = 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('1.134',LANG_IN,SQLERRM);
              RETURN;
        END IF;


        SELECT POLICY_TYPE_ID, POLICY_TYPE_SUB_CATEGORY_ID
        INTO POLICY_TYPE_ID_V, POLICY_TYPE_SUB_CATEGORY_ID_V
        FROM POLICIES_TB
        WHERE POLICY_ID = POLICY_ID_IN;

        SELECT ENDORSEMENT_NUM, ENDORSEMENT_DATE
        INTO ENDORSEMENT_NUM_V ,ENDORSEMENT_DATE_V
        FROM ENDORSEMENTS_TB
        WHERE ENDORSEMENT_ID =  ENDORSEMENT_ID_IN;

        ------- فحص إذا كان هناك حوادث -------
        SELECT COUNT(*) INTO COUNT_V
        FROM GEN_ACCIDENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ACCIDENT_DATE >= ENDORSEMENT_DATE_V;

        IF COUNT_V > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('11',LANG_IN,SQLERRM);
              RETURN;
        END IF;

        ------  فحص إذا كان هناك ملاحق  اكبر  من الملحق الحالي -------
        SELECT COUNT(*) INTO COUNT_V
        FROM ENDORSEMENTS_TB
        WHERE POLICY_TYPE_ID = POLICY_TYPE_ID_V
        AND POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID > ENDORSEMENT_ID_IN;

        IF COUNT_V > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('2.30',LANG_IN,SQLERRM);
              RETURN;
        END IF;

        SELECT COUNT(*)
        INTO  COUNT_V
        FROM ENDORSEMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ISSUED_ON IS NULL;

        -- اذا كان هناك ملاحق غير مصدرة على نفس البوليصة لا يمكن الحذف
        IF COUNT_V <> 0 THEN
            ERR_STATUS_OUT :=0 ;
            ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('2.30',LANG_IN,SQLERRM);
            RETURN;
        END IF;

        ------- فحص إذا كان هناك إعادة تأمين اختياري -------
        SELECT COUNT(*) INTO CNT
        FROM FAC_REINSURANCE_APPS_TB
        WHERE POLICY_TYPE_ID = POLICY_TYPE_ID_V
        AND POLICY_TYPE_SUB_CATEGORY_ID = POLICY_TYPE_SUB_CATEGORY_ID_V
        AND POLICY_ID = POLICY_ID_IN;

        IF CNT > 0 THEN
              ERR_STATUS_OUT :=0 ;
              ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('13',LANG_IN,SQLERRM);
              RETURN;
        END IF;

        -- فحص الإغلاق
        GENERAL_PKG.CHECK_CLOSING_PR(
            ENDORSEMENT_DATE_V,
            '1.108',
            LANG_IN,
            ERR_DESC_OUT,
            ERR_STATUS_OUT
        );

        IF ERR_STATUS_OUT = 0 THEN
          RETURN;
        END IF;


        SELECT COUNT(*) INTO COUNT_V
        FROM ENDORSEMENTS_TB
        WHERE ENDORSEMENT_ID <>  ENDORSEMENT_ID_IN
        AND POLICY_ID = POLICY_ID_IN;

        IF COUNT_V <> 0 THEN
           SELECT MAX(ENDORSEMENT_ID)
           INTO PREV_ENDORSEMENT_ID_V
           FROM ENDORSEMENTS_TB
           WHERE ENDORSEMENT_ID <  ENDORSEMENT_ID_IN
           AND POLICY_ID = POLICY_ID_IN;
        ELSE
           PREV_ENDORSEMENT_ID_V := 0;
        END IF;

        SELECT INSURANCE_STARTING_DATE,INSURANCE_ENDING_DATE
        INTO INSURANCE_STARTING_DATE_V,INSURANCE_ENDING_DATE_V
        FROM HIS_POLICY_VALUES_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID = PREV_ENDORSEMENT_ID_V;

         --  فحص قيمة الدفعات المدفوعة هل تتساوى مع الهستوري للملحق السابق
        SELECT SUM(INST_PAYED_AMOUNT)
        INTO INST_VALUE_V
        FROM INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN;

        SELECT SUM(INST_PAYED_AMOUNT)
        INTO HIS_INST_VALUE_V
        FROM HIS_INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        SELECT COUNT(*)
        INTO COUNT_V
        FROM INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND NVL(INST_PAYED_AMOUNT,0) > 0;

        SELECT COUNT(*)
        INTO HIS_COUNT_V
        FROM HIS_INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID = ENDORSEMENT_ID_IN
        AND NVL(INST_PAYED_AMOUNT,0) > 0;


        IF ( INST_VALUE_V <>  HIS_INST_VALUE_V ) OR (COUNT_V <> HIS_COUNT_V)  THEN
            ERR_STATUS_OUT :=0 ;
            ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN('2.31',LANG_IN,SQLERRM);
            RETURN;
        END IF;

        ENDORSEMENT_ID_V := ENDORSEMENT_ID_IN;

        SELECT INSURANCE_VALUE,INSURRANCE_VALUE_EQUIVALENT,
                END_FEES_VALUE,END_FEES_VALUE_EQ ,
                INSURANCE_ENDING_DATE
        INTO INSURANCE_VALUE_V,INSURRANCE_VALUE_EQUIVALENT_V,
                END_FEES_VALUE_V,END_FEES_VALUE_EQ_V ,
                INSURANCE_ENDING_DATE_V
        FROM HIS_POLICIES_TB
        WHERE
            POLICY_ID = POLICY_ID_IN
            AND ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        SELECT PROPORTIONAL_FEE_VAL
        INTO PROPORTIONAL_FEE_VAL_V
        FROM ENDORSEMENTS_TB
        WHERE ENDORSEMENT_ID = ENDORSEMENT_ID_IN;

        SELECT CURR_EQ_PRICE
        INTO  PRIC_V
        FROM HIS_POLICY_VALUES_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND  ENDORSEMENT_ID = ENDORSEMENT_ID_IN ;

        --تعديل جدول الدفعات
        DELETE FROM INSTALLMENTS_TB WHERE  POLICY_ID = POLICY_ID_IN;

        INSERT INTO INSTALLMENTS_TB
        SELECT  APPLICATION_ID, POLICY_TYPE_ID, INST_ID, POLICY_ID,
          INST_STATUS_ID, INST_DATE, CURRENCY_ID, INST_VALUE, INST_LAST_PAYED_ON,
          INST_PAYED_AMOUNT, CUST_ID, CREATED_ON, CREATED_BY, UPDATED_ON,
          UPDATED_BY,POLICY_TYPE_SUB_CATEGORY_ID
        FROM HIS_INSTALLMENTS_TB
        WHERE POLICY_ID = POLICY_ID_IN
        AND ENDORSEMENT_ID = ENDORSEMENT_ID_V;
        --------------------------------------

        -- حذف بيانات الدفعات من الهستوري
        DELETE FROM HIS_INSTALLMENTS_TB
        WHERE
              ENDORSEMENT_ID = ENDORSEMENT_ID_V;

        -- الإضافة إلى الملاحق المحذوفة
        INSERT INTO DELETED_ENDORSEMENTS_TB
                     (ENDORSEMENT_ID, POLICY_ID, POLICY_TYPE_ID, POLICY_TYPE_SUB_CATEGORY_ID,
                     BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                     POLICY_DEL_REASON_ID, CANCELLED_NOTES, CANCELLED_ON, CANCELLED_BY,ENDORSEMENT_NUM)

         SELECT ENDORSEMENT_ID, POLICY_ID, POLICY_TYPE_ID, POLICY_TYPE_SUB_CATEGORY_ID_V,
                BRANCH_ID, OFFICE_ID, AGENT_ID, REPRESENTATIVE_ID, EMP_ID, CUST_ID,
                POLICY_DEL_REASON_ID_IN, NOTES_IN, SYSDATE, CREATED_BY_IN,ENDORSEMENT_NUM_V
         FROM ENDORSEMENTS_TB
         WHERE ENDORSEMENT_ID = ENDORSEMENT_ID_V  ;


        -------- حذف من ال HIS
        IF POLICY_TYPE_SUB_CATEGORY_ID_V = 1 THEN -- بضائع
             MARINE_ENDORSEMENT_PKG.DELETE_HIS_DETAIL_PR
              (
                ENDORSEMENT_ID_V, LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT
              );
              IF  ERR_STATUS_OUT = 0 THEN
                  RETURN;
              END IF;
        ELSIF POLICY_TYPE_SUB_CATEGORY_ID_V = 3 THEN -- نقل بضائع
             MCT_MARINE_ENDORSEMENT_PKG.DELETE_HIS_DETAIL_PR
              (
                ENDORSEMENT_ID_V, LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT
              );
              IF  ERR_STATUS_OUT = 0 THEN
                  RETURN;
              END IF;
        END IF;

        -------- حذف من ال END
        IF POLICY_TYPE_SUB_CATEGORY_ID_V = 1 THEN -- بضائع
             MARINE_ENDORSEMENT_PKG.DELETE_END_DETAIL_PR
              (
                ENDORSEMENT_ID_V, LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT
              );
              IF  ERR_STATUS_OUT = 0 THEN
                  RETURN;
              END IF;
        ELSIF POLICY_TYPE_SUB_CATEGORY_ID_V = 3 THEN -- نقل بضائع
             MCT_MARINE_ENDORSEMENT_PKG.DELETE_END_DETAIL_PR
              (
                ENDORSEMENT_ID_V, LANG_IN, ERR_DESC_OUT, ERR_STATUS_OUT
              );
              IF  ERR_STATUS_OUT = 0 THEN
                  RETURN;
              END IF;
        END IF;


        DELETE FROM HIS_POLICY_VALUES_TB
        WHERE ENDORSEMENT_ID = ENDORSEMENT_ID_V;

        -- تعديل بيانات البوليصة
        UPDATE POLICIES_TB SET
            INSURANCE_STARTING_DATE     = INSURANCE_STARTING_DATE_V,
            INSURANCE_ENDING_DATE       = INSURANCE_ENDING_DATE_V,
            END_FEES_VALUE              = END_FEES_VALUE_V,
            END_FEES_VALUE_EQ           = END_FEES_VALUE_EQ_V,
            PROPORTIONAL_FEE_VAL        = PROPORTIONAL_FEE_VAL - PROPORTIONAL_FEE_VAL_V,
            PROPORTIONAL_FEE_VAL_EQ     = PROPORTIONAL_FEE_VAL_EQ - ROUND(PROPORTIONAL_FEE_VAL_V*PRIC_V,2) ,
            INSURANCE_VALUE             = INSURANCE_VALUE_V,
            INSURRANCE_VALUE_EQUIVALENT = INSURRANCE_VALUE_EQUIVALENT_V
        WHERE
            POLICY_ID                   = POLICY_ID_IN;

        UPDATE HIS_POLICY_VALUES_TB
        SET
           ACTUAL_ENDING_DATE = INSURANCE_ENDING_DATE_V
        WHERE POLICY_ID       = POLICY_ID_IN;

        --التعديل في حال كان الملحق إلغاء
        IF ENDORSEMENT_NUM_V IN (70,71) THEN
            UPDATE POLICIES_TB
            SET
               CANCELLED_ON           = NULL,
               CANCELLED_BY           = NULL,
               POLICY_STATUS_ID       = 1
            WHERE POLICY_ID           = POLICY_ID_IN;

            UPDATE HIS_POLICY_VALUES_TB
            SET
               CANCELLED_ON       = NULL,
               POLICY_STATUS_ID   = 1
            WHERE POLICY_ID       = POLICY_ID_IN;

        END IF;


           SELECT TRANS_TYPE_ID
        INTO    TRANS_TYPE_V
        FROM  END_SETTINGS_TB
        WHERE ENDORSEMENT_NUM =  ENDORSEMENT_NUM_V ;


             SELECT   POLICY_TYPE_NA
      INTO  POLICY_TYPE_NA_V
      FROM POLICY_TYPES_TB
      WHERE   POLICY_TYPE_ID = POLICY_TYPE_ID_V ;


      SELECT   POLICY_TYPE_SUB_CATEGORY_NA
      INTO  POLICY_TYPE_CAT_NA_V
      FROM POLICY_TYPE_SUB_CATEGORIES_TB
      WHERE   POLICY_TYPE_ID = POLICY_TYPE_ID_V
      AND  POLICY_TYPE_SUB_CATEGORY_ID = POLICY_TYPE_SUB_CATEGORY_ID_V;


                -- Execute delete transaction procedure
    EXECUTE IMMEDIATE 'BEGIN TRANSACTIONS_ENTRIES_PKG.CANCEL_ENTRIES_PROCESS_PR(
                 :1, :2, :3, :4, :5, :6, :7, :8, :9,:10) ; END;'
                 USING
                 'DEL-001',
                 ENDORSEMENT_ID_IN,
                 TRANS_TYPE_V,
                 NEW_TRANS_TYPE_V,
                ' إلغاء ملحق ' || POLICY_TYPE_NA_V || ' - ' || POLICY_TYPE_CAT_NA_V || ' رقم ' ||  ENDORSEMENT_ID_IN ,
                 'Cancel Endoresment ' || POLICY_TYPE_NA_V|| ' - ' || POLICY_TYPE_CAT_NA_V ||   ' رقم ' || ENDORSEMENT_ID_IN ,
                 CREATED_BY_IN,
                 LANG_IN,
                 OUT ERR_DESC_OUT,
                 OUT ERR_STATUS_OUT;

                 IF ERR_STATUS_OUT = 0 THEN
                    RETURN;
                 END IF;

   ERR_STATUS_OUT :=1;
EXCEPTION
WHEN OTHERS THEN
    ERR_STATUS_OUT :=0 ;
    ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END;


PROCEDURE ADD_END_MARINE_RETENTIONS_PR(
--   التحملات
          ENDORSEMENT_ID_IN         IN END_MARINE_CARGO_INS_RETENS_TB.ENDORSEMENT_ID%TYPE,
          PROPOSAL_ID_IN            IN END_MARINE_CARGO_INS_RETENS_TB.PROPOSAL_ID%TYPE,
          RETENTION_TYPE_ID_IN      IN END_MARINE_CARGO_INS_RETENS_TB.RETENTION_TYPE_ID%TYPE,
          RETENTION_VALUE_IN        IN END_MARINE_CARGO_INS_RETENS_TB.RETENTION_VALUE%TYPE,
          CURR_ID_IN                IN END_MARINE_CARGO_INS_RETENS_TB.CURR_ID%TYPE,
          PERCENT_VALUE_IN          IN END_MARINE_CARGO_INS_RETENS_TB.PERCENT_VALUE%TYPE,
          RETENTION_PERCENT_IN      IN END_MARINE_CARGO_INS_RETENS_TB.RETENTION_PERCENT%TYPE,
          RETENTION_SOURCE_IN       IN END_MARINE_CARGO_INS_RETENS_TB.RETENTION_SOURCE%TYPE,
          RETENTION_MIN_LIMIT_IN    IN END_MARINE_CARGO_INS_RETENS_TB.RETENTION_MIN_LIMIT%TYPE,
          RISK_FLAG_IN              IN END_MARINE_CARGO_INS_RETENS_TB.RISK_FLAG%TYPE,
          RISK_ID_IN                IN END_MARINE_CARGO_INS_RETENS_TB.RISK_ID%TYPE,
          CREATED_BY_IN             IN END_MARINE_CARGO_INS_RETENS_TB.CREATED_BY%TYPE,
          LANG_IN                   IN VARCHAR2,
          ERR_DESC_OUT              OUT VARCHAR2,
          ERR_STATUS_OUT            OUT NUMBER)
AS
BEGIN

          INSERT INTO END_MARINE_CARGO_INS_RETENS_TB
                      (
                        ENDORSEMENT_ID,PROPOSAL_ID,RETENTION_TYPE_ID,RETENTION_VALUE,
                        CURR_ID,PERCENT_VALUE,RETENTION_PERCENT,RETENTION_SOURCE,
                        RETENTION_MIN_LIMIT,RISK_FLAG,RISK_ID,
                        CREATED_ON,CREATED_BY
                      )
          VALUES
                      (
                        ENDORSEMENT_ID_IN,PROPOSAL_ID_IN,RETENTION_TYPE_ID_IN,RETENTION_VALUE_IN,
                        CURR_ID_IN,PERCENT_VALUE_IN,RETENTION_PERCENT_IN,RETENTION_SOURCE_IN,
                        RETENTION_MIN_LIMIT_IN,RISK_FLAG_IN,RISK_ID_IN,
                        SYSDATE,CREATED_BY_IN
                      );

          ERR_STATUS_OUT :=1;
EXCEPTION
   WHEN OTHERS THEN
        ERR_STATUS_OUT :=0 ;
        ERR_DESC_OUT := GENERAL_PKG.GET_MESSAGE_FN(SQLCODE,LANG_IN,SQLERRM);
END ;

END;
/