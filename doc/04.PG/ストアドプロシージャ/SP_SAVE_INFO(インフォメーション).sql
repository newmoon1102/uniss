--DROP PROCEDURE SP_SAVE_INFO


CREATE PROCEDURE SP_SAVE_INFO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT

AS
--保存処理実行
BEGIN

--変数定義

    --戻り値
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

--セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --既読処理
    IF @MODE = 1
      BEGIN
      
        --新規保存(ワークテーブルに存在するインフォメーションを履歴にコピー)
        INSERT INTO
               T_INFO_R
               SELECT *
                 FROM T_INFO
                WHERE T_INFO.INFO_NO IN ( SELECT W_INFO.INFO_NO 
                                            FROM W_INFO
                                           WHERE W_INFO.W_USER_ID = @USER_ID
                                             AND W_INFO.W_SERIAL  = @SERIAL )
        --削除
        DELETE
          FROM T_INFO
         WHERE T_INFO.INFO_NO IN ( SELECT W_INFO.INFO_NO 
                                     FROM W_INFO
                                    WHERE W_INFO.W_USER_ID = @USER_ID
                                      AND W_INFO.W_SERIAL  = @SERIAL )
      END

    --全件既読処理
    IF @MODE = 2
      BEGIN
      
        --新規保存(ワークテーブルに存在するインフォメーションを履歴にコピー)
        INSERT INTO
               T_INFO_R
               SELECT *
                 FROM T_INFO
                WHERE T_INFO.NT_TANTO_CD = @USER_ID

        --削除
        DELETE
          FROM T_INFO
         WHERE T_INFO.NT_TANTO_CD = @USER_ID

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_INFO
     WHERE W_INFO.W_USER_ID = @USER_ID
       AND W_INFO.W_SERIAL  = @SERIAL

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
      FROM W_INFO
     WHERE W_INFO.W_USER_ID = @USER_ID
       AND W_INFO.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
