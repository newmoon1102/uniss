-- DROP PROCEDURE SP_SAVE_M_MEISHO_B


CREATE PROCEDURE SP_SAVE_M_MEISHO_B
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@MEISHO_KBN NVARCHAR(4)
AS
--保存処理実行
BEGIN
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )
    
    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --変更前データ削除処理
    DELETE
      FROM M_MEISHO_B
     WHERE M_MEISHO_B.MEISHO_KBN = @MEISHO_KBN

    --保存(ワークテーブル→マスタ)
    INSERT INTO
           M_MEISHO_B(
                       MEISHO_KBN
                      ,MEISHO_CD
                      ,DATA_1
                      ,DATA_2
                      ,SORT_NO
                      ,MISHIYO_FLG
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                     )
                SELECT MEISHO_KBN
                      ,MEISHO_CD
                      ,DATA_1
                      ,DATA_2
                      ,SORT_NO
                      ,MISHIYO_FLG
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                  FROM W_MEISHO_B 
                 WHERE W_USER_ID = @USER_ID
                   AND W_SERIAL  = @SERIAL

    --ワークテーブルクリア
    DELETE
      FROM W_MEISHO_B
     WHERE W_MEISHO_B.W_USER_ID = @USER_ID
       AND W_MEISHO_B.W_SERIAL  = @SERIAL

    --正常終了
    INSERT INTO @TBL VALUES( 0, NULL )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_MEISHO_B
     WHERE W_MEISHO_B.W_USER_ID = @USER_ID
       AND W_MEISHO_B.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
