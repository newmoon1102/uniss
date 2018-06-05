-- DROP PROCEDURE SP_SAVE_M_SHAIN


CREATE PROCEDURE SP_SAVE_M_SHAIN
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
               M_SHAIN(
                        SHAIN_CD
                       ,BUSHO_CD
                       ,SHIMEI
                       ,TANTO_MARK_PATH
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT SHAIN_CD
                       ,BUSHO_CD
                       ,SHIMEI
                       ,TANTO_MARK_PATH
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHAIN 
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
      END
    
    --更新処理
    ELSE IF @MODE = 2
      BEGIN
        --保存(ワークテーブル→マスタ)
         UPDATE M_SHAIN
            SET M_SHAIN.SHAIN_CD         = W_SHAIN.SHAIN_CD
               ,M_SHAIN.BUSHO_CD         = W_SHAIN.BUSHO_CD
               ,M_SHAIN.SHIMEI           = W_SHAIN.SHIMEI
               ,M_SHAIN.TANTO_MARK_PATH  = W_SHAIN.TANTO_MARK_PATH
               ,M_SHAIN.MISHIYO_FLG      = W_SHAIN.MISHIYO_FLG
               ,M_SHAIN.DBS_UPDATE_USER  = W_SHAIN.DBS_UPDATE_USER
               ,M_SHAIN.DBS_UPDATE_DATE  = W_SHAIN.DBS_UPDATE_DATE
           FROM M_SHAIN
          INNER JOIN
                W_SHAIN
             ON W_USER_ID = @USER_ID
            AND W_SERIAL  = @SERIAL
            AND W_SHAIN.SHAIN_CD   = M_SHAIN.SHAIN_CD
      END

    --削除処理
    ELSE
      BEGIN

        --既存データ削除
        DELETE
          FROM M_SHAIN
         WHERE M_SHAIN.SHAIN_CD IN ( SELECT W_SHAIN.SHAIN_CD
                                       FROM W_SHAIN
                                      WHERE W_SHAIN.W_USER_ID = @USER_ID
                                        AND W_SHAIN.W_SERIAL  = @SERIAL
                                      GROUP BY
                                            W_SHAIN.SHAIN_CD )
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_SHAIN
     WHERE W_SHAIN.W_USER_ID = @USER_ID
       AND W_SHAIN.W_SERIAL  = @SERIAL

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
      FROM W_SHAIN
     WHERE W_SHAIN.W_USER_ID = @USER_ID
       AND W_SHAIN.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
