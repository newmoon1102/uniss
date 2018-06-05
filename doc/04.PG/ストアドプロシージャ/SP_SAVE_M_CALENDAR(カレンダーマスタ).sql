-- DROP PROCEDURE SP_SAVE_M_CALENDAR


CREATE PROCEDURE SP_SAVE_M_CALENDAR
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@YEAR       INT
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

    --新規登録処理
    IF @MODE = 1
      BEGIN
        --新規保存(ワークテーブル→マスタ)
        INSERT INTO
               M_CALENDAR(
                           YEAR
                          ,MONTH
                          ,DAY
                          ,CALENDAR_KBN
                          ,DBS_STATUS
                          ,DBS_CREATE_USER
                          ,DBS_CREATE_DATE
                          ,DBS_UPDATE_USER
                          ,DBS_UPDATE_DATE
                         )
                    SELECT YEAR
                          ,MONTH
                          ,DAY
                          ,CALENDAR_KBN
                          ,DBS_STATUS
                          ,DBS_CREATE_USER
                          ,DBS_CREATE_DATE
                          ,DBS_UPDATE_USER
                          ,DBS_UPDATE_DATE
                      FROM W_CALENDAR
                     WHERE W_USER_ID = @USER_ID
                       AND W_SERIAL  = @SERIAL
      END
    
    --更新処理
    IF @MODE = 2
      BEGIN
        --変更前データ削除処理
        DELETE
          FROM M_CALENDAR
         WHERE M_CALENDAR.YEAR = @YEAR

        --保存(ワークテーブル→マスタ)
        INSERT INTO M_CALENDAR
             SELECT YEAR
                   ,MONTH
                   ,DAY
                   ,CALENDAR_KBN
                   ,DBS_STATUS
                   ,DBS_CREATE_USER
                   ,DBS_CREATE_DATE
                   ,DBS_UPDATE_USER
                   ,DBS_UPDATE_DATE
               FROM W_CALENDAR 
              WHERE W_USER_ID = @USER_ID
                AND W_SERIAL  = @SERIAL

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_CALENDAR
     WHERE W_CALENDAR.W_USER_ID = @USER_ID
       AND W_CALENDAR.W_SERIAL  = @SERIAL

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
      FROM W_CALENDAR
     WHERE W_CALENDAR.W_USER_ID = @USER_ID
       AND W_CALENDAR.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
