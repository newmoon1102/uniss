--DROP PROCEDURE SP_SAVE_M_YOSAN


CREATE PROCEDURE SP_SAVE_M_YOSAN
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
               M_YOSAN(
                        YOSAN_CD
                       ,YOSAN_MEI
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT YOSAN_CD
                       ,YOSAN_MEI
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_YOSAN 
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
      END
    
    --更新処理
    ELSE IF @MODE = 2
      BEGIN
    --保存(ワークテーブル→マスタ)
        UPDATE M_YOSAN
           SET M_YOSAN.YOSAN_CD           = W_YOSAN.YOSAN_CD
              ,M_YOSAN.YOSAN_MEI          = W_YOSAN.YOSAN_MEI
              ,M_YOSAN.DBS_STATUS         = W_YOSAN.DBS_STATUS
              ,M_YOSAN.DBS_UPDATE_USER    = W_YOSAN.DBS_UPDATE_USER
              ,M_YOSAN.DBS_UPDATE_DATE    = W_YOSAN.DBS_UPDATE_DATE
                  FROM M_YOSAN
                  INNER JOIN
                        W_YOSAN
                     ON W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_YOSAN.YOSAN_CD   = M_YOSAN.YOSAN_CD
      END

    --削除処理
    ELSE
      BEGIN

        --既存データ削除
        DELETE
          FROM M_YOSAN
         WHERE M_YOSAN.YOSAN_CD IN ( SELECT W_YOSAN.YOSAN_CD
                                       FROM W_YOSAN
                                      WHERE W_YOSAN.W_USER_ID = @USER_ID
                                        AND W_YOSAN.W_SERIAL  = @SERIAL
                                      GROUP BY
                                            W_YOSAN.YOSAN_CD )
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_YOSAN
     WHERE W_YOSAN.W_USER_ID = @USER_ID
       AND W_YOSAN.W_SERIAL  = @SERIAL

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
      FROM W_YOSAN
     WHERE W_YOSAN.W_USER_ID = @USER_ID
       AND W_YOSAN.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
