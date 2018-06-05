-- DROP PROCEDURE SP_SAVE_INFO_R

CREATE PROCEDURE SP_SAVE_INFO_R
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT

AS
--[モード] 0:読込 / 1:未読処理 / 2:ワークテーブル削除
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

    --読込処理
    IF @MODE = 0
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_INFO_R
         WHERE W_INFO_R.W_USER_ID = @USER_ID

        --新規保存(ワークテーブルに存在するインフォメーションを履歴にコピー)
        INSERT INTO
               W_INFO_R (
                         W_INFO_R.W_USER_ID
                        ,W_INFO_R.W_SERIAL
                        ,W_INFO_R.INFO_NO
                        ,W_INFO_R.W_MODE
                        ,W_INFO_R.SELECT_FLG
                        )
               SELECT 
                      @USER_ID
                     ,@SERIAL
                     ,T_INFO_R.INFO_NO
                     ,1
                     ,'False'
                 FROM T_INFO_R
                WHERE T_INFO_R.NT_TANTO_CD = @USER_ID

      END

    --未読(戻す)処理
     ELSE IF @MODE = 1
      BEGIN
      
        --新規保存(ワークテーブルに存在するインフォメーションを履歴にコピー)
        INSERT INTO
               T_INFO
               SELECT *
                 FROM T_INFO_R
                WHERE T_INFO_R.INFO_NO IN ( SELECT W_INFO_R.INFO_NO 
                                              FROM W_INFO_R
                                             WHERE W_INFO_R.W_USER_ID  = @USER_ID
                                               AND W_INFO_R.W_SERIAL   = @SERIAL
                                               AND W_INFO_R.SELECT_FLG = 'True' )

        --削除
        DELETE
          FROM T_INFO_R
         WHERE T_INFO_R.INFO_NO IN ( SELECT W_INFO_R.INFO_NO 
                                       FROM W_INFO_R
                                      WHERE W_INFO_R.W_USER_ID  = @USER_ID
                                        AND W_INFO_R.W_SERIAL   = @SERIAL 
                                        AND W_INFO_R.SELECT_FLG = 'True' )

        --ワークテーブルクリア
        DELETE
          FROM W_INFO_R
         WHERE W_INFO_R.W_USER_ID = @USER_ID

     END

    --ワークテーブル削除処理
    ELSE IF @MODE = 2
     BEGIN

            --ワークテーブルクリア
            DELETE
              FROM W_INFO_R
             WHERE W_INFO_R.W_USER_ID = @USER_ID

     END


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
      FROM W_INFO_R
     WHERE W_INFO_R.W_USER_ID = @USER_ID
       AND W_INFO_R.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
