-- DROP PROCEDURE SP_SAVE_M_KOMOKU_SAMPLE


CREATE PROCEDURE SP_SAVE_M_KOMOKU_SAMPLE
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@BUNSEKI_CD NVARCHAR(10)
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

    --更新処理
    IF @MODE = 2
      BEGIN
        --変更前データ削除処理
        DELETE
          FROM M_KOMOKU_SAMPLE
         WHERE M_KOMOKU_SAMPLE.BUNSEKI_CD = @BUNSEKI_CD

        --ボディ保存(ワークテーブル→マスタ)
        INSERT INTO
               M_KOMOKU_SAMPLE(
                                  BUNSEKI_CD
                                 ,KOBAN
                                 ,MEISHO
                                 ,NYURYOKU
                                 ,KATA
                                 ,ALL_KETA
                                 ,SHOSU_KETA
                                 ,SETTEICHI
                                 ,DBS_STATUS
                                 ,DBS_CREATE_USER
                                 ,DBS_CREATE_DATE
                                 ,DBS_UPDATE_USER
                                 ,DBS_UPDATE_DATE
                                )
                           SELECT BUNSEKI_CD
                                 ,KOBAN
                                 ,MEISHO
                                 ,NYURYOKU
                                 ,KATA
                                 ,ALL_KETA
                                 ,SHOSU_KETA
                                 ,SETTEICHI
                                 ,DBS_STATUS
                                 ,DBS_CREATE_USER
                                 ,DBS_CREATE_DATE
                                 ,DBS_UPDATE_USER
                                 ,DBS_UPDATE_DATE
                             FROM W_KOMOKU_SAMPLE 
                            WHERE W_USER_ID = @USER_ID
                              AND W_SERIAL  = @SERIAL
      END

    --削除処理
    ELSE IF @MODE = 3
      BEGIN
        --既存データ削除
        DELETE
          FROM M_KOMOKU_SAMPLE
         WHERE M_KOMOKU_SAMPLE.BUNSEKI_CD = @BUNSEKI_CD
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_KOMOKU_SAMPLE
     WHERE W_KOMOKU_SAMPLE.W_USER_ID = @USER_ID
       AND W_KOMOKU_SAMPLE.W_SERIAL  = @SERIAL

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
      FROM W_KOMOKU_SAMPLE
     WHERE W_KOMOKU_SAMPLE.W_USER_ID = @USER_ID
       AND W_KOMOKU_SAMPLE.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
