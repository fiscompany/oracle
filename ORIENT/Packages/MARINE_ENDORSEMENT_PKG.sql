CREATE OR REPLACE PACKAGE orient.MARINE_ENDORSEMENT_PKG

AS
TYPE CURSOR_TYPE IS REF CURSOR;
-- This is a copy of the Hora PACKAGE default template. Please modify file
-- C:\Program Files\KeepTool-11\Bin\Templates\ or change file name in the registry below
-- HKEY_CURRENT_USER\Software\KeepTool\Hora\11.0\Forms\dmPlSql\Templates

 PROCEDURE COPY_DATA_TO_END_PR(
  --  نسخ بيانات طلب تامين البحري بمشتقاته الى جداول الهيستوري
           ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
           APP_ID_IN         IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE  ,
           LANG_IN           IN VARCHAR2 ,
           ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
           ERR_STATUS_OUT    OUT NOCOPY NUMBER );

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
            ERR_STATUS_OUT           OUT NOCOPY NUMBER );

 PROCEDURE ADD_END_MC_INSURED_OBJECTS_PR(
           ENDORSEMENT_ID_IN        IN END_MC_INSURED_OBJECTS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN           IN END_MC_INSURED_OBJECTS_TB.PROPOSAL_ID%TYPE,
           INSURED_OBJECT_ID_IN     IN END_MC_INSURED_OBJECTS_TB.INSURED_OBJECT_ID%TYPE,
           LANG_IN                  IN VARCHAR2,
           ERR_DESC_OUT             OUT VARCHAR2,
           ERR_STATUS_OUT           OUT NUMBER);

 PROCEDURE ADD_END_MC_PACKAGING_TYPES_PR(
           ENDORSEMENT_ID_IN        IN END_MC_PACKAGING_TYPES_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN           IN END_MC_PACKAGING_TYPES_TB.PROPOSAL_ID%TYPE,
           PACKAGING_TYPE_ID_IN     IN END_MC_PACKAGING_TYPES_TB.PACKAGING_TYPE_ID%TYPE,
           LANG_IN                  IN VARCHAR2,
           ERR_DESC_OUT             OUT VARCHAR2,
           ERR_STATUS_OUT           OUT NUMBER);


 PROCEDURE ADD_END_MC_ADDITION_COVERAG_PR(
           ENDORSEMENT_ID_IN    IN END_MC_ADDITIONAL_COVERAGES_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_ADDITIONAL_COVERAGES_TB.PROPOSAL_ID%TYPE,
           ADD_COVERAGE_ID_IN   IN END_MC_ADDITIONAL_COVERAGES_TB.ADD_COVERAGE_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
            ERR_STATUS_OUT      OUT NUMBER);


 PROCEDURE ADD_END_MC_CONDITIONS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_CONDITIONS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_CONDITIONS_TB.PROPOSAL_ID%TYPE,
           CONDITION_ID_IN      IN END_MC_CONDITIONS_TB.CONDITION_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER);


 PROCEDURE ADD_END_MC_ENDURINGS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_ENDURINGS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_ENDURINGS_TB.PROPOSAL_ID%TYPE,
           ENDURING_ID_IN       IN END_MC_ENDURINGS_TB.ENDURING_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER);

 PROCEDURE ADD_END_MC_EXCEPTIONS_PR(
           ENDORSEMENT_ID_IN    IN END_MC_EXCEPTIONS_TB.ENDORSEMENT_ID%TYPE,
           PROPOSAL_ID_IN       IN END_MC_EXCEPTIONS_TB.PROPOSAL_ID%TYPE,
           EXCEPTION_ID_IN      IN END_MC_EXCEPTIONS_TB.EXCEPTION_ID%TYPE,
           LANG_IN              IN VARCHAR2,
           ERR_DESC_OUT         OUT VARCHAR2,
           ERR_STATUS_OUT       OUT NUMBER);

 PROCEDURE COPY_DATA_TO_HIS_PR(
  --  نسخ بيانات طلب تامين البحري بمشتقاته الى جداول الهيستوري
           ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
           APP_ID_IN         IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE  ,
           LANG_IN           IN VARCHAR2 ,
           ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
           ERR_STATUS_OUT    OUT NOCOPY NUMBER );


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
          ERR_STATUS_OUT            OUT NOCOPY NUMBER );


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
          ERR_STATUS_OUT              OUT NOCOPY NUMBER );


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
          ERR_STATUS_OUT            OUT NOCOPY NUMBER );

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
           ERR_STATUS_OUT           OUT NUMBER);

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
          ERR_STATUS_OUT                OUT NUMBER);


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
            ERR_STATUS_OUT        OUT NOCOPY NUMBER );


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
          ENDORSEMENT_FEES_IN      IN ENDORSEMENTS_TB.ENDORSEMENT_FEES%TYPE,
          NOTES_IN                   IN ENDORSEMENTS_TB.NOTES%TYPE,
          TRIP_FINAL_DESTINATION_IN  IN MARINE_CARGO_INS_PROPOSALS_TB.TRIP_FINAL_DESTINATION%TYPE,
          UPDATED_BY_IN              IN MARINE_CARGO_INS_PROPOSALS_TB.UPDATED_BY%TYPE,
          LANG_IN                    IN VARCHAR2,
          ERR_DESC_OUT               OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT             OUT NOCOPY NUMBER );

 PROCEDURE ISS_ENDOR_PR(
 -- اصدار ملحق  تعديل الاعيان المؤمنةة
                          ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
                          POLICY_ID_IN IN NUMBER ,
                          ISSUED_BY_IN IN ENDORSEMENTS_TB.ISSUED_BY%TYPE,
                          LANG_IN IN VARCHAR2,
                          ERR_DESC_OUT  OUT NOCOPY VARCHAR2,
                          ERR_STATUS_OUT   OUT NOCOPY NUMBER );

 PROCEDURE DELETE_END_DETAIL_PR(
                    ENDORSEMENT_ID_IN NUMBER ,
                    LANG_IN IN VARCHAR2,
                    ERR_DESC_OUT  OUT VARCHAR2,
                    ERR_STATUS_OUT   OUT NUMBER);

