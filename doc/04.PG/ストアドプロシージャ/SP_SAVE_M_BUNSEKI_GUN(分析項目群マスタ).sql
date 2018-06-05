-- DROP PROCEDURE SP_SAVE_M_BUNSEKI_GUN

CREATE PROCEDURE SP_SAVE_M_BUNSEKI_GUN
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
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
               M_BUNSEKI_GUN_B(
                                BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                    
        INSERT INTO
               M_BUNSEKI_GUN_H(
                                BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            AND SEQ       = '1'
      END
    
    --更新処理
    ELSE IF @MODE = 2
      BEGIN
        --既存データ削除
        DELETE
          FROM M_BUNSEKI_GUN_B
         WHERE M_BUNSEKI_GUN_B.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        DELETE
          FROM M_BUNSEKI_GUN_H
         WHERE M_BUNSEKI_GUN_H.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        --保存(ワークテーブル→マスタ)
        INSERT INTO
               M_BUNSEKI_GUN_B(
                                BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            
        INSERT INTO
               M_BUNSEKI_GUN_H(
                                BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            AND SEQ       ='1'
      END

    --削除処理
    ELSE
      BEGIN

        --既存データ削除
        DELETE
          FROM M_BUNSEKI_GUN_B
         WHERE M_BUNSEKI_GUN_B.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        DELETE
          FROM M_BUNSEKI_GUN_H
         WHERE M_BUNSEKI_GUN_H.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_BUNSEKI_GUN
     WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
       AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL

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
      FROM W_BUNSEKI_GUN
     WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
       AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