PROCEDURE DELETE_HIS_DETAIL_PR(
                    ENDORSEMENT_ID_IN NUMBER ,
                    LANG_IN IN VARCHAR2,
                    ERR_DESC_OUT  OUT VARCHAR2,
                    ERR_STATUS_OUT   OUT NUMBER);

 PROCEDURE DEL_ENDOR_PR(
                          ENDORSEMENT_ID_IN IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
                          CREATED_BY_IN     IN NUMBER ,
                          LANG_IN           IN VARCHAR2,
                          ERR_DESC_OUT      OUT NOCOPY VARCHAR2,
                          ERR_STATUS_OUT    OUT NOCOPY NUMBER );


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
          ERR_STATUS_OUT    OUT NOCOPY NUMBER) ;

FUNCTION GET_CHANGE_FN (
          FIELD_NAME_IN IN VARCHAR2,
          HIS_TABLE_NAME_IN VARCHAR2,
          END_TABLE_NAME_IN VARCHAR2,
          POLICY_ID_IN IN NUMBER,
          ENDORSEMENT_ID_IN IN NUMBER,
          LANG_IN VARCHAR2,
          SYMPOL_IN IN NUMBER DEFAULT NULL
          )  RETURN  VARCHAR2;

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
          ERR_STATUS_OUT                     OUT NOCOPY NUMBER );

PROCEDURE UPD_PERIOD_END_PR(
          -- ملحق تمديد مدة التأمين
          -- تعديل
          ENDORSEMENT_ID_IN                  IN ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          ENDORSEMENT_DATE_IN                IN ENDORSEMENTS_TB.ENDORSEMENT_DATE%TYPE,
          APP_ID_IN                          IN MARINE_CARGO_INS_APPS_TB.APP_ID%TYPE,
          INSURANCE_ENDING_DATE_NEW_IN       IN ENDORSEMENTS_TB.INSURANCE_ENDING_DATE_NEW%TYPE,

          PROPORTIONAL_FEE_PER_IN            IN MCT_PROPOSALS_TB.PROPORTIONAL_FEE_PER%TYPE,
          PROPORTIONAL_FEE_VAL_IN            IN MCT_PROPOSALS_TB.PROPORTIONAL_FEE_VAL%TYPE,
          ENDORSMENT_VALUE_IN                IN NUMBER ,
          ENDORSEMENT_FEES_IN                IN NUMBER ,
          NOTES_IN                           IN ENDORSEMENTS_TB.NOTES%TYPE,
          CREATED_BY_IN                      IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                            IN VARCHAR2,
          ERR_DESC_OUT                       OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT                     OUT NOCOPY NUMBER );

PROCEDURE DEL_MARINE_ENDORSEMENTS_PR(
-------------- حذف ملاحق التأمين الهندسي المصدرة -----------
          ENDORSEMENT_ID_IN          IN DELETED_ENDORSEMENTS_TB.ENDORSEMENT_ID%TYPE,
          POLICY_ID_IN               IN DELETED_ENDORSEMENTS_TB.POLICY_ID%TYPE,
          POLICY_DEL_REASON_ID_IN    IN DELETED_ENDORSEMENTS_TB.POLICY_DEL_REASON_ID%TYPE,
          NOTES_IN                   IN DELETED_ENDORSEMENTS_TB.CANCELLED_NOTES%TYPE,
          CREATED_BY_IN              IN ENDORSEMENTS_TB.CREATED_BY%TYPE,
          LANG_IN                    IN VARCHAR2,
          ERR_DESC_OUT               OUT NOCOPY VARCHAR2,
          ERR_STATUS_OUT             OUT NOCOPY NUMBER );

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
          ERR_STATUS_OUT            OUT NUMBER);

END;
/